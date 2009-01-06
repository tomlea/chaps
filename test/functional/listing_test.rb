require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RoomListTest < TC
  def test_should_list_rooms
    with_client do |server, client|
      server.stubs(:rooms).returns([Room.new("A"), Room.new("B")])
      client.room_list
      assert_equal "RL000002000\tA\n", client.gets
      assert_equal "RL001002000\tB\n", client.gets
    end
  end
end

class UserListTest < TC
  def test_should_report_no_such_room
    with_client do |server, client|    
      server.stubs(:rooms).returns([])
      client.user_list("foo")
      assert_equal "ER004\n", client.gets
    end
  end

  def test_room_listing_errors_should_not_be_fatal
    with_client do |server, client|    
      server.stubs(:rooms).returns([])
      client.user_list("foo")
      client.user_list("foo")
      assert_equal "ER004\n", client.gets
      assert_equal "ER004\n", client.gets
    end
  end
  
  def test_should_list_users_in_rooms
    with_client do |server, client|    
      server.stubs(:rooms).returns([room = Room.new("MyRoom")])
      room.stubs(:users).returns([stub(:name => "A"), stub(:name => "B")])
      client.user_list("MyRoom")
      assert_equal "UL000002\tA\n", client.gets
      assert_equal "UL001002\tB\n", client.gets
    end
  end
end
