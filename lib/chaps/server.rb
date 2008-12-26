require 'gserver'
module Chaps
  class Server < GServer
    def initialize(port=10001, *args)
      super(port, *args)
    end
    def serve(io)
      message = Messages.parse(io.gets)
      raise "Expected A0" unless message.is_a? Messages::Inbound::A0
      response = Messages::Outbound::A0.new("a"*50)
      io << response
    end
  end
end