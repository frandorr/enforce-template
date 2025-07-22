# Python Polylith Template with `uv`, `just`, `todo.txt`, and Obsidian

A template repository for Python projects using the Polylith architecture, powered by the `uv` package manager, `just` task runner, `todo.txt` for task tracking, and Obsidian for knowledge management.

## Philosophy

This repo **enforces decision-making**:

* Every change starts with a task.
* Every commit references a task.
* Every task ends in a PR.
* You control everything with `just`.

---

# Index

* [Simplest Usage](#simplest-usage)
* [Features](#features)
* [Getting Started](#getting-started)

  * [Prerequisites](#prerequisites)
  * [Setup](#setup)
  * [Obsidian setup](#obsidian-setup)
* [Dependencies](#dependencies)

  * [Development Dependencies](#development-dependencies)
  * [Recommended Additional Tools](#recommended-additional-tools)
* [Pre-commit Hooks](#pre-commit-hooks)

  * [Installing Pre-commit](#installing-pre-commit)
* [Project Structure](#project-structure)
* [Development Workflow](#development-workflow)
* [Commit Conventions](#commit-conventions)
* [License](#license)

---

## Simplest Usage

```bash
just todo-add "Implement login feature +auth_server @auth"
# ⤷ Adds a task with a timestamp and unique ID to todo.txt

just poly-create component auth "Authentication module"
# ⤷ Creates a new component named `auth`

# Write your code, then commit with a reference to the task ID (e.g., #112AFC)
git commit -m "feat(auth): implement login feature #112AFC"

git commit -m "feat(auth): implement logout feature [do #112AFC]"
# ⤷ Marks the task as done

just todo-list-done
# ⤷ Lists completed tasks
```

---

## Features

* Modular architecture via [Polylith](https://polylith.gitbook.io/)
* Fast, isolated dependency management with [`uv`](https://github.com/astral-sh/uv)
* Automation of all setup and development tasks using [`just`](https://github.com/casey/just)
* Personal task tracking with [`todo.txt`](https://github.com/todotxt/todo.txt-cli)
* Built-in support for [Obsidian](https://obsidian.md) as a knowledge base
* Git hook setup and commit enforcement via tasks

---

## Getting Started

### Prerequisites

* [`uv`](https://github.com/astral-sh/uv)
* [`just`](https://github.com/casey/just)
* [`todo.txt-cli`](https://github.com/todotxt/todo.txt-cli) – install via `just todo-install`
* [Obsidian](https://obsidian.md)

---

### Setup

```bash
just config
```

This single command:

* Sets up `just` completions
* Installs `todo.txt-cli`
* Configures `todo.txt` under your Git username
* Installs the commit-msg git hook
* Prompts for setting up the `t` alias for todo.txt

---

Update project names manually:

* In `workspace.toml`:

  ```toml
  [tool.polylith]
  namespace = "your-project-name"
  ```

* In `pyproject.toml`:

  ```toml
  [project]
  name = "your-project-name"
  ```

---

### Obsidian Setup

1. Install Obsidian
2. Open the vault in this repo: `docs`
3. Install community plugins:

   * `obsidian-excalidraw-plugin`
   * `todotxt-codeblocks`
4. Restart Obsidian

---

## Dependencies

### Development Dependencies

Installed via `uv` and managed in `pyproject.toml`:

* `pre-commit`
* `polylith-cli`
* `pytest`
* `basedpyright`

### Recommended Additional Tools

* [`togit-parser`](https://github.com/franciscod/togit-parser): Analyze dependencies between functions to enforce modularity. Install via:

```bash
cargo install togit-parser
```

---

## Pre-commit Hooks

Pre-configured in `.pre-commit-config.yaml`:

* `ruff` – Linting and formatting
* `basedpyright` – Type checking
* `nbstripout` – Cleans notebook outputs
* `pre-commit-hooks` – General purpose checks (e.g., trailing whitespace, YAML/JSON validity, etc.)

### Installing Pre-commit

```bash
uv run pre-commit install
```

---

## Project Structure

Polylith organizes code into:

* `components/` – Reusable building blocks
* `bases/` – Application entry points
* `projects/` – Deployable targets

Create bricks using:

```bash
just poly-create component my_component "My description"
just poly-create base my_base "My base"
just poly-create project my_project "My project"
```

---

## Development Workflow

1. Add a task:

   ```bash
   just todo-add "Implement login feature +auth_server @auth"
   ```

2. Create a component or base:

   ```bash
   just poly-create component auth "Authentication logic"
   ```

3. Develop features, test with:

   ```bash
   uv run pytest
   ```

4. Mark tasks as done:

   ```bash
   git commit -m "feat(auth): implement logout [do #112AFC]"
   ```

5. List tasks:

   ```bash
   just todo-list           # all tasks
   just todo-list-project   # grouped by project
   just todo-list-context   # grouped by context
   just todo-list-done      # completed
   ```

6. Manually mark task as done:

   ```bash
   just todo-done TASK_ID='#112AFC'
   ```

---

## Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org):

Examples:

```bash
git commit -m "feat(auth): implement login [do #112AFC]"
git commit -m "fix(api): correct error response handling #778FAD"
```

Merge policy:

* Rebase main into your feature branch before merging
* Use merge commits when merging to main

---

## License

MIT

---