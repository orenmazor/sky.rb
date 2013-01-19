require 'test_helper'

class TestQuerySelection < MiniTest::Unit::TestCase
  def test_parse_single_field
    selection = SkyDB::Query::Selection.parse("foo")
    assert_equal 1, selection.fields.length
    assert_equal "foo", selection.fields[0].expression
  end
end
