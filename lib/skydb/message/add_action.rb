class SkyDB
  class Message
    class AddAction < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'action add' message.
      def initialize(action=nil, options={})
        super('add_action')
        self.action = action
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Action
      ##################################

      # The action to add.
      attr_reader :action
      
      def action=(value)
        @action = value if value.is_a?(Action)
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
        buffer << action.to_msgpack
      end
    end
  end
end