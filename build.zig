const std = @import("std");
const zon = @import("build.zig.zon");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const force_llvm = b.option(bool, "llvm", "Force the LLVM code generator (required for --fuzz)") orelse false;
    const link_tdlib = b.option(bool, "tdlib", "Link system libtdjson directly") orelse false;

    // 1. Exported root module (`telegram`)
    const telegram_mod = b.addModule("telegram", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    if (link_tdlib) {
        telegram_mod.linkSystemLibrary("tdjson", .{});
    }

    // 2. CLI executable (`zig-telegram`)
    const cli = b.addExecutable(.{
        .name = "zig-telegram",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/cli.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "telegram", .module = telegram_mod },
            },
        }),
    });
    b.installArtifact(cli);

    const run_cli = b.addRunArtifact(cli);
    run_cli.addPassthruArgs();
    b.step("run", "Run the zig-telegram CLI").dependOn(&run_cli.step);

    // 3. Bot API 10.3 code generator (`gen-spec` and `spec-check`)
    const gen_exe = b.addExecutable(.{
        .name = "gen-bot-api",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/gen_bot_api.zig"),
            .target = b.graph.host,
            .optimize = .Debug,
        }),
    });
    const run_gen = b.addRunArtifact(gen_exe);
    b.step("gen-spec", "Regenerate src/bot/{enums,types,methods,client}.zig from spec/bot_api_10_3.json").dependOn(&run_gen.step);

    const run_spec_check = b.addRunArtifact(gen_exe);
    run_spec_check.addArg("--check");
    const spec_check_step = b.step("spec-check", "Verify generated Bot API 10.3 sources match spec/bot_api_10_3.json");
    spec_check_step.dependOn(&run_spec_check.step);

    // 4. Unit tests, Golden Bot API 10.3 tests, CLI tests, and Examples
    const lib_tests = b.addTest(.{
        .root_module = telegram_mod,
        .use_llvm = if (force_llvm) true else null,
    });

    const golden_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/golden_bot_api.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "telegram", .module = telegram_mod }},
        }),
        .use_llvm = if (force_llvm) true else null,
    });

    const cli_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/cli_cases.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "telegram", .module = telegram_mod },
                .{
                    .name = "cli",
                    .module = b.createModule(.{
                        .root_source_file = b.path("src/cli.zig"),
                        .target = target,
                        .optimize = optimize,
                        .imports = &.{.{ .name = "telegram", .module = telegram_mod }},
                    }),
                },
            },
        }),
        .use_llvm = if (force_llvm) true else null,
    });

    const test_cli_step = b.step("test-cli", "Run the CLI test suite");
    test_cli_step.dependOn(&b.addRunArtifact(cli_unit_tests).step);

    // End-to-end binary execution checks for `zig-telegram`
    const run_ver = b.addRunArtifact(cli);
    run_ver.addArg("version");
    run_ver.expectStdOutEqual(b.fmt("zig-telegram {s} (Bot API 10.3, 185 methods)\n", .{zon.version}));
    test_cli_step.dependOn(&run_ver.step);

    const run_spec = b.addRunArtifact(cli);
    run_spec.addArgs(&.{ "spec", "--method", "sendMediaGroup" });
    run_spec.expectStdOutEqual("{\"version\":\"Bot API 10.3\",\"method\":\"sendMediaGroup\",\"supported\":true}\n");
    test_cli_step.dependOn(&run_spec.step);

    const test_step = b.step("test", "Run all unit, golden, CLI, spec-check, and example tests");
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);
    test_step.dependOn(&b.addRunArtifact(golden_tests).step);
    test_step.dependOn(test_cli_step);
    test_step.dependOn(spec_check_step);

    b.step("test-build", "Compile tests without running them (for cross targets)").dependOn(&lib_tests.step);

    for ([_][]const u8{ "echo_bot", "webhook_bot", "media_group", "mtproto_frame" }) |example_name| {
        const ex = b.addExecutable(.{
            .name = example_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(b.fmt("examples/{s}.zig", .{example_name})),
                .target = target,
                .optimize = optimize,
                .imports = &.{.{ .name = "telegram", .module = telegram_mod }},
            }),
        });
        const run_ex = b.addRunArtifact(ex);
        run_ex.expectExitCode(0);
        test_step.dependOn(&run_ex.step);
    }

    // 5. ReleaseFast benchmarks (`zig build bench` and `zig build perf-check`)
    const fast_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });
    const bench_exe = b.addExecutable(.{
        .name = "bench",
        .root_module = b.createModule(.{
            .root_source_file = b.path("bench/bench.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .imports = &.{.{ .name = "telegram", .module = fast_mod }},
        }),
    });
    const run_bench = b.addRunArtifact(bench_exe);
    run_bench.addPassthruArgs();
    b.step("bench", "Run ReleaseFast throughput benchmarks").dependOn(&run_bench.step);

    const run_perf_check = b.addRunArtifact(bench_exe);
    run_perf_check.addArgs(&.{ "--quick", "--check" });
    b.step("perf-check", "Fail if single-pass JSON or MTProto AES-256-IGE throughput regresses").dependOn(&run_perf_check.step);

    // 6. Documentation & GitHub Pages landing site (`zig build docs`)
    // Installs the technical-design landing page at `zig-out/docs/index.html`
    // and the Zig autodoc API reference at `zig-out/docs/api/`.
    const docs_lib = b.addLibrary(.{
        .name = "telegram",
        .root_module = telegram_mod,
    });
    const install_api_docs = b.addInstallDirectory(.{
        .source_dir = docs_lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs/api",
    });
    const install_site = b.addInstallDirectory(.{
        .source_dir = b.path("docs/site"),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Build GitHub Pages technical landing site and Zig API reference into zig-out/docs");
    docs_step.dependOn(&install_api_docs.step);
    docs_step.dependOn(&install_site.step);
}
