require File.join(File.dirname(__FILE__), *%w[.. test_helper])

Thread.abort_on_exception=true

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

  def test_server_should_not_remove_unrelated_instances_of_the_same_user
    with_authenticating_server do |server, connection_factory|
      connection_factory.connect do |io|
        authenticate(io, "test")
        connection_factory.connect do |io2|
          authenticate(io2, "test")
          assert_has_users 2, server
        end      
        assert_has_users 1, server
      end      
    end
  end
end
