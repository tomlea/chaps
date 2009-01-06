require 'gserver'
require 'yaml'
require 'digest/md5'
require 'chaps/utils'
require 'chaps/logging_io'

module Chaps
  class Server < GServer
    include Utils
    attr_reader :rooms, :users
    def initialize(port=4500, *args)
      super(port, *args)
      @rooms = [Room.new("Hall")]
      @users = []
    end

    def serve(io)
      handle_session(io)
    rescue Errno::EPIPE
      log "Client quit"
    rescue Object => e
      return if e.message == "stop"
      log "#{e.class}: #{e.message}"
      log e.backtrace
    ensure
      io.close unless io.closed?
    end

    def handle_session(io)
      io = LoggingIO.new(io, audit)
      with_error_messages_to(io) do
        if user = authenticate(io)
          begin
            @users.push user
            user.serve(io)
          ensure
            @users.delete(user)
          end
        end
      end
    end

    def user_list(room_name, io)
      with_error_messages_to(io) do
        room = rooms.find{|r| r.name == room_name} or raise Messages::Outbound::Errors::NoSuchRoom
        io << Messages::Outbound::UL.for(room.users)
      end
    end

    def room_list(io)
      io << Messages::Outbound::RL.for(rooms)
    end

    def authenticate(io)
      a0 = expect(io, :A0)
      io << Messages::Outbound::A0.new(salt = "a"*50)      

      password = password_for(a0.username)
      a1 = expect(io, :A1)
      
      raise Messages::Outbound::Errors::BadUsername unless password
      unless a1.md5 == Digest::MD5.hexdigest(salt + password) or a1.md5 == Digest::MD5.hexdigest(salt + Digest::MD5.hexdigest(password))
        raise Messages::Outbound::Errors::BadPassword
      end
      
      io << Messages::Outbound::A1.new
      
      return User.new(a0.username, self)
    end
    
    def password_for(username)
      return "test" if username == "test"
      YAML.load(File.read("auth.yml"))[username] rescue nil
    end
  end
end
