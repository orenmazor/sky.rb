class SkyDB
  class Message
    class Lookup < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'lookup' message.
      def initialize(options={})
        super('lookup')
        self.actions = options[:actions] || []
        self.properties = options[:properties] || []
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Actions
      ##################################

      # A list of actions to lookup.
      attr_accessor :actions

      # A list of properties to lookup.
      attr_accessor :properties


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
        buffer << {
          'actionNames' => actions.map {|action| action.name},
          'propertyNames' => properties.map {|property| property.name}
        }.to_msgpack
      end

      ####################################
      # Response processing
      ####################################

      # Updates the action and property identifiers from the returned data.
      def process_response(response)
        # Update action identifiers.
        action_ids = response['actionIds']
        actions.each_with_index do |action, index|
          action.id = action_ids[index].to_i
        end
        
        # Update property identifiers.
        property_ids = response['propertyIds']
        propertys.each_with_index do |property, index|
          property.id = property_ids[index].to_i
        end
        
        return response
      end
    end
  end
end