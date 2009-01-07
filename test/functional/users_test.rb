require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class UserManagmentTest < TC
  def test_server_should_remove_logged_off_users
    with_authenticating_server do |server, connection_factory|
      connection_factory.connect do |io|
        authenticate(io, "test")
        assert_has_users 1, server
      end
      
      assert_has_users 0, server
      
      connection_factory.connect do |io|
        authenticate(io, "test2")
        assert_has_users 1, server
      end      
    end
  end

  def test_server_should_clean_up_double_logins
    with_authenticating_server do |server, connection_factory|
      connection_factory.connect do |io|
        authenticate(io, "test")
        connection_factory.connect do |io2|
          authenticate(io2, "test")
          assert_has_users 1, server
          assert io.eof?, "Expected socket to have been closed"
        end
        assert_has_users 0, server
      end
    end
  end
end

class FreindListingTest < TC
  def test_friend_listing
    User.stubs(:friends_for).with("test").returns(["test2"])
    with_client(:username => "test") do |server, client|
      client.friend_list
      assert_match /FL000001\ttest2\tU0Offline\tUsers/, client.gets
    end
  end
  
  def test_should_show_online_friends
    User.stubs(:friends_for).with("test").returns(["test2"])
    User.stubs(:friends_for).with("test2").returns(["test"])
    with_authenticating_server do |server, connection_factory|
      connection_factory.connect do |test_io|
        authenticate(test_io, "test")
        connection_factory.connect do |test2_io|
          authenticate(test2_io, "test2")
          test2_io.puts "FL"
          assert_match /FL000001\ttest\tU1Online\tUsers/, test2_io.gets
        end
      end      
    end
  end
end
