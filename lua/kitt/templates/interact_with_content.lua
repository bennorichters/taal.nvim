return {
  model = "gpt-5",
  input = {
    {
      role = "system",
      content = "Format your response in markdown. %s",
    },
    {
      role = "user",
      content = "%s",
    },
  },
}
