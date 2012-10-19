class SkyDB
  class Message
    class AddProperty < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'property add' message.
      #
      # @param [Property] property  the property to add.
      def initialize(property=nil, options={})
        super('add_property')
        self.property = property
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Property
      ##################################

      # The property to add.
      attr_reader :property
      
      def property=(value)
        @property = value if value.is_a?(Property)
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
        buffer << property.to_msgpack
      end
    end
  end
end