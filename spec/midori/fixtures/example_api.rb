class ExampleConfigure < Midori::Configure
  set :logger, Logger.new(StringIO.new)
  set :bind, '127.0.0.1'
  set :port, 8080
end

class ExampleSSLConfigure < Midori::Configure
  set :logger, Logger.new(StringIO.new)
  set :bind, '127.0.0.1'
  set :port, 8443
  set :secure, true
  set :ssl_key, 'spec/midori/fixtures/files/ssl/key.pem'
  set :ssl_cert, 'spec/midori/fixtures/files/ssl/cert.pem'
end

class User < Midori::API
  get '/' do
    'User'
  end
end

class ExampleMiddleware < Midori::Middleware
  helper :test_helper_inside_middleware do
    'Hello World'
  end
end

class ExampleAPI < Midori::API
  helper :test_helper do
    'Hello World'
  end

  mount '/user', User
  use ExampleMiddleware

  filter ExampleMiddleware
  get '/' do
    return test_helper
  end

  get '/2' do
    test_helper_inside_middleware
  end

  get '/error' do
    raise StandardError
  end

  get '/large' do
    'w' * 2 * 20
  end

  get '/stop' do
    EXAMPLE_RUNNER.stop
  end

  define_error :test_error
  capture TestError do |_e|
    'Hello Error'
  end

  get '/test_error' do
    raise TestError
  end

  websocket '/websocket' do |ws|
    ws.on :open do
      ws.send 'Hello'
    end

    ws.on :message do |msg|
      ws.send msg
    end

    ws.on :pong do
      ws.send ''
    end

    ws.on :close do
    end
  end

  websocket '/websocket/opcode' do |ws|
    ws.on :open do
      ws.send Object.new
    end
  end

  websocket '/websocket/ping' do |ws|
    ws.on :open do
      ws.ping ''
    end
  end

  websocket '/websocket/too_large_ping' do |ws|
    ws.on :message do
      ws.ping '01234567890123456789012345678901
      23456789012345678901234567890123456789012
      34567890123456789012345678901234567890123
      45678901234567890123456789012345678901234
      56789012345678901234567890123456789012345
      67890123456789012345678901234567890123456
      78901234567890123456789012345678901234567
      89012345678901234567890123456789012345678
      90123456789012345678901234567890123456789
      012345678901234567890123456789'
    end
  end

  websocket '/websocket/wrong_opcode' do |ws|;end

  eventsource '/eventsource' do |es|
    es.send("Hello\nWorld")
  end
end

EXAMPLE_API_ENGINE = Midori::APIEngine.new(ExampleAPI)
EXAMPLE_RUNNER = Midori::Runner.new(EXAMPLE_API_ENGINE, ExampleConfigure)
EXAMPLE_SSL_RUNNER = Midori::Runner.new(EXAMPLE_API_ENGINE, ExampleSSLConfigure)