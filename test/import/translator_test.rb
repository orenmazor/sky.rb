require 'test_helper'

class TestTranslator < MiniTest::Unit::TestCase
  def setup
    @translator = SkyDB::Import::Translator.new()
    
    @input = {
      'myString' => 'hello world',
      'myInt' => '100',
      'myFloat' => '20.21',
      'myTrue' => 'true',
      'myFalse' => 'false',
      'myDate' => '10/26/1982 12:00 AM',
      'foo' => '1000',
    }
    @output = {}
  end
  

  ######################################
  # Simple Translation
  ######################################

  def test_string_translation
    SkyDB::Import::Translator.new(:input_field => 'myString', :output_field => 'data')
      .translate(@input, @output)
    assert_equal 'hello world', @output['data']
  end

  def test_int_translation
    SkyDB::Import::Translator.new(:input_field => 'myInt', :output_field => 'data', :format => 'Int')
      .translate(@input, @output)
    assert_equal 100, @output['data']
  end

  def test_float_translation
    SkyDB::Import::Translator.new(:input_field => 'myFloat', :output_field => 'data', :format => 'Float')
      .translate(@input, @output)
    assert_equal 20.21, @output['data']
  end

  def test_boolean_true_translation
    SkyDB::Import::Translator.new(:input_field => 'myTrue', :output_field => 'data', :format => 'Boolean')
      .translate(@input, @output)
    assert_equal true, @output['data']
  end

  def test_boolean_false_translation
    SkyDB::Import::Translator.new(:input_field => 'myFalse', :output_field => 'data', :format => 'Boolean')
      .translate(@input, @output)
    assert_equal false, @output['data']
  end

  def test_date_translation
    SkyDB::Import::Translator.new(:input_field => 'myDate', :output_field => 'data', :format => 'Date')
      .translate(@input, @output)
    assert_equal Time.parse('1982-10-26'), @output['data']
  end


  ######################################
  # Dynamic Translation
  ######################################

  def test_translate_function_proc
    SkyDB::Import::Translator.new(:translate_function => lambda {|input, output| output['data'] = input['foo'].to_i + 10})
      .translate(@input, @output)
    assert_equal 1010, @output['data']
  end


  def test_translate_function_string
    SkyDB::Import::Translator.new(:translate_function => "output['data'] = input['foo'].to_i * 2")
      .translate(@input, @output)
    assert_equal 2000, @output['data']
  end
end
