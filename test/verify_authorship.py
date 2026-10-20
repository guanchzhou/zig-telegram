#!/usr/bin/env python3
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXPECTED_AUTHOR = "Andrey Maltsev"
FORBIDDEN_TRAILERS = (
    "Co-" + "authored-by:",
    "Generated-" + "by:",
    "cursor" + "agent",
)


def main() -> None:
    configured = subprocess.run(
        ["git", "config", "user.name"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if configured.returncode == 0 and configured.stdout.strip():
        assert configured.stdout.strip() == EXPECTED_AUTHOR, (
            f"Expected {EXPECTED_AUTHOR}, got {configured.stdout.strip()}"
        )

    history = subprocess.run(
        ["git", "log", "--format=%an%n%cn%n%B"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if history.returncode == 0:
        for trailer in FORBIDDEN_TRAILERS:
            assert trailer not in history.stdout, f"git log contains {trailer}"
        names = subprocess.run(
            ["git", "log", "--format=%an%n%cn"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=True,
        ).stdout
        authors = {line for line in names.splitlines() if line}
        assert authors <= {EXPECTED_AUTHOR}, f"Unexpected authors: {authors}"
    else:
        assert "does not have any commits yet" in history.stderr

    for path in ROOT.rglob("*"):
        if (
            not path.is_file()
            or ".git" in path.parts
            or ".zig-cache" in path.parts
            or "zig-out" in path.parts
        ):
            continue
        try:
            text = path.read_text()
        except UnicodeDecodeError:
            continue
        for trailer in FORBIDDEN_TRAILERS:
            assert trailer not in text, f"{path.relative_to(ROOT)} contains {trailer}"

    assert EXPECTED_AUTHOR in (ROOT / "LICENSE").read_text()
    assert EXPECTED_AUTHOR in (ROOT / "README.md").read_text()


if __name__ == "__main__":
    main()
