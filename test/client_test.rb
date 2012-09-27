require 'minitest/autorun'
require 'skydb'

class TestClient < MiniTest::Unit::TestCase
  def setup
    @client = SkyDB::Client.new
  end
end