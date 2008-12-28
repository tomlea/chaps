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
    
    module Outbound
      class A0
        attr_reader :random_data
        def initialize(random_data)
          @random_data = random_data
          raise Exception, "Random Data Should be 50 Chars" unless @random_data.length == 50
        end
        
        def to_s
          "A0#{@random_data}\n"
        end
      end

      class A1
        def to_s
          "A1U\n"
        end
      end
      
      class ER
        def initialize(code)
          @code = code
        end
        
        def to_s
          "ER#{@code}\n"
        end
      end
      
      class RL
        def initialize(room, room_count, room_index)
          @room, @room_count, @room_index = room, room_count, room_index
        end
        
        def to_s
          "RL%03X%03X%03X\t%s\n" % [@room_index, @room_count, @room.users.size, @room.name]
        end
      end
      
      class UL
        def initialize(user, count, index)
          @user, @count, @index = user, count, index
        end
        
        def to_s
          "UL%03X%03X\t%s\n" % [@index, @count, @user.name]
        end
      end
      
      
      module Errors
        BadUsername = ER.new("000")
        BadPassword = ER.new("002")
        NoSuchRoom =  ER.new("004")
      end
    end
    
    module Inbound
      class A0
        attr_reader :username, :client, :protocol_version
        def initialize(message)
          if matches = message.match(/^([^\t]+)(?:\t(.*)([0-9]))?$/)
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
          if matches = message.match(/^([a-f0-9]{32})$/)
            _, @md5 = matches.to_a
          else
            raise Exception, "Bad Message"
          end
        end
      end
      
      class RL
        def initialize(message)
        end
      end
      
      class UL
        attr_reader :room_name
        def initialize(message)
          if matches = message.match(/^(.+)$/)
            _, @room_name = matches.to_a
          else
            raise Exception, "Bad Message"
          end
        end
      end
    end
  end
end