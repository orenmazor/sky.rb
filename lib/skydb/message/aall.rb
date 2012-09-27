class SkyDB
  class Message
    class AALL < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'action all' message.
      def initialize()
        super(Type::AALL)
      end


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################

      ####################################
      # Encoding
      ####################################

      # Encodes the message body.
      #
      # @param [IO] buffer  the buffer to write the header to.
      def encode_body(buffer)
        # Do nothing.
      end
    end
  end
end