require 'gserver'
require 'yaml'
require 'digest/md5'
require 'chaps/utils'
module Chaps
  class Server < GServer
    include Utils
    attr_reader :rooms
    def initialize(port=4500, *args)
      super(port, *args)
      @rooms = [Room.new("Hall")]
      @users = []
    end
    
    def serve(io)
      with_error_messages_to(io) do
        return unless user = authenticate(io)
        @users << user
        user.serve(io)
      end
    rescue => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      raise
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
      message = expect(io, :A0)
      io << Messages::Outbound::A0.new(salt = "a"*50)      
      
      username = message.username
      password = password_for(username) or raise Messages::Outbound::Errors::BadUsername

      raise Messages::Outbound::Errors::BadPassword unless expect(io, :A1).md5 == Digest::MD5.hexdigest(salt + password)
      io << Messages::Outbound::A1.new
      return User.new(username, self)
    end
    
    def password_for(username)
      return "test" if username == "test"
      YAML.load(File.read("auth.yml"))[username] rescue nil
    end    
  end
end
