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
        # Update actions.
        actions.each_with_index do |action, index|
          obj = response['actions'][index]
          action.id = obj.nil? ? 0 : obj['id']
        end
        
        # Update properties.
        properties.each_with_index do |property, index|
          obj = response['properties'][index]
          property.id = obj.nil? ? 0 : obj['id']
          property.type = obj.nil? ? :object : SkyDB::Property::Type.decode(obj['type'])
          property.data_type = obj.nil? ? nil : obj['dataType']
        end
        
        return response
      end
    end
  end
end