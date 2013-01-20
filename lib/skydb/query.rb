require 'skydb/query/selection'
require 'skydb/query/after'
require 'skydb/query/validation_error'

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
      self.selection = options[:selection] || SkyDB::Query::Selection.new()
      self.conditions = options[:conditions] || []
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

    # A list of conditions that must be fulfilled before selection can occur.
    attr_accessor :conditions


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Helpers
    ####################################

    # Adds a list of fields to the selection.
    #
    # @param [String] fields  A list of fields to add to the selection.
    #
    # @return [Query]  The query object is returned.
    def select(*fields)
      selection.select(*fields)
      return self
    end

    # Adds one or more grouping fields to the selection of the query.
    #
    # @param [String] groups  A list of groups to add to the selection.
    #
    # @return [Query]  The query object is returned.
    def group_by(*groups)
      selection.group_by(*groups)
      return self
    end

    # Adds an 'after' condition to the query.
    #
    # @param [Hash] options  The options to pass to the 'after' condition.
    #
    # @return [Query]  The query object is returned.
    def after(options={})
      conditions << SkyDB::Query::After.new(options)
      return self
    end


    ####################################
    # Results
    ####################################

    # Executes the query and returns the resulting data.
    def results
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
      # TODO: Lookup all actions & properties.
      
      # Validate everything in query before proceeding.
      validate!

      # Generate selection.
      code = []
      code << selection.codegen()
      
      # Generate condition functions.
      conditions.each_with_index do |condition, index|
        condition.function_name ||= "__condition#{nextseq}"
        code << condition.codegen(:next => (index > 0))
      end

      # Generate the invocation of the conditions.
      conditionals = conditions.map {|condition| "#{condition.function_name}(cursor, data)"}.join(' and ')
      
      # Generate aggregate() function.
      code << "function aggregate(cursor, data)"
      code << "  while cursor:next_session() do"
      code << "    while cursor:next() do"
      code << "      if #{conditionals} then"
      code << "        select(cursor, data)"
      code << "      end"
      code << "    end"
      code << "  end"
      code << "end"
      
      return code.join("\n")
    end


    ####################################
    # Utility
    ####################################
    
    private
    
    # Generates a sequence number used for uniquely naming objects and
    # functions in the query.
    def nextseq
      @sequence = (@sequence || 0) + 1
    end
  end
end