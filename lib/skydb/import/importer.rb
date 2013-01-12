require 'yaml'

class SkyDB
  class Import
    class Importer
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
      def import
        # TODO: Read in the format file as a translator.
        # TODO: Loop over each of the files.
        # TODO:   Translate the row into a Sky event.
        # TODO:   Send the event to the Sky server.
        # TODO:   Update progress bar.
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
        
        # Convert each field to a translator.
        transform['fields'].each_pair do |key, value|
          translator = Translator.new(:output_field => key)

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
          
          # Append to the list of translators.
          @translators << translator
        end
        
        return nil
      end

      # Parses and appends the contents of a transform file to the importer.
      #
      # @param [String]  the filename to load from.
      def load_transform_file(filename)
        load_transform(IO.read(filename))
      end
    end
  end
end