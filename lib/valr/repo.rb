require 'rugged'
require 'valr/repository_error'
require 'valr/empty_repository_error'
require 'valr/not_valid_range_error'
require 'valr/not_valid_branch_error'

module Valr
  class Repo
    # Initialize new Valr for a git repository
    # @param [String] repo_path Path of git repository
    def initialize(repo_path)
      @repo_path = repo_path
      begin
        @repo = Rugged::Repository.new @repo_path
      rescue Rugged::RepositoryError => e
        raise Valr::RepositoryError.new @repo_path
      end
      raise Valr::EmptyRepositoryError.new @repo_path if @repo.empty?
    end

    # Get the changelog based on commit messages.
    # @param [Boolean] first_parent Optional, if true limits to first parent commits
    # @param [String] range Optional, define a specific range of commits
    # @param [String] branch Optional, show commits in a branch
    # @param [String] from_ancestor_with Optional, from common ancestor with this branch
    # @return [String] changelog
    def changelog(first_parent: false, range: nil, branch: nil, from_ancestor_with: nil)
      to_list(first_lines(log_messages first_parent, range, branch, from_ancestor_with))
    end

    # Get the full changelog including metadata.
    # @param [Boolean] first_parent Optional, if true limits to first parent commits
    # @param [String] range Optional, define a specific range of commits
    # @param [String] branch Optional, show commits in a branch
    # @param [String] from_ancestor_with Optional, from common ancestor with this branch
    # @return [String] changelog
    def full_changelog(first_parent: false, range: nil, branch: nil, from_ancestor_with: nil)
      changelog_list = changelog first_parent: first_parent, range: range, branch: branch, from_ancestor_with: from_ancestor_with
      if !range.nil?
        header = full_changelog_header_range range
      elsif !branch.nil?
        header = full_changelog_header_branch branch, from_ancestor_with
      else
        header = full_changelog_header_no_range
      end
      [header, "", changelog_list].join "\n"
    end

    private

    # Array to markdown list
    # @param [Array<String>] items
    # @return [String] markdown list
    def to_list(items)
      (items.map {|item| "- #{item}"}).join("\n")
    end

    # Extract only first lines
    # @param [Array<String>] strings
    # @return [Array<String>] Array of first lines
    def first_lines(strings)
      strings.map {|string|
        string.split("\n").first
      }
    end

    # Get log messages for a repository
    # @param [Boolean] first_parent Optional, if true limit to first parent commits
    # @param [String] range Optional, define a specific range of commits
    # @param [String] branch Optional, show commits in a branch
    # @param [String] from_ancestor_with Optional, from common ancestor with this branch
    # @return [Array<String>] log messages
    def log_messages(first_parent = false, range = nil, branch = nil, from_ancestor_with = nil)
      walker = Rugged::Walker.new @repo
      if !range.nil?
        begin
          walker.push_range range
        rescue Rugged::ReferenceError => e
          raise Valr::NotValidRangeError.new range
        end
      elsif !branch.nil?
        b = @repo.references["refs/heads/#{branch}"]
        raise Valr::NotValidBranchError.new branch if b.nil?
        if !from_ancestor_with.nil?
          a = @repo.references["refs/heads/#{from_ancestor_with}"]
          raise Valr::NotValidBranchError.new from_ancestor_with if a.nil?
          base = @repo.merge_base b.target_id, a.target_id
          walker.push_range "#{base}..#{b.target_id}"
        else
          walker.push b.target_id
        end
      else
        walker.push @repo.head.target_id
      end
      walker.simplify_first_parent if first_parent
      message_list = walker.inject([]) { |messages, c| messages << c.message }
      walker.reset
      message_list
    end

    # Get the header when no range
    # @return [String] header no range
    def full_changelog_header_no_range
      @repo.head.target_id
    end

    # Get the header when a range is defined
    # @param [String] range Define a specific range of commits
    # @return [String] header with a range
    def full_changelog_header_range(range)
      from, to = range.split '..'
      from_commit, to_commit = [from, to].map { |ref| rev_parse ref }
      ["    from: #{from} <#{from_commit.oid}>",
       "    to:   #{to} <#{to_commit.oid}>"].join "\n"
    end

    # Get the header when a branch is defined
    # @param [String] branch Show commits for a branch
    # @param [String] ancestor Ancestor or nil
    # @return [String] header with a branch
    def full_changelog_header_branch(branch, ancestor)
      h = ["    branch: #{branch} <#{@repo.references["refs/heads/#{branch}"].target_id}>"]
      h << "    from ancestor with: #{ancestor} <#{@repo.references["refs/heads/#{ancestor}"].target_id}>" unless ancestor.nil?
      h.join "\n"
    end

    # Get the commit of a reference (tag or other)
    # @param [String] ref Reference to get the commit
    # @return the commit
    def rev_parse(ref)
      Rugged::Object.rev_parse @repo, ref
    end
  end
end
