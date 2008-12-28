require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class MessageParsingTest < TC
  class StubMessage
    def initialize(message)
    end
  end

  def teardown
    Chaps::Messages::Inbound.send(:remove_const, :DE) if defined? Chaps::Messages::Inbound::DE
  end
  
  def test_should_raise_for_invalid_message
    assert_raise(Exception) { Chaps::Messages.parse("NOtdefined") }
  end

  def test_not_should_raise_for_valid_message
    Chaps::Messages::Inbound.const_set(:DE, StubMessage)
    assert_nothing_raised { Chaps::Messages.parse("DEfined") }
  end
  
  def test_should_return_new_message
    Chaps::Messages::Inbound.const_set(:DE, StubMessage)
    actual = Chaps::Messages.parse("DEfined")
    assert_instance_of StubMessage, actual
  end
end

class A0MessageTest < TC
  def test_should_parse_complete_A0_message
    a0 = Chaps::Messages::Inbound::A0.new("bob\tfoooo4")
    assert_equal "bob", a0.username
    assert_equal "foooo", a0.client
    assert_equal 4, a0.protocol_version
  end

  def test_should_parse_legacy_A0_message
    a0 = Chaps::Messages::Inbound::A0.new("bob")
    assert_equal "bob", a0.username
    assert_nil a0.client
    assert_equal 0, a0.protocol_version
  end
  def test_should_bail_on_bad_message
    assert_raise(Exception) { Chaps::Messages::Inbound::A0.new("") }
    assert_raise(Exception) { Chaps::Messages::Inbound::A0.new("foo\tbar") }
  end
end

class A1MessageTest < TC
  def test_should_parse_A1_message
    a1 = Chaps::Messages::Inbound::A1.new("b6e2b3fd6097b32cb6768a81fb611811")
    assert_equal "b6e2b3fd6097b32cb6768a81fb611811", a1.md5
  end
  
  def test_should_bail_on_bad_message
    assert_raise(Exception) { Chaps::Messages::Inbound::A1.new("") }
    assert_raise(Exception) { Chaps::Messages::Inbound::A1.new("foo") }
    assert_raise(Exception) { Chaps::Messages::Inbound::A1.new("b6e2b3fd6097b32cb6768a81fb61181K") }
  end
end

