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
      class ListItem
        attr_reader :item
        def initialize(index, total, item = nil)
          @index, @total, @item = index, total, item
        end
        
        def message_name
          self.class.name.split("::").last
        end
        
        def to_s
          "%s%03X%03X%s\n" % [message_name, @index, @total, payload]
        end
        
        def self.for(items)
          rv = []
          items.each_with_index do |item, index|
            rv << new(index, items.size, item)
          end
          rv
        end
      end
            
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
      
      class RL < ListItem
        alias room item
        def payload
          "%03X\t%s" % [room.users.size, room.name]
        end
      end
      
      class UL < ListItem
        alias user item  
        def payload
          "\t%s" % [user.name]
        end
      end
      
      
      module Errors
        BadUsername = ER.new("000")
        BadPassword = ER.new("002")
        NoSuchRoom =  ER.new("004")
      end
    end
    
    module Inbound
      class Simple
        attr_reader :data
        def initialize(data)
          self.class.validate(data)
          @data = data
        end
        
        def self.regexp
          @regexp || superclass.respond_to?(:regexp) && superclass.regexp
        end
        
        def self.validate(data)
          if regexp
            regexp.match(data) or raise Exception, "Bad Message"
          end
        end
        
        def self.default_method(regexp)
          klass = Class.new(self)
          klass.send(:instance_variable_set, :@regexp, regexp)
          klass
        end
      end
      
      def self.Simple(regexp = nil)
        if regexp
          Simple.default_method(regexp)
        else
          Simple
        end
      end
            
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

      class A1 < Simple(/^([a-f0-9]{32})$/)
        alias md5 data
      end
      
      class RL < Simple
      end

      class FL < Simple
      end
      
      class UL < Simple(/.+/)
        alias room_name data
      end
    end
  end
end