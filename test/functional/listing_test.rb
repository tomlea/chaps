require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RoomListTest < TC
  def test_should_list_rooms
    @server = Server.new
    @server.stubs(:rooms).returns([Room.new("A"), Room.new("B")])
    io = StringIO.new("")
    @server.room_list(io)
    io.rewind
    
    assert_equal "RL000002000\tA\n", io.gets
    assert_equal "RL001002000\tB\n", io.gets
  end
end

class UserListTest < TC
  def test_should_report_no_such_room
    @server = Server.new
    @server.stubs(:rooms).returns([])
    io = StringIO.new("")
    with_error_messages_to(io){
      @server.user_list("foo", io)
    }
    io.rewind
    
    assert_equal "ER004\n", io.gets
  end
  
  def test_should_list_users_in_rooms
    @server = Server.new
    @server.stubs(:rooms).returns([room = Room.new("MyRoom")])
    room.stubs(:users).returns([stub(:name => "A"), stub(:name => "B")])
    io = StringIO.new("")
    @server.user_list("MyRoom", io)
    io.rewind
    
    assert_equal "UL000002\tA\n", io.gets
    assert_equal "UL001002\tB\n", io.gets
  end
end
