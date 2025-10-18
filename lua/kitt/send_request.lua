return function(post, endpoint, api_key)
  return function(body_content, extra_opts)
    local opts = {
      body = body_content,
      headers = {
        content_type = "application/json",
        authorization = "Bearer " .. api_key,
      },
    }

    if extra_opts then
      opts = vim.tbl_deep_extend("error", opts, extra_opts)
    end

    return post(endpoint, opts)
  end
end
