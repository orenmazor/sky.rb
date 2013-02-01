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
    def to_json(*a); to_hash.to_json(*a); end

    # Encodes the action into JSON format.
    def to_hash(*a)
      {
        'id' => id,
        'name' => name
      }.delete_if {|k,v| v == '' || v == 0}
    end

    # Deserializes the selection field object from a hash.
    def from_hash(hash, *a)
      return nil if hash.nil?
      self.id = hash['id'].to_i
      self.name = hash['name']
      return self
    end
  end
end