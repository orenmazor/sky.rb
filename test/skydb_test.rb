require 'minitest/autorun'
require 'skydb'

class TestSkyDB < MiniTest::Unit::TestCase
  def setup
    @skydb = SkyDB.new
  end
end