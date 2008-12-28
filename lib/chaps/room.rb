module Chaps
  class Room
    attr_reader :name, :users
    def initialize(name)
      @name = name
      @users = []
      @last_message = nil
    end
    
    def <<(message)
      message.last_message = @last_message
      @last_message = message
      @users.each do |user|
        user.new_message_in(self)
      end
    end
  end
end