if Rails.env.test?
  WebMock.allow_net_connect!(net_http_connect_on_start: true, allow_localhost: true)
end