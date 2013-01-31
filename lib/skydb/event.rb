class SkyDB
  class Event
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes an event object.
    def initialize(options={})
      self.object_id = options[:object_id]
      self.timestamp = options[:timestamp]
      self.action = options[:action]
      self.data = options[:data]
    end


    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    ##################################
    # Object ID
    ##################################

    # The object identifier.
    attr_accessor :object_id

    ##################################
    # Timestamp
    ##################################

    # The timestamp of when the event occurred.
    attr_reader :timestamp
    
    def timestamp=(value)
      @timestamp = value.to_time if value.class.method_defined?(:to_time)
    end

    ##################################
    # Action
    ##################################

    # The hash containing action related information (including the name of
    # the action being performed).
    attr_reader :action
    
    def action=(value)
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
      @action = clone.keys.length > 0 ? clone : nil
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
    
    # Encodes the event into MsgPack format.
    def to_msgpack
      obj = {
        :objectId => object_id.to_msgpack,
        :timestamp => SkyDB::Timestamp.to_timestamp(timestamp)
      }
      obj[:action] = action unless action.nil? || action.empty?
      obj[:data] = data unless data.nil? || data.empty?
      return obj.to_msgpack
    end
  end
end