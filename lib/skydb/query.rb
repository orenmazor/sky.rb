require 'skydb/query/selection'

class SkyDB
  # The Query object represents a high level abstraction of how data is
  # processed and retrieved from the database. It is inspired by ActiveRecord
  # in the sense that commands can be chained together.
  #
  # The query is not executed until the results() method is called.
  class Query
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    def initialize(options={})
      self.client = options[:client]
      self.selection = options[:selection]
      self.groups = options[:groups]
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The client that is used for executing the query.
    attr_accessor :client

    # The properties that should be selected from the database.
    attr_accessor :selection

    # The properties that should be grouped by when selecting data.
    attr_accessor :groups


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Results
    ####################################

    # Executes the query and returns the resulting data.
    def results
      # Generate the Lua code for this query.
      code = to_lua()
      
      # Send it to the server.
      results = client.aggregate(code)
      
      # Return the results.
      return results
    end


    ####################################
    # Lua Generation
    ####################################

    # Generates the Lua code that represents the query.
    def to_lua
      # TODO: Generate Lua code.
    end
  end
end