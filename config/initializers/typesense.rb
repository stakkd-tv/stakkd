Typesense.configuration = {
  nodes: [{
    host: "localhost",
    port: "8108",
    protocol: "http"
  }],
  api_key: ENV["TYPESENSE_API_KEY"],
  connection_timeout_seconds: 2,
  log_level: :info,
  pagination_backend: :will_paginate
}
