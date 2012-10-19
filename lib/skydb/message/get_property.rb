class SkyDB
  class Message
    class GetProperty < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'property get' message.
      #
      # @param [Fixnum] property_id  The identifier for the property to retrieve.
      def initialize(property_id=nil, options={})
        super('get_property')
        self.property_id = property_id
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