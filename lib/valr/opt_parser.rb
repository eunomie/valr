require 'optparse'

module Valr
  class OptParser
    def self.parse(args)
      options = {}
      options[:range] = nil
      options[:first_parent] = false
      options[:branch] = nil
      options[:from_ancestor_with] = nil

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: valr [options] [repository]"

        opts.separator ''
        opts.separator 'Range options:'

        opts.on('-r', '--range [RANGE]', 'display commits only for the RANGE') do |range|
          options[:range] = range
        end

        opts.on('-f', '--from [REV]', 'display commits from REV to HEAD') do |rev|
          options[:range] = "#{rev}..HEAD"
        end

        opts.separator ''
        opts.separator 'Branch options:'

        opts.on('-b', '--branch [BRANCH]', 'display commits for a specific BRANCH') do |branch|
          options[:branch] = branch
        end

	opts.on('--from-ancestor-with [ANCESTOR]', 'display commits from an ancestor with a branch') do |ancestor|
          options[:from_ancestor_with] = ancestor
	end

        opts.separator ''
        opts.separator 'Filter:'

        opts.on('-p', '--first-parent', 'display only first-parent commits') do |p|
          options[:first_parent] = p
        end

        opts.separator ''
        opts.separator 'Help:'
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end

      opt_parser.parse! args
      options
    end
  end
end
