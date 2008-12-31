module Chaps
  module Utils
    def expect(io, klass_name)
      message = Messages.parse(io.gets)
      raise Exception, "Expected a #{klass_name}, got a #{message.class.name}" unless message.is_a? Messages::Inbound.const_get(klass_name)
      message
    end

    def with_error_messages_to(io)
      yield
    rescue Messages::Outbound::ER => er
      io << er
      false
    end
    
    extend self
  end
end