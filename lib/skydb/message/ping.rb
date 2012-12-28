class SkyDB
  class Message
    class Ping < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'ping' message.
      def initialize(options={})
        super('ping')
      end


      ########################################################################
      #
      # Methods
      #
      ########################################################################

      ##################################
      # Validation
      ##################################

      # A flag stating if the table is required for this type of message.
      def require_table?
        return false
      end
    end
  end
end