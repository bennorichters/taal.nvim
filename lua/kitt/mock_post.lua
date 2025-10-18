local stream_data = 'data: {"type":"response.output_text.delta","delta":"%s"}'
local stream_done = 'data: {"type":"response.output_text.done"}'
local response_body = [===[
{
  "id": "0",
  "output": [
    {
      "id": "1",
      "type": "reasoning"
    },
    {
      "id": "2",
      "type": "message",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "en"
        }
      ]
    }
  ]
}
]===]

return function(_, opts)
  if opts.stream then
  for i = 1, 5 do
    opts.stream(nil, string.format(stream_data, i))
  end
  opts.stream(nil, stream_done)
  else
  return {
    status = 200,
    body = response_body,
  }
  end
end
