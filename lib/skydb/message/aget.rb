class SkyDB
  class Message
    class AGET < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'action get' message.
      #
      # @param [Fixnum] action_id  the identifier of the action to retrieve.
      def initialize(action_id=nil, options={})
        super(Type::AGET)
        self.action_id = action_id
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