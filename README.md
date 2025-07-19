# Python Polylith Template with uv, todo.txt and Obsidian

A template repository for Python projects using the Polylith architecture with uv package manager that enforces practices and conventions.

## Philosophy

This repo **enforces decision-making**:

- Every change starts with a task.
- Every commit references a task.
- Every task ends in a PR.
- You control everything with `just`.

# Index

- [Simplest Usage](#simplest-usage)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Obsidian setup](#obsidian-setup)
- [Dependencies](#dependencies)
  - [Development Dependencies](#development-dependencies)
  - [Recommended Additional Tools](#recommended-additional-tools)
- [Pre-commit Hooks](#pre-commit-hooks)
  - [Installing Pre-commit](#installing-pre-commit)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Commit Conventions](#commit-conventions)
- [License](#license)

## Simplest Usage

```bash
just todo-add "Implement login feature +auth_server @auth"
# This creates a task with a reference, i.e. #112AFC and timestamp in todo.txt
just poly-add component auth # create a component
# implement your functionality...
git commit -m "feat(auth): implement login feature #112AFC"
# more functionalities...
git commit -m "feat(auth): implement logout feature [do #112AFC]"
# task is marked as done and available at done.txt
just todo-list-done # list done tasks
```

## Features

- Polylith architecture for modular, maintainable Python code
- uv package manager for fast, reliable dependency management
- Pre-configured development tools
- Pre-commit hooks for code quality checks, `just` tasks for common operations
- todo.txt for task management and Obsidian for knowledge management
- Python 3.13+ support

## Getting Started

### Prerequisites

- [uv](https://github.com/astral-sh/uv) package manager
- [just](https://github.com/casey/just) for task automation
- [todo.txt](https://github.com/todotxt/todo.txt-cli) (install with `just install-todotxt`)
- [Obsidian](https://obsidian.md/) for knowledge management

### Setup

1. Use this template to create a new repository
2. Modify the project name in `workspace.toml`:
   ```toml
   [tool.polylith]
   namespace = "your-project-name"
   ```
3. Update project details in `pyproject.toml`
4. Run `uv sync` to install dependencies
5. Run `uv run poly --help` to see available Polylith commands

### Obsidian setup

1. Install Obsidian
2. Open Obsidian and open the vault in this repo `docs`
3. Install the plugins recommenden community plugins:
   `obsidian-excalidraw-plugin` and `todotxt-codeblocks`
4. Restart Obsidian

## Dependencies

### Development Dependencies

This template includes the following development dependencies:

- **pre-commit**: Manages Git hooks for code quality checks
- **polylith-cli**: Command-line interface for Polylith architecture
- **pytest**: Testing framework
- **basedpyright**: Type checking tool

### Recommended Additional Tools

We recommend installing the following additional tools:

- **togit-parser**: A tool to check dependencies between your python functions. You can install it with `cargo install togit-parser`. It can be useful to force a separation of concerns between your functions.

## Pre-commit Hooks

The template includes several pre-commit hooks for code quality:

- **ruff**: Lints and formats Python code
- **basedpyright**: Type checks Python code
- **pre-commit-hooks**: Various code quality checks
  - trailing-whitespace
  - check-added-large-files
  - check-docstring-first
  - check-json
  - check-merge-conflict
  - check-symlinks
  - check-yaml
  - debug-statements
  - name-tests-test
- **nbstripout**: Cleans Jupyter notebook outputs

### Installing Pre-commit

```bash
uv run pre-commit install
```

## Project Structure

The Polylith architecture organizes code into:

- **Components**: Reusable building blocks
- **Bases**: Entry points to your application
- **Projects**: Deployable artifacts

## Development Workflow

1. Add tasks with `t add <description> +<project> @<component>`.
   i.e. `t add "Implement login feature" +auth_server +auth`
2. Create components and bases using Polylith CLI
3. Implement your functionality
4. Create projects to package your code
5. Run tests with `uv run pytest`
6. Commit your changes with `git commit -m "feat(auth): implement login feature #1"`
   a. To close a task, add `[do #1]` to your commit message
   b. To close multiple tasks, add `[do #1 #2 #3]` to your commit message.
   i.e. `git commit -m "feat(auth): implement login feature [do #1 #2] #3"` will close tasks 1 and 2, and leave task 3 open.

## Commit Conventions

This project uses the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summarys) format for commit messages.

To keep a clean history easy to review:

- rebase main into your branch before merging
- merge commit when merging on the main branch

## License

MIT
