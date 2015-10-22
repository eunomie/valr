module Valr
  class NotValidBranchError < RuntimeError
    # Error raised when asked branch is not valid
    # @param [String] branch Name of the branch
    def initialize(branch)
      super("'#{branch}' is not a valid branch")
    end
  end
end
