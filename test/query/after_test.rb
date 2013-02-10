require 'test_helper'

class TestQueryAfterCondition < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @after = SkyDB::Query::AfterCondition.new()
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
      SkyDB::Query::AfterCondition.new(:function_name => "foo").validate!
    end
    assert_match /^Action with non-zero identifier required/, e.message
  end

  def test_validate_enter_action
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::AfterCondition.new(:action => :enter, :function_name => "foo").validate!
    end
    assert_equal "Enter actions cannot be used with an 'after' condition. Please use an 'on' condition instead.", e.message
  end
  
  def test_validate_function_name
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::AfterCondition.new(:action => 10).validate!
    end
    assert_match /^Invalid function name ''/, e.message
  end
  
  
  ######################################
  # Code Generation
  ######################################

  def test_codegen
    @after = SkyDB::Query::AfterCondition.new(:action => 10, :function_name => "foo")
    expected =
      <<-BLOCK.unindent
        function foo(cursor, data)
          repeat
            if cursor.event.action_id == 10 then
              cursor:next()
              return true
            end
          until not cursor:next()
          return false
        end
      BLOCK
    assert_equal expected, @after.codegen()
  end

  def test_codegen_within_1_step
    @after = SkyDB::Query::AfterCondition.new(:action => 10, :within => {:quantity => 1, :unit => 'step'}, :function_name => "foo")
    expected =
      <<-BLOCK.unindent
        function foo(cursor, data)
          remaining = 1
          repeat
            if cursor.event.action_id == 10 then
              cursor:next()
              return true
            end
            remaining = remaining - 1
            if remaining <= 0 then return false end
          until not cursor:next()
          return false
        end
      BLOCK
    assert_equal expected, @after.codegen()
  end
end
