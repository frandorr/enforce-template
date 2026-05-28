"""Smoke tests for the aereo-plugin-template repository."""

import subprocess
import sys
import tomllib
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent


def test_repo_has_required_files():
    """The template must contain the essential scaffolding files."""
    required = [
        "pyproject.toml",
        "workspace.toml",
        "setup.sh",
        "README.md",
        "LICENSE",
        "CONTRIBUTING.md",
        "CODE_OF_CONDUCT.md",
        "CHANGELOG.md",
        ".gitignore",
    ]
    for name in required:
        path = REPO_ROOT / name
        assert path.exists(), f"Missing required file: {name}"
        assert path.is_file(), f"Expected file, found directory: {name}"


def test_pyproject_has_required_fields():
    """Root pyproject.toml must contain the metadata required for packaging."""
    pyproject_path = REPO_ROOT / "pyproject.toml"
    with pyproject_path.open("rb") as f:
        data = tomllib.load(f)

    project = data["project"]
    assert project["name"] == "aereo-plugin-template"
    assert project["license"] == "Apache-2.0"
    assert ">=3.12" in project["requires-python"]
    assert "keywords" in project
    assert "classifiers" in project
    assert "urls" in project
    assert "Homepage" in project["urls"]
    assert "Repository" in project["urls"]
    assert "Issues" in project["urls"]
    assert "Documentation" in project["urls"]


def test_workspace_toml_has_polylith_config():
    """workspace.toml must declare the polylith namespace and theme."""
    workspace_path = REPO_ROOT / "workspace.toml"
    with workspace_path.open("rb") as f:
        data = tomllib.load(f)

    assert data["tool"]["polylith"]["namespace"] == "aereo"
    assert data["tool"]["polylith"]["structure"]["theme"] == "loose"
    assert data["tool"]["polylith"]["test"]["enabled"] is True


def test_setup_sh_is_executable():
    """setup.sh must be executable so new users can run it directly."""
    setup_path = REPO_ROOT / "setup.sh"
    assert setup_path.exists()
    mode = setup_path.stat().st_mode
    assert mode & 0o111, "setup.sh is not executable"


def test_setup_sh_syntax_is_valid():
    """bash -n should parse setup.sh without errors."""
    setup_path = REPO_ROOT / "setup.sh"
    result = subprocess.run(
        ["bash", "-n", str(setup_path)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, f"bash syntax error:\n{result.stderr}"


def test_gitignore_has_env():
    """.gitignore must prevent accidental commits of .env files."""
    gitignore_path = REPO_ROOT / ".gitignore"
    content = gitignore_path.read_text()
    assert ".env" in content, ".gitignore must contain '.env'"


def test_release_script_imports():
    """The release helper script must be valid Python."""
    release_script = REPO_ROOT / ".agents" / "scripts" / "release.py"
    assert release_script.exists()

    # Attempt to compile the script
    release_script.read_text()
    result = subprocess.run(
        [sys.executable, "-m", "py_compile", str(release_script)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, f"release.py failed to compile:\n{result.stderr}"


def test_pyproject_has_uv_workspace():
    """The template must be configured as a uv workspace with polylith members."""
    pyproject_path = REPO_ROOT / "pyproject.toml"
    with pyproject_path.open("rb") as f:
        data = tomllib.load(f)

    assert data["tool"]["uv"]["managed"] is True
    assert "members" in data["tool"]["uv"]["workspace"]
    assert data["tool"]["uv"]["workspace"]["members"] == ["projects/*"]


def test_pyproject_has_hatch_build_config():
    """Hatch build must be configured for polylith dev-mode directories."""
    pyproject_path = REPO_ROOT / "pyproject.toml"
    with pyproject_path.open("rb") as f:
        data = tomllib.load(f)

    hatch_build = data["tool"]["hatch"]["build"]
    assert "dev-mode-dirs" in hatch_build
    dirs = hatch_build["dev-mode-dirs"]
    assert "components" in dirs
    assert "bases" in dirs
