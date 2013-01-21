require 'yaml'
require 'csv'
require 'ruby-progressbar'

class SkyDB
  class Import
    class Importer
      ##########################################################################
      #
      # Errors
      #
      ##########################################################################

      class TransformNotFound < StandardError; end
      

      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      # Initializes the importer.
      def initialize(options={})
        @translators = []

        self.client = options[:client] || SkyDB.client
        self.table_name  = options[:table_name]
        self.format = options[:format]
        self.files  = options[:files] || []
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The client to access the Sky server with.
      attr_accessor :client

      # The name of the table to import into.
      attr_accessor :table_name

      # The format file to use for translating the input data.
      attr_accessor :format

      # A list of translators to use to convert input rows into output rows.
      attr_reader :translators

      # A list of files to input from.
      attr_accessor :files


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################
    
      ##################################
      # Import
      ##################################
    
      # Imports the rows from a list of files.
      #
      # @param [Array]  a list of files to import.
      def import(files)
        files = [files] unless files.is_a?(Array)
        
        # Set the table to import into.
        SkyDB.table_name = table_name
        
        # Loop over each of the files.
        files.each do |file|
          # Initialize progress bar.
          count = %x{wc -l #{file}}.split.first.to_i
          progress_bar = ::ProgressBar.create(
            :total => count,
            :format => ('%-40s' % file) + ' |%B| %P%%'
          )

          file = File.open(file, 'r')
          begin
            SkyDB.multi(:max_count => 1000) do
              # Process each line of the CSV file.
              CSV.foreach(file, :headers => true) do |input|
                input = input.to_hash
                
                # Convert input line to a symbolized hash.
                output = translate(input)
                output._symbolize_keys!
                
                p output
              
                # Convert hash to an event and send to Sky.
                event = SkyDB::Event.new(output)

                if !(event.object_id > 0)
                  progress_bar.clear()
                  puts "[ERROR] Invalid object id on line #{$.}."
                elsif event.timestamp.nil?
                  progress_bar.clear()
                  puts "[ERROR] Invalid timestamp on line #{$.}."
                else
                  SkyDB.add_event(event)
                end
              
                # Update progress bar.
                progress_bar.increment()
              end
            end
          ensure
            file.close
          end

          # Finish progress bar.
          progress_bar.finish()        
        end
        
        return nil
      end


      ##################################
      # Translation
      ##################################

      # Translates an input hash into an output hash using the translators.
      #
      # @param [Hash]  the input hash.
      #
      # @return [Hash]  the output hash.
      def translate(input)
        output = {}

        translators.each do |translator|
          translator.translate(input, output)
        end

        return output
      end
      
      
      ##################################
      # Transform Management
      ##################################
    
      # Parses and appends the contents of a transform file to the importer.
      #
      # @param [String]  the YAML formatted transform file.
      def load_transform(content)
        # Parse the transform file.
        transform = {'fields' => {}}.merge(YAML.load(content))

        # Load individual field translations.
        load_transform_fields(transform['fields'])
        
        # Load a free-form translate function if specified.
        if !transform['translate'].nil?
          @translators << Translator.new(
            :translate_function => transform['translate']
          )
        end
        
        return nil
      end

      # Loads a hash of transforms.
      #
      # @param [Hash]  the hash of transform info.
      # @param [Array]  the path of fields.
      def load_transform_fields(fields, path=nil)
        
        # Convert each field to a translator.
        fields.each_pair do |key, value|
          translator = Translator.new(:output_field => (path.nil? ? key : path.clone.concat([key])))

          # Load a regular transform.
          if value.is_a?(String)
            # If the line is wrapped in curly braces then generate a translate function.
            m, code = *value.match(/^\s*\{(.*)\}\s*$/)
            if !m.nil?
              translator.translate_function = code
          
            # Otherwise it's a colon-separated field describing the input field and data type.
            else
              input_field, format = *value.strip.split(":")
              translator.input_field = input_field
              translator.format = format
            end

          # If this field is a hash then load it as a nested transform.
          elsif value.is_a?(Hash)
            load_transform_fields(value, path.to_a.clone.flatten.concat([key]))
          
          else
            raise "Invalid data type for '#{key}' in transform file: #{value.class}"
          end
          
          # Append to the list of translators.
          @translators << translator
        end
      end


      # Parses and appends the contents of a transform file to the importer.
      #
      # @param [String]  the filename to load from.
      def load_transform_file(filename)
        transforms_path = File.expand_path(File.join(File.dirname(__FILE__), 'transforms'))
        named_transform_path = File.join(transforms_path, "#{filename}.yml")
        
        # If it's just a word then find it in the gem.
        if filename.index(/^\w+$/)
          raise TransformNotFound.new("Named transform not available: #{filename} (#{named_transform_path})") unless File.exists?(named_transform_path)
          return load_transform(IO.read(named_transform_path))

        # Otherwise load it from the present working directory.
        else
          raise TransformNotFound.new("Transform file not found: #{filename}") unless File.exists?(filename)
          return load_transform(IO.read(filename))
        end
      end
    end
  end
end