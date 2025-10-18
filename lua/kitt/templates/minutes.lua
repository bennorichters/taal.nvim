return {
  model = "gpt-5-nano",
  input = {
    {
      role = "system",
      content = "From the notes you receive write a coherent summary.",
    },
    {
      role = "user",
      content = "%s",
    },
  },
}
