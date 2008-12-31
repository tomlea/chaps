require 'gserver'
require 'yaml'
require 'digest/md5'

module Chaps
  class Server < GServer
    attr_reader :rooms
    def initialize(port=10001, *args)
      super(port, *args)
      @rooms = [Room.new("Hall")]
      @users = []
    end
    
    def serve(io)
      return unless user = authenticate(io)
      @users << user
      user.serve(io)
    rescue => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      raise
    end
    
    def user_list(room_name, io)
      error = Proc.new{|m| io << m; return false}
      room = rooms.find{|r| r.name == room_name} or error.call(Messages::Outbound::Errors::NoSuchRoom)
      io << Messages::Outbound::UL.for(room.users)
    end
    
    def room_list(io)
      io << Messages::Outbound::RL.for(rooms)
    end
    
    def authenticate(io)
      error = Proc.new{|m| io << m; return false}
      message = expect(io, :A0)
      io << Messages::Outbound::A0.new(salt = "a"*50)      
      
      username = message.username
      password = password_for(username) or error.call(Messages::Outbound::Errors::BadUsername)

      error.call(Messages::Outbound::Errors::BadPassword) unless expect(io, :A1).md5 == Digest::MD5.hexdigest(salt + password)
      io << Messages::Outbound::A1.new
      return User.new(username, self)
    end
    
    def password_for(username)
      return "test" if username == "test"
      YAML.load(File.read("auth.yml"))[username] rescue nil
    end
    
    def expect(io, klass_name)
      message = Messages.parse(io.gets)
      raise Exception, "Expected a #{klass_name}, got a #{message.class.name}" unless message.is_a? Messages::Inbound.const_get(klass_name)
      message
    end
  end
end
