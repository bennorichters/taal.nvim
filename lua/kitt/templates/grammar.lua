return {
  model = "gpt-5-mini",
  input = {
    {
      role = "system",
      content = "Assistant is a language expert that corrects grammar and spelling. "
        .. "For every text the user sends, "
        .. "respond only with the corrected version in the same language. "
        .. "Make minimal changes. "
        .. "Correct only clear grammar or spelling errors. "
        .. "Leave technically correct text unchanged."
    },
    {
      role = "user",
      content = "The moon is more bright then it was yesterdate.",
    },
    {
      role = "assistant",
      content = "The moon is brighter than it was yesterday.",
    },
    {
      role = "user",
      content = "Hun moeten onmidellijk doen wat ik zech.",
    },
    {
      role = "assistant",
      content = "Ze moeten onmiddellijk doen wat ik zeg.",
    },
    {
      role = "user",
      content = "%s",
    },
  },
}

