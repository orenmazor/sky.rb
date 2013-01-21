require 'skydb/property/type'

class SkyDB
  class Property
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the property.
    def initialize(options={})
      self.id = options[:id]
      self.type = options[:type]
      self.data_type = options[:data_type]
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

    # The property identifier.
    attr_reader :id
    
    def id=(value)
      @id = value.to_i
    end


    ##################################
    # Type
    ##################################

    # The property type. This can be either :object or :action.
    attr_reader :type
    
    def type=(value)
      value = :object unless [:object, :action].index(value)
      @type = value
    end


    ##################################
    # Data Type
    ##################################

    # The property data type. This can be either 'String', 'Int', 'Float',
    # or 'Boolean'.
    attr_reader :data_type
    
    def data_type=(value)
      value = nil unless ['String', 'Int', 'Float', 'Boolean'].index(value)
      @data_type = value
    end


    ##################################
    # Name
    ##################################

    # The name of the property.
    attr_reader :name
    
    def name=(value)
      @name = value.to_s
    end


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    # Encodes the property into MsgPack format.
    def to_msgpack
      return {
        id:id,
        type:SkyDB::Property::Type.encode(type),
        dataType:data_type,
        name:name
      }.to_msgpack
    end
  end
end