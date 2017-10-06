
##
# HTTPS Server
class Midori::SSL
  attr_reader :server
  
  def initialize(bind, port, ssl_key, ssl_cert)
    ssl_ctx = OpenSSL::SSL::SSLContext.new
    ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    ssl_ctx.key = OpenSSL::PKey::RSA.new(File.open(ssl_key))
    ssl_ctx.cert = OpenSSL::X509::Certificate.new(File.open(ssl_cert))
    tcp_server = TCPServer.new(bind, port)
    @ssl_server = OpenSSL::SSL::SSLServer.new(tcp_server, ssl_ctx)
  end

  # Get File Descriptor of the TCPServer
  # @return [Integer] file descriptor
  def to_i
    @server.to_i
  end

  # Get TCPServer of the SSL Server
  # @return [TCPServer] the TCPServer
  def server
    @ssl_server.to_io
  end
end  