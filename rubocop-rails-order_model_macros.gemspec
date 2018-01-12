# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubocop/rails/order_model_macros/version'

Gem::Specification.new do |spec|
  spec.name          = "rubocop-rails-order_model_macros"
  spec.version       = RuboCop::Rails::OrderModelMacros::Version::STRING
  spec.authors       = ["Caroline Artz"]
  spec.email         = ["ceartz@gmail.com"]

  spec.summary       = "Extension of RuboCop for ordering macro style methods in Rails models"
  spec.description   = "Extension of RuboCop for ordering macro style methods in Rails models"
  spec.homepage      = "https://github.com/carolineartz/rubocop-rails-order_model_macros"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rubocop', '~> 0.51'
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rspec", "~> 3.4"
end
