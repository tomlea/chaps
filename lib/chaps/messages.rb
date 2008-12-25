module Chaps
  module Messages
    def self.parse(message)
      message =~ /^(..)(.*)$/
      code, message = $1, $2
      if Inbound.const_defined? code
        Inbound.const_get(code).new(message)
      else
        raise Exception, "Invalid Message Received"
      end
    end

    module Inbound
      class A0
        attr_reader :username, :client, :protocol_version
        def initialize(message)
          if matches = message.match(/^..([^\t]+)(?:\t(.*)([0-9]))?$/)
            _, @username, @client, @protocol_version = matches.to_a
            @protocol_version = @protocol_version.to_i
          else
            raise Exception, "Bad Message"
          end
        end
      end

      class A1
        attr_reader :md5
        def initialize(message)
          if matches = message.match(/^..([a-z0-9]{32})$/)
            _, @md5 = matches.to_a
          else
            raise Exception, "Bad Message"
          end
        end
      end
    end
  end
end