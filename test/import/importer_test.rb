require 'test_helper'

class TestImporter < MiniTest::Unit::TestCase
  def setup
    @importer = SkyDB::Import::Importer.new()
    @input  = {
      'myString' => 'Hello',
      'foo' => 100
    }
    @output = {}
  end
  

  ######################################
  # Transform File
  ######################################

  def test_load_simple_transform
    @importer.load_transform(
      <<-BLOCK.unindent
      fields:
        name: myString
      BLOCK
    )
    
    assert_equal "myString", @importer.translators.first.input_field
    assert_equal "name", @importer.translators.first.output_field
    assert_equal "string", @importer.translators.first.format
  end

  def test_load_simple_proc
    @importer.load_transform(
      <<-BLOCK.unindent
      fields:
        name: "{ output['foo'] * 10 }"
      BLOCK
    )
    
    assert_equal "name", @importer.translators.first.output_field
    assert !@importer.translators.first.translate_function.nil?
  end
end
