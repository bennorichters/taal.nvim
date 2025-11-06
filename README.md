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

Using [Mini.Deps](https://nvim-mini.org/mini.nvim/readmes/mini-deps):

```lua
MiniDeps.later(function()
  MiniDeps.add {
    source = "bennorichters/taal.nvim",
    depends = { "nvim-lua/plenary.nvim" },
  }

  require("taal").setup {}
end)
```

