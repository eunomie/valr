require 'rugged'
require 'valr/repository_error'
require 'valr/empty_repository_error'
require 'valr/not_valid_range_error'

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
    # @return [String] changelog
    def changelog(first_parent: false, range: nil)
      to_list(first_lines(log_messages first_parent, range))
    end

    # Get the full changelog including metadata.
    # @param [Boolean] first_parent Optional, if true limits to first parent commits
    # @param [String] range Optional, define a specific range of commits
    # @return [String] changelog
    def full_changelog(first_parent: false, range: nil)
      if range.nil?
        full_changelog_no_range first_parent
      else
        full_changelog_range first_parent, range
      end
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
    # @return [Array<String>] log messages
    def log_messages(first_parent = false, range = nil)
      walker = Rugged::Walker.new @repo
      if range.nil?
        walker.push @repo.head.target_id
      else
        begin
          walker.push_range range
        rescue Rugged::ReferenceError => e
          raise Valr::NotValidRangeError.new range
        end
      end
      walker.simplify_first_parent if first_parent
      messages = walker.inject([]) { |messages, c| messages << c.message }
      walker.reset
      messages
    end

    # Get the full changelog including metadata.
    # @param [Boolean] first_parent If true limits to first parent commits
    # @return [String] changelog
    def full_changelog_no_range(first_parent)
      %{#{last_sha1}

#{changelog(first_parent: first_parent)}}
    end

    # Get the full changelog including metadata.
    # @param [Boolean] first_parent If true limits to first parent commits
    # @param [String] range Define a specific range of commits
    # @return [String] changelog
    def full_changelog_range(first_parent, range)
      changelog_list = changelog first_parent: first_parent, range: range
      from, to = range.split '..'
      from_commit, to_commit = [from, to].map { |ref| rev_parse ref }
      %{    from: #{from} <#{from_commit.oid}>
    to:   #{to} <#{to_commit.oid}>

#{changelog_list}}
    end

    # Get the last sha1 of a git repository
    def last_sha1
      @repo.head.target_id
    end

    # Get the commit of a reference (tag or other)
    # @param [String] ref Reference to get the commit
    # @return the commit
    def rev_parse(ref)
      Rugged::Object.rev_parse @repo, ref
    end
  end
end
