class SkyDB
  class Query
    # A validation error indicates that some part of a query is incomplete
    # and that codegen could not occur.
    class ValidationError < StandardError; end
  end
end

