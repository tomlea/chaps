require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class AuthenticationTest < TC
  def test_should_authenticate_client
    server = with_authenticating_server do |server, client_factory|
      client_sock = client_factory.connect
      client_sock.puts "A0test"
      message = client_sock.gets
      assert_match /A0(.{50})/, message
      salt = message[/.{50}$/]
      digest = Digest::MD5.hexdigest(salt + "test")
      client_sock.puts "A1#{digest}"
      assert_match "A1U", client_sock.gets
      assert_has_users 1, server
    end
  end
  
  def test_should_fail_auth
    server = with_authenticating_server do |server, client_factory|
      client_sock = client_factory.connect
      client_sock.puts "A0test"
      message = client_sock.gets
      assert_match /A0(.{50})/, message
      salt = message[/.{50}$/]
      digest = Digest::MD5.hexdigest(salt + "bad_password")
      client_sock.puts "A1#{digest}"
      assert_match "ER002", client_sock.gets
      assert_has_users 0, server
    end
  end
  
  def test_should_return_bad_user
    server = with_authenticating_server do |server, client_factory|
      client_sock = client_factory.connect
      client_sock.puts "A0bad_username"        
      assert_match /A0(.{50})/, message = client_sock.gets
      salt = message[/.{50}$/]
      digest = Digest::MD5.hexdigest(salt + "bad_password")
      client_sock.puts "A1#{digest}"
      assert_match "ER000", client_sock.gets, "Expected bad username."
      assert_has_users 0, server
    end    
  end
end
