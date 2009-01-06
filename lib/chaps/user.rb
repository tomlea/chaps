require 'thread'

module Chaps
  class User
    attr_reader :name
    def initialize(name, server)
      @name, @server = name, server
      @outbound_queue = Queue.new()
      @last_message_by_room = {}
    end
    
    def send(message)
      @outbound_queue << message
    end
    
    alias << send
    
    def new_message_in(room)
      messages = []
      room.each_messages_since(@last_message_by_room[room]) do |message|
        send message
      end
    end
    
    def friends
      self.class.friends_for(name).inject({}){|collection, friend_name| 
        collection.merge( friend_name => @server.find_user(friend_name) || :offline )
      }
    end
    
    def self.friends_for(name)
      %w{you have no friends}
    end
    
    def serve(io)
      t = Thread.new(io) { |outbound_io|
        while m = @outbound_queue.shift
          outbound_io << m
        end
      }
      
      while(message = Messages.parse(raw_message = io.gets))
        case message
        when Messages::Inbound::RL
          @server.room_list(self)
        when Messages::Inbound::UL
          @server.user_list(message.room_name, self)
        when Messages::Inbound::FL
          self << Messages::Outbound::FL.for(friends)
        else
          raise Exception, "Bad message: #{raw_message.inspect}"
        end
      end
    ensure
      t.terminate rescue nil
      t.join rescue nil
    end
  end
end