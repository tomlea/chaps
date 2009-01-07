require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class UserStoreTest < TC
  def test_should_persist_friend_list
    with_stubbed_file_store do
      username = "test"
      UserStore.new(username).friends = friends = %w{bob susan zack}
      assert_equal friends, UserStore.new(username).friends
    end
  end

  def test_should_default_to_empty_list
    with_stubbed_file_store do
      username = "test"
      assert_equal [], UserStore.new(username).friends
    end
  end
end
