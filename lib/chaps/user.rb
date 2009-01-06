require 'thread'

module Chaps
  class UserSession
    include Utils
    
    class ShutdownSession < Exception; end
    
    def initialize(user, server)
      @user = user
      @server = server
      @user.current_session = self
      @outbound_queue = Queue.new()
      @last_message_by_room = {}
    end
    
    def close
      if @user
        @user.current_session = nil
      end
      
      if @master_thread and @master_thread.alive?
        @master_thread.raise ShutdownSession
        @master_thread.join
      end
    end
    
    def send(message)
      @outbound_queue << message
    end

    def friends
      @user.friends.map{|friend_name| @server.find_user(friend_name) }
    end

    def serve(io)
      @master_thread = Thread.current
      
      t = Thread.new(io) { |outbound_io|
        while m = @outbound_queue.shift
          outbound_io << m
        end
      }

      while(message = Messages.parse(raw_message = io.gets))
        handle_mesage(message)
      end

    rescue ShutdownSession => e
    ensure
      t.terminate rescue nil
      t.join rescue nil
    end

    def handle_mesage(message)
      case message
      when Messages::Inbound::RL
        send Messages::Outbound::RL.for(@server.rooms)
      when Messages::Inbound::UL
        with_error_messages_to(self) do
          room = @server.find_room(message.room_name) or raise Messages::Outbound::Errors::NoSuchRoom
          send Messages::Outbound::UL.for(room.users)
        end        
      when Messages::Inbound::FL
        send Messages::Outbound::FL.for(friends)
      end
    end

    alias << send
  end

  class User
    attr_reader :name, :status
    attr_accessor :current_session
    
    def initialize(name)
      @name = name
      @status = :offline
      @current_session = nil
    end

    def self.friends_for(name)
      ["you have no friends"]
    end
    
    def friends
      self.class.friends_for(name)
    end
    
    def online?
      !@current_session.nil?
    end
  end
end
