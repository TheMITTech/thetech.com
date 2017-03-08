if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.pre_authorize_cb = lambda do |env|
    env['PATH_INFO'] !~ /^\/message-bus/
  end
end