module Valr
  class RepositoryError < RuntimeError
    # Error raised when not in a repository
    # @param [String] repo_path Path in which to search a repository
    def initialize(repo_path)
      super("'#{repo_path}' is not a git repository")
    end
  end
end
