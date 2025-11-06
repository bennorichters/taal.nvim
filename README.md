# Taal

A Neovim plugin that uses LLMs to improve the grammar and spelling of natural language text.

## Features

- Suggests grammar and spelling improvements. This feature is language agnostic, as long as the chosen LLM is capable of that.

- Offers a word-by-word diff of the original text and the suggested improvements.

- Applies improvements all at once, or on a one-to-one basis.

- Recognizes the language the text is written in and sets the correct `spelllang` option.
  
- Interacts with the LLM using a user command and the selected text.

- Supports three LLMs: Claude, Ollama, OpenAI-responses.

## Installation

This plugin uses `curl` and for that it depends on [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

<details>
<summary>Example using <a href="https://nvim-mini.org/mini.nvim/readmes/mini-deps">mini.deps</a></summary>

```lua
MiniDeps.later(function()
  MiniDeps.add {
    source = "bennorichters/taal.nvim",
    depends = { "nvim-lua/plenary.nvim" },
  }

  require("taal").setup {}
end)
```
</details>

### API keys

Three LLM's are supported. Ollama, the default choice, does not need an API key. The other two (Claude and OpenAI-responses) do need a key. These keys should be made available via an environment variable:

- Claude: `{{CLAUDE_API_KEY}}`
- OpenAI_responses: `{{OPENAI_API_KEY}}`

If you want to use Claude or OpenAI_responses, do not forget to configure the plugin accordingly, see below.

## Usage

This module needs to be set up with `require('taal').setup({})`. The setup arg `{}` is optional and can be a custom config table, to overwrite the defaults. Calling the setup function, with or without a table, is mandatory.

### Config options

The config supports these fields:
- log_level: string - ["trace", "info", "debug", "error"] - default: "error"
- timeout: number - timeout for LLM requests in ms - default: 6000
  (six-thousand, i.e., six seconds)
- adapters: table:
  {
    {[LLM] = {endpoint = endpoint to be used by this LLM},
    {[LLM] = {endpoint = ...}},
  }
- adapter: string - default adapter for every LLM call - default: ollama
- model: string - default model for every LLM call - default: gemma3
- commands: table:
  {
    [command_name]: string - ["improve_grammar", "suggest_grammar", "set_spellang",
    "interact"] = { adapter = ["claude", "ollama", "openai_responses"], model
    = "[chosen model]"}
  }

### Default config

<details>
<summary>default config</summary>
The default config is:
```lua
  {
    log_level = "error",
    timeout = 6000,

    adapters = {
      claude = {
	endpoint = "https://api.anthropic.com/v1/messages",
      },
      ollama = {
	endpoint = "http://localhost:11434/api/chat",
      },
      openai_responses = {
	endpoint = "https://api.openai.com/v1/responses",
      },
    },

    adapter = "ollama",
    model = "gemma3",

    commands = {
      improve_grammar = {
	adapter = nil,
	model = nil,
      },
      suggest_grammar = {
	adapter = nil,
	model = nil,
      },
      set_spellang = {
	adapter = nil,
	model = nil,
      },
      interact = {
	adapter = nil,
	model = nil,
      },
    },
  }
```
</details>

### Example config

This example uses Ollama and the model gemma3 as the default LLM (because it is not changed), except for the interact command. For that command it will use Claude with the model claude-sonnet-4-5-20250929.
```lua
  { 
    commands = {
      interact = { 
	adapter="claude", model="claude-sonnet-4-5-20250929", 
      }
    }
  }
```

