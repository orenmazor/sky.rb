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
end
