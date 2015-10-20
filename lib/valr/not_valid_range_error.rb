module Valr
  class NotValidRangeError < RuntimeError
    # Error raised when the specified range is not valid
    # @param [String] range Range asked
    def initialize(range)
      super("'#{range}' is not a valid range")
    end
  end
end
