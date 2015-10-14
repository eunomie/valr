module Valr
  class EmptyRepositoryError < RuntimeError
    # Error raised when the repository is empty
    # @param [String] repo_path Path in which to search a repository
    def initialize(repo_path)
      super("'#{repo_path}' is empty")
    end
  end
end
