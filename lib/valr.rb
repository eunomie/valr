require 'rugged'

class Valr
  # Get the changelog based on commit messages.
  # @param [String] repo_path Path of repository
  # @return [String] changelog
  def changelog(repo_path)
    to_list(first_lines(log_messages(repo_path)))
  end

  # Get the full changelog including metadata.
  # @param [String] repo_path Path of repository
  # @return [String] changelog
  def full_changelog(repo_path)
    "#{last_sha1(repo_path)}\n\n#{changelog(repo_path)}"
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
  # @param [String] repo_path Path of git repository
  # @return [Array<String>] log messages
  def log_messages(repo_path)
    repo = Rugged::Repository.new repo_path
    walker = Rugged::Walker.new repo
    walker.push repo.head.target_id
    messages = walker.inject([]) { |messages, c| messages << c.message }
    walker.reset
    messages
  end

  # Get the last sha1 of a git repository
  def last_sha1(repo_path)
    repo = Rugged::Repository.new repo_path
    repo.head.target_id
  end
end
