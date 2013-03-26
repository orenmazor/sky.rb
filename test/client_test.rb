# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @client = SkyDB::Client.new()
    @table = SkyDB::Table.new(:name => 'foo')
  end

  
  ######################################
  # Table API
  ######################################

  def test_create_table
    stub_request(:post, "http://localhost:8585/tables")
      .with(:body => '{"name":"foo"}')
      .to_return(:status => 200, :body => '{"name":"foo"}')

    table = @client.create_table(SkyDB::Table.new(:name => 'foo'))
    assert_equal("foo", table.name)
  end

  def test_delete_table
    stub_request(:delete, "http://localhost:8585/tables/foo").to_return(:status => 200)
    @client.delete_table(SkyDB::Table.new(:name => 'foo'))
  end


  ######################################
  # Property API
  ######################################

  def test_create_property
    stub_request(:post, "http://localhost:8585/tables/foo/properties")
      .with(:body => '{"name":"action","transient":true,"dataType":"string"}')
      .to_return(:status => 200, :body => '{"id":-1,"name":"action","transient":true,"dataType":"string"}')

    property = @client.create_property(@table, SkyDB::Property.new(:name => 'action', :transient => true, :data_type => 'string'))
    assert_equal("action", property.name)
    assert_equal(true, property.transient)
    assert_equal("string", property.data_type)
  end

  def test_get_properties
    stub_request(:get, "http://localhost:8585/tables/foo/properties")
      .to_return(:status => 200, :body => '[{"id":-1,"name":"action","transient":true,"dataType":"string"},{"id":1,"name":"first_name","transient":false,"dataType":"integer"}]')

    properties = @client.get_properties(@table)
    assert_equal(2, properties.length)
    assert_equal("action", properties[0].name)
    assert_equal("first_name", properties[1].name)
  end
end
