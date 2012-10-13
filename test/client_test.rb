# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  def setup
    @client = SkyDB::Client.new(host:'127.0.0.1', port:9000)
    @message = mock('message')
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
  # Query Messages
  ######################################

  def test_next_action
    @client.expects(:send_message).with(is_a(SkyDB::Message::NextAction))
    @client.next_action [1, 2]
  end
end
