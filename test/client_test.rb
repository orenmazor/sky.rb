# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  def setup
    @client = SkyDB::Client.new(host:'127.0.0.1', port:9000)
    @message = mock('message')
  end
  
  ######################################
  # Send
  ######################################

  def test_send_message
    socket = StringIO.new("\xa3foo")
    TCPSocket.expects(:new).with('127.0.0.1', 9000).returns(socket)
    @message.expects(:encode).with(socket)
    @message.expects(:process_response).with("foo").returns("bar")
    assert_equal 'bar', @client.send_message(@message)
  end


  ######################################
  # Action Messages
  ######################################

  def test_aadd
    action = SkyDB::Action.new
    @client.expects(:send_message).with(is_a(SkyDB::Message::AADD))
    @client.aadd action
  end

  def test_aget
    @client.expects(:send_message).with(is_a(SkyDB::Message::AGET))
    @client.aget 12
  end

  def test_aall
    @client.expects(:send_message).with(is_a(SkyDB::Message::AALL))
    @client.aall
  end


  ######################################
  # Property Messages
  ######################################

  def test_padd
    property = SkyDB::Property.new
    @client.expects(:send_message).with(is_a(SkyDB::Message::PADD))
    @client.padd property
  end

  def test_aget
    @client.expects(:send_message).with(is_a(SkyDB::Message::PGET))
    @client.pget 12
  end

  def test_aall
    @client.expects(:send_message).with(is_a(SkyDB::Message::PALL))
    @client.pall
  end


  ######################################
  # Event Messages
  ######################################

  def test_eadd
    event = SkyDB::Event.new
    @client.expects(:send_message).with(is_a(SkyDB::Message::EADD))
    @client.eadd event
  end


  ######################################
  # Path Messages
  ######################################

  def test_peach
    @client.expects(:send_message).with(is_a(SkyDB::Message::PEACH))
    @client.peach "foo"
  end
end
