require File.join(File.dirname(__FILE__), *%w[.. test_helper])

Thread.abort_on_exception=true

class UserManagmentTest < TC
  def test_server_should_remove_logged_off_users
    with_authenticating_server do |server, connection_factory|
      connection_factory.connect do |io|
        authenticate(io, "test")
        assert_equal 1, server.users.size, "Server should only have one users right now."
      end
      
      sleep 0.1 # let the server track the dropped connection.
      assert_equal 0, server.users.size
      
      connection_factory.connect do |io|
        authenticate(io, "test2")
        assert_equal 1, server.users.size, "Server should only have one users right now."
      end      
    end
  end

  # def test_server_should_not_remove_unrelated_instances_of_the_same_user
  #   flunk("TODO")
  # end
end
