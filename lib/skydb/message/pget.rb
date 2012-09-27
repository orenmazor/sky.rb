class SkyDB
  class Message
    class PGET < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'property get' message.
      def initialize()
        super(Type::PGET)
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Property ID
      ##################################

      # The property identifier to retrieve.
      attr_reader :property_id
      
      def property_id=(value)
        @property_id = value.to_i
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
        buffer << property_id.to_msgpack
      end
    end
  end
end