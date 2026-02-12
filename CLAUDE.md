# CLAUDE.md

## Project overview

taal.nvim is a Neovim plugin written in Lua that uses LLMs (Claude, Gemini, OpenAI) to check and improve grammar and spelling of natural language text. It highlights errors, shows word-level diffs, and can apply suggestions individually or all at once. There is also an Ollama adapter, but it is not documented for end users in README.md because it is not reliable enough for production use. It is useful for testing since it's free.

## Directory structure

- `lua/taal/` - Main source code
  - `adapters/` - LLM provider implementations (claude, gemini, ollama, openai_responses)
  - `templates/` - Prompt templates (grammar, interact, recognize_language)
  - `init.lua` - Plugin entry point and setup
  - `commands.lua` - User command implementations
  - `config.lua` - Configuration management
  - `diff.lua` - Word-level text diffing
  - `buffer_helper.lua` - Buffer/UI operations (extmarks, highlights, inlay hints)
  - `template_sender.lua` - HTTP request handling (factory pattern)
  - `response_writer.lua` - Streaming response rendering
- `tests/` - Test suite (mirrors source structure)
  - `mock.lua` - Mock objects with argument capture
  - `helpers.lua` - Test utilities
- `scripts/minimal_init.lua` - Test initialization script
- `doc/taal.txt` - Vim help documentation

## Running tests

Tests use `mini.test` from `mini.nvim` (stored in `deps/mini.nvim`).

```bash
# Run all tests
nvim --headless -u scripts/minimal_init.lua -c "lua MiniTest.run()"

# Run a single test file
nvim --headless -u scripts/minimal_init.lua -c "lua MiniTest.run_file('tests/test_diff.lua')"
```

## Code formatting

Uses StyLua. Config in `.stylua.toml`: 2-space indent, 100 char line width, double quotes preferred.

```bash
stylua lua/ tests/
```

## Coding conventions

- **Module pattern**: Every file uses `local M = {} ... return M`
- **Naming**: Classes/constructors use PascalCase (e.g., `ResponseWriter`), everything else uses snake_case
- **Dependencies**: `require()` calls at the top of the file
- **Tests**: Files named `test_<module>.lua`, test sets use `T["function_name.scenario"]`
- **Mocking**: Tests use `tests/mock.lua` which tracks function calls via metatable-based argument capture
- **Dependency injection**: `init.lua` wires everything together; `commands.setup()` receives dependencies as arguments rather than requiring them directly
- **No default keybindings**: The plugin exposes user commands (`TaalGrammar`, `TaalHover`, etc.) but leaves keymapping to the user

## Dependencies

- Runtime: `nvim-lua/plenary.nvim` (for curl HTTP client)
- Test: `mini.nvim` (for mini.test framework, in `deps/`)

## Commit messages

Short, lowercase, imperative-style descriptions. No conventional commit prefixes.
