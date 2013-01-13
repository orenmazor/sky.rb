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
      attr_reader :format
      
      def format=(value)
        value = 'string' if value.nil?
        value = 'int' if value == 'integer'
        @format = value.to_s.downcase
      end

      # The translation function to execute. This can be a Proc or it can be
      # a String that is evaluated into a proc with "input" and "output"
      # arguments.
      attr_reader :translate_function
      
      def translate_function=(value)
        # Only allow nils, procs & strings.
        if !value.nil? && !value.is_a?(Proc) && !value.is_a?(String)
          raise "Unable to convert #{value.class} to a translation function."
        end
        
        # If this is a string then eval it into a proc.
        if value.is_a?(String)
          # If there is an output field set then make the lamda an assignment.
          if output_field.nil?
            @translate_function = eval("lambda { |input,output| #{value} }")

          # If there's no output field set then it's free form.
          else
            keys = output_field.is_a?(Array) ? output_field : [output_field]
            keys.map! {|key| "['" + key.gsub("'", "\\'") + "']"}
            @translate_function = eval("lambda { |input,output| output#{keys.join('')} = #{value.to_s} }")
          end

        # If this is a proc or a nil then just pass it through.
        else
          @translate_function = value
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

        # If the input field and output field are set then apply them.
        elsif !input_field.nil? && !output_field.nil?
          value = input[input_field]

          # Navigate down to nested output hash if necessary.
          if output_field.is_a?(Array)
            output_field[0..-2].each do |field|
              output[field] = {} unless output.has_key?(field)
              output = output[field]
            end

            output_field = self.output_field.last
          else
            output_field = self.output_field
          end

          # Convert type.
          output[output_field] = case format
          when "int" then value.to_i
          when "float" then value.to_f
          when "boolean" then (value.downcase == "true" || value.downcase == "yes" || value.downcase == "y")
          when "date" then Chronic.parse(value)
          else value.to_s
          end
        end
        
        return nil
      end
    end
  end
end