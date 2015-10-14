require 'rugged'
require 'valr/repository_error'
require 'valr/empty_repository_error'

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
    # @return [String] changelog
    def changelog
      to_list(first_lines(log_messages))
    end

    # Get the full changelog including metadata.
    # @return [String] changelog
    def full_changelog
      %{#{last_sha1}

#{changelog}}
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
    # @return [Array<String>] log messages
    def log_messages
      walker = Rugged::Walker.new @repo
      walker.push @repo.head.target_id
      messages = walker.inject([]) { |messages, c| messages << c.message }
      walker.reset
      messages
    end

    # Get the last sha1 of a git repository
    def last_sha1
      @repo.head.target_id
    end
  end
end
