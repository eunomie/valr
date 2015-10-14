require 'rugged'

class Valr
  # Initialize new Valr for a git repository
  # @param [String] repo_path Path of git repository
  def initialize(repo_path)
    @repo_path = repo_path
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
    repo = Rugged::Repository.new @repo_path
    walker = Rugged::Walker.new repo
    walker.push repo.head.target_id
    messages = walker.inject([]) { |messages, c| messages << c.message }
    walker.reset
    messages
  end

  # Get the last sha1 of a git repository
  def last_sha1
    repo = Rugged::Repository.new @repo_path
    repo.head.target_id
  end
end
