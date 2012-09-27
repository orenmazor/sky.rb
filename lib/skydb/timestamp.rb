class SkyDB
  class Timestamp
    ##########################################################################
    #
    # Static Methods
    #
    ##########################################################################

    # Converts a Time object to a Sky timestamp value.
    #
    # @param [Time] time  the time object.
    #
    # @return [Fixnum]  the number of microseconds since the epoch (1970-01-01T00:00:00.000000Z).
    def self.to_timestamp(time)
      if time.nil?
        return nil
      else
        return time.to_time.utc.to_i * 1_000_000
      end
    end
  end
end
