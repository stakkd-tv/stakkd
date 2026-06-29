Typesense.configuration = {
  nodes: [{
    host: ENV["TYPESENSE_HOST"],
    port: ENV["TYPESENSE_PORT"],
    protocol: ENV["TYPESENSE_PROTOCOL"]
  }],
  api_key: ENV["TYPESENSE_API_KEY"],
  connection_timeout_seconds: 2,
  log_level: :info,
  pagination_backend: :will_paginate
}
