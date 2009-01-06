class ConnectionFactory
  def initialize(port, host = "127.0.0.1")
    @port, @host = port, host
    @sockets = []
  end

  def self.for(*params, &block)
    factory = new(*params)
    yield factory
  ensure
    factory.clean_up!
  end

  def new_client
    TCPSocket.new(@host, @port)
  end

  def connect(&block)
    sock = new_client
    if block_given?
      begin
        yield sock
      ensure
        sock.close
      end
    else
      @sockets << sock
      sock
    end
  end

  def clean_up!
    @sockets.each do |sock|
      sock.close unless sock.closed?
    end
  end
end
