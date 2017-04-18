require 'rubygems'

module RuboCop
  module Rails
    module OrderModelMacros
      module Version
        STRING = "0.1.22".freeze

        def self.gem_version
          Gem::Version.new(STRING)
        end
      end
    end
  end
end
