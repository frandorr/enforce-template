set shell := ["bash", "-cu"]

todo-install:
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

    # Set up alias in shell configuration file
    ALIAS_CMD="alias t='todo.sh -d $(pwd)/docs/todo/config'"
    FILE="${ZSH_VERSION:+$HOME/.zshrc}"
    FILE="${FILE:-$HOME/.bashrc}"

    mkdir -p "$(dirname "$FILE")"
    touch "$FILE"
    if ! grep -qxF "$ALIAS_CMD" "$FILE"; then
        echo "$ALIAS_CMD" >> "$FILE"
        echo "Alias added to $FILE"
    else
        echo "Alias already exists in $FILE"
    fi
    echo "Run: source $FILE to activate the alias"

git-config:
    git config core.hooksPath .githooks
    echo "Git is now using custom enforce hooks from .githooks/"
    git config merge.union.driver true
    echo "Git is now configured to use union merge driver for todo files"

# Add a task with timestamp
todo-add TASK='':
    #!/usr/bin/env bash
    if [[ -z "{{ TASK }}" ]]; then echo "❌ Usage: just add-task TASK='your task description'"; exit 1; fi
    UUID=$(uuidgen)
    # take first 6 characters of UUID
    UUID_SHORT=${UUID:0:6}
    NOW=$(date -u +"%Y-%m-%dT%H:%M") && todo.sh -d docs/todo/config add "$NOW {{ TASK }} #$UUID_SHORT"
    echo "Task added with ID #$UUID_SHORT at $NOW"

todo-list:
    #!/usr/bin/env bash
    todo.sh -d docs/todo/config list | sort -n

todo-list-done:
    #!/usr/bin/env bash
    todo.sh -d docs/todo/config lsa | grep ' x ' | sort -n

todo-done TASK_ID='':
    #!/usr/bin/env bash
    set -euo pipefail

    # Get lowercase username from git config, replacing spaces with underscores
    user=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    todo_dir="docs/todo/$user"

    if [[ ! "{{ TASK_ID }}" =~ ^(#[0-9a-fA-F]{6}( #[0-9a-fA-F]{6})*)$ ]]; then echo "❌ Usage: just todo-done TASK_ID='#id #id2 #id3'"; exit 1; fi
    # grep line numbers of task ID in todo.txt
    # for each id, find the line number in todo.txt
    IFS=' ' read -r -a IDS <<< "{{ TASK_ID }}"
    for ID in "${IDS[@]}"; do
        # Find the line containing the task ID in todo.txt
        # Escape special characters in ID for grep
        ESCAPED_ID=$(printf '%s' "$ID" | sed 's/[][\.*^$(){}?+|/\\]/\\&/g')
        LINE=$(grep "$ESCAPED_ID" "$todo_dir/todo.txt" || true)
        if [[ -z "$LINE" ]]; then
            echo "No matching task found for ID '$ID'"
            echo "Existing tasks are:"
            just todo-list
            exit 1
        fi
        FINISH_DATE=$(date -u +"%Y-%m-%dT%H:%M")
        # Append the task to done.txt with the finish date
        echo "x $FINISH_DATE $LINE" >> "$todo_dir/done.txt"
        LINE_NUM=$(grep -n "$ESCAPED_ID" "$todo_dir/todo.txt" | cut -d: -f1)
        todo.sh -d docs/todo/config -f del $LINE_NUM

        echo "Task $ID marked as done with date $FINISH_DATE"
    done
