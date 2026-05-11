# Examples — aer Plugin Template

This directory shows how to use the **aer plugin template** to scaffold a new plugin.

## Quick Start

1. **Copy the template** to a new repository:
   ```bash
   cp -r aer-plugin-template aer-my-new-plugin
   cd aer-my-new-plugin
   ```

2. **Run the setup script** to bootstrap your plugin:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   The setup script will:
   - Validate your project name follows the `aer-` prefix rule.
   - Install `uv` (if missing) and set up workspace dependencies.
   - Create your first **Component** (logic) and **Project** (packaging).
   - Generate a pre-configured `pyproject.toml` with standard entry points.

3. **Implement your plugin logic** in the generated component:
   - For search plugins: override the `search()` method.
   - For extract plugins: override `prepare_for_extraction()`, `extract()`, and `extract_batches()`.

4. **Run tests** to verify everything is wired correctly:
   ```bash
   uv run pytest
   ```

## Reference Implementations

For production-ready examples, see:

- **Search plugin**: [aer-search-aws-goes](https://github.com/frandorr/aer-search-aws-goes)
- **Extract plugin**: [aer-extract-aws-goes](https://github.com/frandorr/aer-extract-aws-goes)

## Files

| File | Description |
|------|-------------|
| `README.md` | This file — explains how to scaffold a new plugin from the template. |
