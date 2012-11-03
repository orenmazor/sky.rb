# encoding: binary
require 'test_helper'

class TestMessageNextActions < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::NextActions.new()
  end
  
  ######################################
  # Object ID
  ######################################
  
  def test_prior_action_ids
    @message.prior_action_ids = [1, 2, 3]
    assert_equal [1, 2, 3], @message.prior_action_ids
  end
  
  def test_invalid_prior_action_ids
    @message.prior_action_ids = 12
    assert_equal [], @message.prior_action_ids
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.prior_action_ids = [1, 2]
    @message.encode(buffer)
    assert_bytes "\x93\x01\xacnext_actions\xa0\x92\x01\x02", buffer
  end
end
