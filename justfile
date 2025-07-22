set shell := ["bash", "-cu"]

red := '\x1b[0;31m'
yellow := '\x1b[0;33m'
blue := '\x1b[0;34m'
magenta := '\x1b[0;35m'
green := '\x1b[0;32m'
reset := '\x1b[0m'

config:
    #!/usr/bin/env bash
    set -euo pipefail
    echo -e "{{ blue }}Setting up your environment...{{ reset }}"
    just --completions bash > ~/.just-completions.bash
    JUST_COMPLETION_CMD="source ~/.just-completions.bash"
    FILE="${ZSH_VERSION:+$HOME/.zshrc}"
    FILE="${FILE:-$HOME/.bashrc}"

    mkdir -p "$(dirname "$FILE")"
    touch "$FILE"
    if ! grep -qxF "$JUST_COMPLETION_CMD" "$FILE"; then
        echo "$JUST_COMPLETION_CMD" >> "$FILE"
        echo -e "{{ green }}Alias added to $FILE{{ reset }}"
    else
        echo -e "{{ yellow }}Alias already exists in $FILE{{ reset }}"
    fi
    echo -e "{{ green }}Just completions generated at ~/.just-completions.bash{{ reset }}"
    # run git-config to set up git hooks
    echo -e "{{ blue }}Running git-config to set up git hooks...{{ reset }}"
    just git-config
    # run todo-install to install todo.txt-cli
    echo -e "{{ blue }}Running todo-install to install todo.txt-cli...{{ reset }}"
    just todo-install
    # run todo-config to set up todo configuration
    echo -e "{{ blue }}Running todo-config to set up todo configuration...{{ reset }}"
    just todo-config
    # ask if the user wants to set up the todo alias
    read -p "Do you want to set up the todo alias? (y/n): " setup_alias
    if [[ "$setup_alias" == "y" || "$setup_alias" == "Y" ]]; then
        echo -e "{{ green }}Setting up todo alias...{{ reset }}"
        just todo-alias
    else
        echo -e "{{ yellow }}Skipping todo alias setup.{{ reset }}"
    fi

git-config:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d .git/hooks ]; then
        echo -e "{{ red }}.git/hooks directory does not exist. Please run this command in a git repository.{{ reset }}"
        exit 1
    fi
    if [ ! -f .git/hooks/commit-msg ]; then
        echo -e "{{ green }}Copying .githooks/commit-msg to .git/hooks/commit-msg{{ reset }}"
        cp .githooks/commit-msg .git/hooks/commit-msg
        chmod +x .git/hooks/commit-msg
        echo -e "{{ green }}Commit-msg hook installed successfully.{{ reset }}"
    else
        echo -e "{{ red }}.git/hooks/commit-msg already exists. Please remove it before running this command.{{ reset }}"
        exit 1
    fi

todo-install:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v todo.sh &> /dev/null; then
        echo -e "{{ blue }}Installing todo.txt-cli...{{ reset }}"
    else
        echo -e "{{ yellow }}todo.txt-cli is already installed. Skipping installation.{{ reset }}"
        exit 0
    fi
    wget https://github.com/todotxt/todo.txt-cli/archive/refs/tags/v2.13.0.tar.gz
    tar -xzf v2.13.0.tar.gz
    cd todo.txt-cli-2.13.0 && sudo make install
    sudo chown -R "$USER":"$USER" docs/todo
    rm v2.13.0.tar.gz
    rm -rf todo.txt-cli-2.13.0

# Initialize todo configuration for the current user
todo-config:
    #!/usr/bin/env bash
    set -euo pipefail

    # Get lowercase username from git config, replacing spaces with underscores
    user=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    todo_dir="docs/todo/$user"

    # Create todo directory and necessary files
    mkdir -p "$todo_dir"
    touch "$todo_dir/todo.txt" "$todo_dir/done.txt" "$todo_dir/report.txt"
    chmod u+rw "$todo_dir"/*

todo-alias:
    #!/usr/bin/env bash
    set -euo pipefail
    # Set up alias in shell configuration file
    ALIAS_CMD="alias t='todo.sh -d $(pwd)/docs/todo/config'"
    FILE="${ZSH_VERSION:+$HOME/.zshrc}"
    FILE="${FILE:-$HOME/.bashrc}"

    mkdir -p "$(dirname "$FILE")"
    touch "$FILE"
    if ! grep -qxF "$ALIAS_CMD" "$FILE"; then
        echo "$ALIAS_CMD" >> "$FILE"
        echo -e "{{ green }}Alias added to $FILE{{ reset }}"
    else
        echo -e "{{ yellow }}Alias already exists in $FILE{{ reset }}"
    fi
    echo -e "{{ blue }}Run: source $FILE to activate the alias{{ reset }}"

# Add a task with timestamp
todo-add TASK:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -z "{{ TASK }}" ]]; then echo -e "{{ red }}Usage: just add-task 'your task description +project @context'{{ reset }}"; exit 1; fi
    # check if project and context are present with regex (+project and @context)
    if ! [[ "{{ TASK }}" =~ \+([a-zA-Z0-9_-]+) ]] || ! [[ "{{ TASK }}" =~ @([a-zA-Z0-9_-]+) ]]; then
        echo -e "{{ red }}Task must include a project (e.g., +project) and a context (e.g., @context).{{ reset }}"
        exit 1
    fi
    UUID=$(uuidgen)
    # take first 6 characters of UUID
    UUID_SHORT=${UUID:0:6}
    NOW=$(date -u +"%Y-%m-%dT%H:%M") && todo.sh -d docs/todo/config add "$NOW {{ TASK }} #$UUID_SHORT"
    echo -e "{{ green }}Task added with ID #$UUID_SHORT at $NOW{{ reset }}"

todo-list:
    #!/usr/bin/env bash
    echo -e "{{ blue }}Listing all tasks...{{ reset }}"
    todo.sh -d docs/todo/config list | sort -n

todo-list-context:
    #!/usr/bin/env bash
    echo -e "{{ blue }} List of tasks by context...{{ reset }}"
    todo.sh -d docs/todo/config cv

todo-list-project:
    #!/usr/bin/env bash
    echo -e "{{ blue }} List of tasks by project...{{ reset }}"
    todo.sh -d docs/todo/config pv

todo-list-done:
    #!/usr/bin/env bash
    todo.sh -d docs/todo/config lsa | grep ' x ' | sort -n

todo-done TASK_ID='':
    #!/usr/bin/env bash
    set -euo pipefail

    # Get lowercase username from git config, replacing spaces with underscores
    user=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    todo_dir="docs/todo/$user"

    if [[ ! "{{ TASK_ID }}" =~ ^(#[0-9a-fA-F]{6}( #[0-9a-fA-F]{6})*)$ ]]; then echo -e "{{ red }}❌ Usage: just todo-done TASK_ID='#id #id2 #id3'{{ reset }}"; exit 1; fi
    # grep line numbers of task ID in todo.txt
    # for each id, find the line number in todo.txt
    IFS=' ' read -r -a IDS <<< "{{ TASK_ID }}"
    for ID in "${IDS[@]}"; do
        # Find the line containing the task ID in todo.txt
        # Escape special characters in ID for grep
        ESCAPED_ID=$(printf '%s' "$ID" | sed 's/[][\.*^$(){}?+|/\\]/\\&/g')
        LINE=$(grep "$ESCAPED_ID" "$todo_dir/todo.txt" || true)
        if [[ -z "$LINE" ]]; then
            echo -e "{{ red }}No matching task found for ID '$ID'{{ reset }}"
            echo -e "{{ blue }}Existing tasks are:{{ reset }}"
            just todo-list
            exit 1
        fi
        FINISH_DATE=$(date -u +"%Y-%m-%dT%H:%M")
        # Append the task to done.txt with the finish date
        echo "x $FINISH_DATE $LINE" >> "$todo_dir/done.txt"
        LINE_NUM=$(grep -n "$ESCAPED_ID" "$todo_dir/todo.txt" | cut -d: -f1)
        todo.sh -d docs/todo/config -f del $LINE_NUM

        echo -e "{{ green }}Task $ID marked as done with date $FINISH_DATE{{ reset }}"
    done

poly-create BRICK_TYPE NAME DESCRIPTION='':
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{ BRICK_TYPE }}" != "component" && "{{ BRICK_TYPE }}" != "base" && "{{ BRICK_TYPE }}" != "project" ]]; then
        echo -e "{{ red }}Invalid brick type '{{ BRICK_TYPE }}'. Use: component, base, or project.{{ reset }}"
        echo -e "{{ blue }}Example: just poly-create component sample_name 'A sample component'{{ reset }}"
        exit 1
    fi

    echo -e "{{ green }}Creating a new {{ BRICK_TYPE }}: '{{ NAME }}'{{ reset }}"
    # check if DESCRIPTION is empty
    if [[ -z "{{ DESCRIPTION }}" ]]; then
        uv run poly create {{ BRICK_TYPE }} --name "{{ NAME }}"
    else
        uv run poly create {{ BRICK_TYPE }} --name "{{ NAME }}" --description "{{ DESCRIPTION }}"
    fi

[positional-arguments]
poly *args:
    #!/usr/bin/env bash
    set -euo pipefail
    uv run poly "$@"
    # if the first argument is not "info", run poly info
    if [[ "$1" != "info" ]]; then
        uv run poly info
    fi
