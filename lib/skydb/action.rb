class SkyDB
  class Action
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the action.
    def initialize(id=0, name=nil)
      self.id = id
      self.name = name
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
  end
end