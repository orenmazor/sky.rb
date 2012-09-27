class SkyDB
  class Message
    class EADD < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'event add' message.
      def initialize()
        super(Type::EADD)
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Object ID
      ##################################

      # The numeric identifier of the object that the event is attached to.
      attr_reader :object_id
      
      def object_id=(value)
        @object_id = value.to_i
      end

      ##################################
      # Timestamp
      ##################################

      # The timestamp of when the event occurred.
      attr_reader :timestamp
      
      def timestamp=(value)
        @timestamp = value.to_time if value.class.method_defined?(:to_time)
      end

      ##################################
      # Action ID
      ##################################

      # The numeric identifier for the action performed for this event. Set
      # this to 0 or nil if no action is being performed.
      attr_reader :action_id
      
      def action_id=(value)
        value = value.to_i
        value = nil if value == 0
        @action_id = value
      end

      ##################################
      # Data
      ##################################

      # A hash of data properties to set on the event. Properties can only be
      # a String, Fixnum, Float or Boolean.
      attr_reader :data
      
      def data=(value)
        clone = {}

        # Copy over keys
        if !value.nil?
          value.each_pair do |k, v|
            # Only copy keys with valid value types.
            if v.is_a?(String) || v.is_a?(Fixnum) || v.is_a?(Float) || v == true || v == false
              clone[k] = value[k]
            end
          end
        end

        # Only set the data if we have keys.
        @data = clone.keys.length > 0 ? clone : nil
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
        buffer << {
          :objectId => object_id,
          :timestamp => SkyDB::Timestamp.to_timestamp(timestamp),
          :actionId => action_id,
          :data => data
        }.to_msgpack
      end
    end
  end
end