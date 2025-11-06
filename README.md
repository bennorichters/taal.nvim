# Taal

A Neovim plugin that uses LLMs to improve the grammar and spelling of natural language text.

## Features

- Suggests grammar and spelling improvements. This feature is language agnostic, as long as the chosen LLM is capable of that.

- View a word-by-word diff of the original text and the suggested improvements.

- Apply improvements all at once, or on a one-to-one basis.

- Recognizes the language the text is written in and sets the correct `spelllang` option.
  
- Interact with the LLM using the selected text.

- Supports three LLMs: Claude, Ollama, OpenAI-responses

## Installation

This plugin uses `curl` and for that it depends on [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

Example using [Mini.Deps](https://nvim-mini.org/mini.nvim/readmes/mini-deps):

```lua
MiniDeps.later(function()
  MiniDeps.add {
    source = "bennorichters/taal.nvim",
    depends = { "nvim-lua/plenary.nvim" },
  }

  require("taal").setup {}
end)
```

### API keys

Three LLM's are supported. Two of them (Claude and OpenAI-responses) need an API key. These keys should be made available via an environment variable:

- Claude: `{{CLAUDE_API_KEY}}`
- OpenAI_responses: `{{OPENAI_API_KEY}}`

## Usage

...
