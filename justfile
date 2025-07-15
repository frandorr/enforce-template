set shell := ["bash", "-cu"]

install-todotxt:
    wget https://github.com/todotxt/todo.txt-cli/archive/refs/tags/v2.13.0.tar.gz
    tar -xzf v2.13.0.tar.gz
    cd todo.txt-cli-2.13.0 && sudo make install
    sudo chown -R "$USER":"$USER" docs/todo
    rm v2.13.0.tar.gz
    rm -rf todo.txt-cli-2.13.0
    # sudo sed -i 's|^export TODO_DIR=.*|export TODO_DIR=$(pwd)/docs/todo|' $(pwd)/docs/todo/config
    # bash -c '\
    #     mkdir -p $(pwd)/docs/todo && \
    #     for f in todo.txt done.txt report.txt; do \
    #         touch "$(pwd)/docs/todo/$f"; \
    #         chmod u+rw "$(pwd)/docs/todo/$f"; \
    #     done \
    # '
    bash -c '\
        ALIAS_CMD="alias t='\''todo.sh -d $(pwd)/docs/todo/config'\''"; \
        FILE="${ZSH_VERSION:+$HOME/.zshrc}"; \
        FILE="${FILE:-$HOME/.bashrc}"; \
        mkdir -p "$(dirname "$FILE")"; \
        touch "$FILE"; \
        grep -qxF "$ALIAS_CMD" "$FILE" || echo "$ALIAS_CMD" >> "$FILE"; \
        echo "✅ Alias added to $FILE (if not already present)"; \
        echo "🔁 Run: source $FILE to activate the alias"; \
    '

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
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%S") && todo.sh -d docs/todo/config add "$NOW {{ TASK }} #$UUID_SHORT"

todo-list:
    #!/usr/bin/env bash
    todo.sh -d docs/todo/config list | sort -n

todo-done TASK_ID='':
    #!/usr/bin/env bash
    # check TASK_ID is a list of #ids
    if [[ ! "{{ TASK_ID }}" =~ ^(#[0-9a-fA-F]{6}( #[0-9a-fA-F]{6})*)$ ]]; then echo "❌ Usage: just todo-done TASK_ID='#id #id2 #id3'"; exit 1; fi
    # grep line numbers of task ID in todo.txt
    # for each id, find the line number in todo.txt
    IFS=' ' read -r -a IDS <<< "{{ TASK_ID }}"
    LINE_NUMS=()
    for ID in "${IDS[@]}"; do
        LINE_NUM=$(grep -n "$ID" docs/todo/todo.txt | cut -d: -f1)
        if [[ -z "$LINE_NUM" ]]; then
            echo "❌ No matching task found for ID '$ID'"
            echo "Existing tasks are:"
            # avoid fetching completed tasks in todo.txt (marked with 'x')
            just todo-list
            exit 1
        fi
        LINE_NUMS+=("$LINE_NUM")
    done
    # Mark the task as done in done.txt
    todo.sh -d docs/todo/config do ${LINE_NUMS[*]}
    # LINE_NUM=$(cat docs/todo/todo.txt | grep -n "{{ TASK_ID }}" | cut -d: -f1)
    # if [[ -z "$LINE_NUM" ]]; then
    #     echo "❌ No matching task found for ID '{{ TASK_ID }}'"
    #     exit 1
    # fi
    # # Remove the task from todo.txt
    # todo.sh -d docs/todo/config do "$LINE_NUM" -a
    # echo "✅ Task '{{ TASK_ID }}' marked as done and removed from todo.txt"

# # List current todo tasks
# list:
#     echo "📋 Current tasks:"
#     cat {{TODO_FILE}} || echo "No tasks found."
# # Mark task as done by matching part of the line (safe)
# done MATCH='':
#     if [[ -z "{{MATCH}}" ]]; then
#         echo "❌ Usage: just done MATCH='part of task'"
#         exit 1
#     fi
#     MATCHED=$(grep "{{MATCH}}" {{TODO_FILE}} || true)
#     if [[ -z "$MATCHED" ]]; then
#         echo "❌ No matching task found"
#         exit 1
#     fi
#     echo "$MATCHED" >> {{DONE_FILE}}
#     sed -i "" "/{{MATCH}}/d" {{TODO_FILE}} || sed -i "/{{MATCH}}/d" {{TODO_FILE}} # Linux/macOS
#     echo "✅ Moved to done.txt: $MATCHED"
# # Show completed tasks
# done-list:
#     echo "✅ Completed tasks:"
#     cat {{DONE_FILE}} || echo "No completed tasks."
