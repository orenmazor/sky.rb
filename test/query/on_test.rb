require 'test_helper'

class TestQueryOnCondition < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @condition = SkyDB::Query::OnCondition.new()
  end


  ##############################################################################
  #
  # Tests
  #
  ##############################################################################

  ######################################
  # Validation
  ######################################

  def test_validate_action
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::OnCondition.new(:function_name => "foo").validate!
    end
    assert_match /^Action with non-zero identifier required/, e.message
  end

  def test_validate_function_name
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::OnCondition.new(:action => 10).validate!
    end
    assert_match /^Invalid function name ''/, e.message
  end
  
  
  ######################################
  # Code Generation
  ######################################

  def test_codegen
    @condition = SkyDB::Query::OnCondition.new(:action => 10, :function_name => "foo")
    expected =
      <<-BLOCK.unindent
        function foo(cursor, data)
          repeat
            if cursor.event.action_id == 10 then
              return true
            end
          until not cursor:next()
          return false
        end
      BLOCK
    assert_equal expected, @condition.codegen()
  end

  def test_codegen_enter
    @condition = SkyDB::Query::OnCondition.new(:action => :enter, :function_name => "foo")
    expected =
      <<-BLOCK.unindent
        function foo(cursor, data)
          return (cursor.session_event_index == 0)
        end
      BLOCK
    assert_equal expected, @condition.codegen()
  end
end
