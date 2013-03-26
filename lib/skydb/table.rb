class SkyDB
  class Table
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the table.
    def initialize(options={})
      self.name = options[:name]
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The name of the table.
    attr_accessor :name


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################

    ####################################
    # Encoding
    ####################################

    # Encodes the table into a hash.
    def to_hash(*a)
      {'name' => name}
    end

    # Decodes a hash into a table.
    def from_hash(hash, *a)
      self.name = hash.nil? ? '' : hash['name']
      return self
    end
  end
end