require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RLTest < TC
  def test_should_format_a_room_list_item_correctly
    room = stub()
    room.stubs(:name).returns("test")
    room.stubs(:users).returns([])
    
    rl = Chaps::Messages::Outbound::RL.new(2, 3, room)
    assert_equal "RL002003000\ttest\n", rl.to_s

    room.stubs(:users).returns([nil]*10)
    rl = Chaps::Messages::Outbound::RL.new(10, 10, room)
    assert_equal "RL00A00A00A\ttest\n", rl.to_s
  end
end

class ULTest < TC
  def test_should_format_a_user_list_item_correctly
    user = stub()
    user.stubs(:name).returns("test")
    
    ul = Chaps::Messages::Outbound::UL.new(2, 3, user)
    assert_equal "UL002003\ttest\n", ul.to_s
  end
end