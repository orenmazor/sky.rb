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

      # The name of the table to import into.
      attr_accessor :table_name

      # The format file to use for translating the input data.
      attr_accessor :format

      # A list of files to input from.
      attr_accessor :files

      ##########################################################################
      #
      # Methods
      #
      ##########################################################################
    
      # Imports the rows from a list of files.
      def import
        # TODO: Read in the format file as a translator.
        # TODO: Loop over each of the files.
        # TODO:   Translate the row into a Sky event.
        # TODO:   Send the event to the Sky server.
        # TODO:   Update progress bar.
      end
    end
  end
end