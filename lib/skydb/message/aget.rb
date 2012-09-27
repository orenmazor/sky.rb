class SkyDB
  class Message
    class AGET < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'action get' message.
      def initialize()
        super(Type::AGET)
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Action ID
      ##################################

      # The action identifier to retrieve.
      attr_reader :action_id
      
      def action_id=(value)
        @action_id = value.to_i
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
        buffer << action_id.to_msgpack
      end
    end
  end
end