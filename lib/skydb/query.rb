require 'skydb/query/selection'
require 'skydb/query/condition'
require 'skydb/query/after_condition'
require 'skydb/query/on_condition'
require 'skydb/query/validation_error'

class SkyDB
  # The Query object represents a high level abstraction of how data is
  # processed and retrieved from the database. It is inspired by ActiveRecord
  # in the sense that commands can be chained together.
  #
  # The query is not executed until the execute() method is called.
  class Query
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    def initialize(options={})
      self.client = options[:client]
      self.selection = options[:selection]
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The client that is used for executing the query.
    attr_accessor :client

    # The properties that should be selected from the database.
    attr_reader :selection
    
    def selection=(value)
      @selection = value
      value.query = self unless value.nil?
      return value
    end

    # The number of idle seconds that separates sessions. 
    attr_accessor :session_idle_time


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Helpers
    ####################################

    # Creates and appends a new selection to the query.
    #
    # @param [String] fields  A list of fields to add to the selection.
    #
    # @return [Selection]  The newly created selection object is returned.
    def select(*fields)
      self.selection = SkyDB::Query::Selection.new()
      selection.select(*fields)
      return selection
    end

    # Sets the session idle seconds and returns the query object.
    #
    # @param [Fixnum] seconds  The number of idle seconds.
    #
    # @return [Query]  The query object is returned.
    def session(seconds)
      self.session_idle_time = seconds
      return self
    end


    ####################################
    # Execution
    ####################################

    # Executes the query and returns the resulting data.
    def execute
      # Generate the Lua code for this query.
      code = codegen()
      
      # Send it to the server.
      results = client.aggregate(code)
      
      # Return the results.
      return results
    end


    ####################################
    # Validation
    ####################################

    # Validates that all the elements of the query are valid.
    def validate!
      selection.validate!
    end
    
    
    ####################################
    # Codegen
    ####################################

    # Generates the Lua code that represents the query.
    def codegen
      # Lookup all actions & properties.
      lookup_identifiers()
      
      # Validate everything in query before proceeding.
      validate!

      # Generate selection.
      code = []
      code << selection.codegen()
      
      # Generate aggregate() function.
      code << "function aggregate(cursor, data)"
      code << "  cursor:set_session_idle(#{session_idle_time.to_i})" if session_idle_time.to_i > 0
      code << "  select_all(cursor, data)"
      code << "end"
      code << ""
      
      return code.join("\n")
    end


    ####################################
    # Serialization
    ####################################
    
    # Serializes the query object into a JSON string.
    def to_json(*a); to_hash.to_json(*a); end

    # Serializes the query object into a hash.
    def to_hash(*a)
      hash = {}
      hash['selections'] = [selection.to_hash(*a)] unless selection.nil?
      hash['sessionIdleTime'] = session_idle_time.to_i
      hash
    end

    # Deserializes the query object into a hash.
    def from_hash(hash, *a)
      return if hash.nil?
      selection_hash, x = *hash['selections']
      self.selection = SkyDB::Query::Selection.new.from_hash(selection_hash)
      self.session_idle_time = hash['sessionIdleTime'].to_i
      return self
    end
    

    ####################################
    # Utility
    ####################################
    
    # Generates a sequence number used for uniquely naming objects and
    # functions in the query.
    def nextseq
      @sequence = (@sequence || 0) + 1
    end

    # Looks up all actions and properties that are missing an identifier.
    def lookup_identifiers
      # Find all the actions on the selection that are missing an id.
      actions = []
      actions.concat(selection.get_identifiers())

      # Lookup all the actions.
      if actions.length > 0
        client.lookup(:actions => actions)
      end
      
      return nil
    end
  end
end