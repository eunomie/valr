require 'optparse'

module Valr
  class OptParser
    def self.parse(args)
      options = {}
      options[:range] = nil
      options[:first_parent] = false

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
