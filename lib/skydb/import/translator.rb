require 'chronic'

class SkyDB
  class Import
    class Translator
      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      # Initializes the translator.
      def initialize(options={})
        self.input_field = options[:input_field]
        self.output_field = options[:output_field]
        self.format = options[:format]
        self.translate_function = options[:translate_function]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The name of the input field to read from.
      attr_accessor :input_field

      # The name of the output field to write to.
      attr_accessor :output_field

      # The format of the field (String, Integer, Float, Date).
      attr_accessor :format

      # The translation function to execute. This can be a Proc or it can be
      # a String that is evaluated into a proc with "input" and "output"
      # arguments.
      attr_reader :translate_function
      
      def translate_function=(value)
        if value.nil?
          @translate_function = nil
        elsif value.is_a?(Proc)
          @translate_function = value
        elsif value.is_a?(String)
          @translate_function = eval("lambda { |input,output| #{value.to_s} }")
        else
          raise "Unable to convert #{value.class} to a translation function."
        end
      end



      ##########################################################################
      #
      # Methods
      #
      ##########################################################################
    
      # Translate a field from the input hash into a field into the
      # output hash.
      #
      # @param [Hash]  the input data.
      # @param [Hash]  the output data.
      def translate(input, output)
        # If a translation function is set then use it.
        if !translate_function.nil?
          translate_function.call(input, output)
        end

        # If the input field and output field are set then apply them.
        if !input_field.nil? && !output_field.nil?
          value = input[input_field]
          
          output[output_field] = case format
          when "Int" then value.to_i
          when "Float" then value.to_f
          when "Boolean" then value == "true"
          when "Date" then Chronic.parse(value)
          else value.to_s
          end
        end
        
        return nil
      end
    end
  end
end