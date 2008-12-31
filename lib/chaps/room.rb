module Chaps
  class Room
    attr_reader :name, :users, :last_message
    def initialize(name)
      @name = name
      @users = []
      @last_message = nil
    end
    
    def <<(message)
      last_message.next_message = message
      @last_message = message
      @users.each do |user|
        user.new_message_in(self)
      end
    end
    
    def each_messages_since(last_known)
      m = last_known
      while m and m != last_known
        m = m.next_message
        yield if m
      end
    end
  end
end