class SkyDB
  class Message
    class NextAction < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'next action' message.
      #
      # @param [Array] prior_action_ids  the prior action ids.
      def initialize(prior_action_ids=nil, options={})
        super('next_action')
        self.prior_action_ids = prior_action_ids
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Prior Action IDs
      ##################################

      # The prior action ids.
      attr_reader :prior_action_ids
      
      def prior_action_ids=(value)
        @prior_action_ids = value.is_a?(Array) ? value : []
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
        buffer << prior_action_ids.to_msgpack
      end
    end
  end
end