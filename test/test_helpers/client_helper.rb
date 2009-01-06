class Chaps::ClientHelper
  KERNEL_METHODS = [:puts, :gets]
  def room_list
    puts "RL"
  end

  def user_list(room)
    puts "UL#{room}"
  end

  def friend_list
    puts "FL"
  end

  def initialize(io)
    @io = io
  end

  def method_missing(method, *args)
    @io.__send__(method, *args)
  end

  KERNEL_METHODS.each do |method|
    define_method method do |*args|
      method_missing(method, *args)
    end
  end
end
