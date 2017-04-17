require 'pathname'
require 'yaml'

require 'rubocop'
require 'rubocop/rails/order_model_macros'
require 'rubocop/rails/order_model_macros/configuration'
require 'rubocop/rails/order_model_macros/version'
require 'rubocop/rails/inject'

RuboCop::Rails::Inject.defaults!

# cops
require 'rubocop/cop/rails/order_model_macros'
