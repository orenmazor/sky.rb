require 'test_helper'

class TestQueryAfter < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @after = SkyDB::Query::After.new()
  end


  ##############################################################################
  #
  # Tests
  #
  ##############################################################################

  ######################################
  # Validation
  ######################################

  def test_validate_action_id
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::After.new(:function_name => "foo").validate!
    end
    assert_match /^Action identifier required and must be greater than zero for/, e.message
  end
  
  def test_validate_function_name
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::After.new(:action_id => 10).validate!
    end
    assert_match /^Invalid function name '' for/, e.message
  end
  
  
  ######################################
  # Code Generation
  ######################################

  def test_codegen
    @after = SkyDB::Query::After.new(:action_id => 10, :function_name => "foo")
    expected =
      <<-BLOCK.unindent
        function foo(cursor, data)
          while cursor:next_session() do
            while cursor:next() do
              if cursor.event.action_id == 10 then
                return true
              end
            end
          end
          return false
        end
      BLOCK
    assert_equal expected, @after.codegen()
  end
end
