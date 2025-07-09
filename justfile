install-todotxt:
    wget https://github.com/todotxt/todo.txt-cli/archive/refs/tags/v2.13.0.tar.gz
    tar -xzf v2.13.0.tar.gz
    cd todo.txt-cli-2.13.0 && sudo make install
    sudo chown -R "$USER":"$USER" docs/todo
    rm v2.13.0.tar.gz
    rm -rf todo.txt-cli-2.13.0
    sudo sed -i 's|^export TODO_DIR=.*|export TODO_DIR=$(pwd)/docs/todo|' $(pwd)/docs/todo/config
    bash -c '\
        mkdir -p $(pwd)/docs/todo && \
        for f in todo.txt done.txt report.txt; do \
            touch "$(pwd)/docs/todo/$f"; \
            chmod u+rw "$(pwd)/docs/todo/$f"; \
        done \
    '
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
