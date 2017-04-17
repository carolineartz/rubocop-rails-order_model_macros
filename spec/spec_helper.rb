# This file is copied from rubocop-rspec

require 'rubocop'
require 'rubocop/rspec/support'
require 'pry'

RSpec.configure do |config|
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubocop-rails-order_model_macros'
