require File.join(File.dirname(__FILE__), *%w[.. test_helper])

require "timeout"

class AuthenticationTest < TC
  def test_should_authenticate_client
    result = with_authenticating_server do |client_sock|
      client_sock.puts "A0test"
      message = client_sock.gets
      assert_match /A0(.{50})/, message
      salt = message[/.{50}$/]
      digest = Digest::MD5.hexdigest(salt + "test")
      client_sock.puts "A1#{digest}"
      assert_equal "A1U", client_sock.gets.chomp
    end
    
    assert_equal result, 0, "authenticate should have returned true."    
  end
  
  def test_should_fail_auth
    result = with_authenticating_server do |client_sock|
      client_sock.puts "A0test"
      message = client_sock.gets
      assert_match /A0(.{50})/, message
      salt = message[/.{50}$/]
      digest = Digest::MD5.hexdigest(salt + "bad_password")
      client_sock.puts "A1#{digest}"
      assert_equal "ER002", client_sock.gets.chomp
    end
    
    assert_equal result, 1, "authenticate should have returned false."    
  end
  
  def test_should_return_bad_user
    result = with_authenticating_server do |client_sock|
      client_sock.puts "A0bad_username"        
      message = client_sock.gets
      assert_match /A0(.{50})/, message
      salt = message[/.{50}$/]
      digest = Digest::MD5.hexdigest(salt + "bad_password")
      client_sock.puts "A1#{digest}"
      assert_equal "ER000", client_sock.gets.chomp, "Expected bad username."
    end
    
    assert_equal result, 1, "authenticate should have returned false."    
  end

protected
  def with_authenticating_server
    server = Chaps::Server.new
    client_sock, server_sock = Socket.socketpair(Socket::PF_UNIX, Socket::SOCK_STREAM, 0)

    server.stubs(:password_for).returns(nil)
    server.stubs(:password_for).with("test").returns("test")

    pid = fork{
      Timeout::timeout(2){
        exit 1 unless server.authenticate(server_sock)
      }
    }
    
    yield client_sock
    Process.wait
    
    return $?.exitstatus
  ensure
    begin
      Process.kill("TERM", pid)
      Process.wait
    rescue
    end    
  end
end
