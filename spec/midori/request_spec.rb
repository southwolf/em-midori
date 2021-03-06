require './spec/spec_helper'

RSpec.describe Midori::Request do
  it 'parse request without query_string' do
    data = "GET / HTTP/1.1\r\n\r\n"
    request = Midori::Request.new
    request.parse(data)
    expect(request.protocol).to eq([1, 1])
    expect(request.method).to eq(:GET)
    expect(request.path).to eq('/')
    expect(request.query_string).to eq(nil)
    expect(request.query_params).to eq({})
  end

  it 'parse request with query_string' do
    data = "GET /?test=1 HTTP/1.1\r\n\r\n"
    request = Midori::Request.new
    request.parse(data)
    expect(request.protocol).to eq([1, 1])
    expect(request.method).to eq(:GET)
    expect(request.path).to eq('/')
    expect(request.query_string).to eq('test=1')
    expect(request.query_params['test']).to eq(['1'])
  end

  it 'parse request with cookies' do
    data = "GET /?test=1 HTTP/1.1\r\nCookie: a=1; b=2\r\n\r\n"
    request = Midori::Request.new
    request.parse(data)
    expect(request.protocol).to eq([1, 1])
    expect(request.method).to eq(:GET)
    expect(request.path).to eq('/')
    expect(request.cookie['a'].name).to eq('a')
    expect(request.cookie['a'].value).to eq(['1'])
    expect(request.cookie['b'].value).to eq(['2'])
  end

  it 'parse request with header and body' do
    data = "GET / HTTP/1.1\r\nTest: Hello\r\n\r\nBody"
    request = Midori::Request.new
    request.parse(data)
    expect(request.header['Test']).to eq('Hello')
    expect(request.body).to eq('Body')
  end

  it 'parse request with separated body' do
    data = "GET / HTTP/1.1\r\nContent-Length: 4\r\n\r\n"
    request = Midori::Request.new
    request.parse(data)
    request.parse('Body')
    expect(request.body).to eq('Body')
  end

  it 'parse websocket upgrade' do
    data = "GET / HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
    request = Midori::Request.new
    request.parse(data)
    expect(request.method).to eq(:WEBSOCKET)
  end

  it 'parse eventsource upgrade' do
    data ="GET / HTTP/1.1\r\nAccept: text/event-stream\r\n\r\n"
    request = Midori::Request.new
    request.parse(data)
    expect(request.method).to eq(:EVENTSOURCE)
  end

  it 'parses all methods' do
    methods = %w( delete
                  get
                  head
                  post
                  put
                  options
                  trace
                  copy
                  lock
                  mkcol
                  move
                  propfind
                  proppatch
                  unlock
                  report
                  mkactivity
                  checkout
                  merge
                  m-search
                  notify
                  subscribe
                  unsubscribe
                  link
                  unlink
                  patch
                  purge
                ).freeze
    
    methods.each do |method|
      request = Midori::Request.new
      data = "#{method.upcase} / HTTP/1.1\r\n\r\n"
      request.parse(data)
      expect(request.method).to eq(method.upcase.to_sym)
    end
  end
end
