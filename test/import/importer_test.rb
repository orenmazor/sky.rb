require 'test_helper'

class TestImporter < MiniTest::Unit::TestCase
  def setup
    @importer = SkyDB::Import::Importer.new(:table_name => 'test')
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


  ######################################
  # Import
  ######################################

  def test_import_csv
    events = [mock(), mock(), mock(), mock()]
    SkyDB::Event.expects(:new).with(:object_id => 100, :timestamp => Chronic.parse("2000-01-01T00:00:00Z"), :action => {:name => '/index.html'}).returns(events[0])
    SkyDB::Event.expects(:new).with(:object_id => 100, :timestamp => Chronic.parse("2000-01-01T00:01:00Z"), :action => {:name => '/signup.html'}).returns(events[1])
    SkyDB::Event.expects(:new).with(:object_id => 100, :timestamp => Chronic.parse("2000-01-01T00:02:00Z"), :action => {:name => '/buy.html'}).returns(events[2])
    SkyDB::Event.expects(:new).with(:object_id => 101, :timestamp => Chronic.parse("2000-01-02T12:00:00Z"), :action => {:name => '/index.html'}).returns(events[3])
    SkyDB.expects(:add_event).with(events[0])
    SkyDB.expects(:add_event).with(events[1])
    SkyDB.expects(:add_event).with(events[2])
    SkyDB.expects(:add_event).with(events[3])
    @importer.load_transform_file('sky')
    @importer.import(['fixtures/importer/1.csv'])
  end
end
