require 'simplecov'
SimpleCov.start

$: << File.expand_path("../../lib", File.dirname(__FILE__))
require 'valr'

require_relative '../../test_helpers/git_helpers'
World(GitHelpers)
