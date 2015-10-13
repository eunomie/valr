class Valr
  # Get the changelog based on commit messages.
  # @param [Array<String>] messages Git commit messages
  # @return [String] changelog
  def changelog(messages)
    to_list(first_lines(messages.reverse))
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
end
