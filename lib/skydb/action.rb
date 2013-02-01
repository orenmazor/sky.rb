class SkyDB
  class Action
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the action.
    def initialize(options={})
      self.id = options[:id]
      self.name = options[:name]
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    ##################################
    # ID
    ##################################

    # The action identifier.
    attr_reader :id
    
    def id=(value)
      @id = value.to_i
    end


    ##################################
    # Name
    ##################################

    # The name of the action.
    attr_reader :name
    
    def name=(value)
      @name = value.to_s
    end


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    # Encodes the action into MsgPack format.
    def to_msgpack
      return {id:id, name:name}.to_msgpack
    end

    # Serializes the query object into a JSON string.
    def to_json(*a); as_json.to_json(*a); end

    # Encodes the action into JSON format.
    def as_json(*a)
      {
        'id' => id,
        'name' => name
      }.delete_if {|k,v| v == '' || v == 0}
    end
  end
end