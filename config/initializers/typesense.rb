Typesense.configuration = {
  nodes: [{
    host: AppConfig::TYPESENSE_HOST,
    port: AppConfig::TYPESENSE_PORT,
    protocol: AppConfig::TYPESENSE_PROTOCOL
  }],
  api_key: AppConfig::TYPESENSE_API_KEY,
  connection_timeout_seconds: 2,
  log_level: :info,
  pagination_backend: :will_paginate
}
