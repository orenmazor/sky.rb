class SkyDB
  class Message
    class GetTables < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'get_tables' message.
      def initialize(options={})
        super('get_tables')
      end


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################

      ##################################
      # Validation
      ##################################

      # A flag stating if the table is required for this type of message.
      def require_table?
        return false
      end

      ####################################
      # Encoding
      ####################################

      def process_response(response)
        tables = []
        response['tables'].each do |hash|
          tables << SkyDB::Table.new(hash['name'])
        end
      end
    end
  end
end