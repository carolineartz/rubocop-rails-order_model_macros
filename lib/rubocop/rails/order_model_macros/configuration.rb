module RuboCop
  module Rails
    module OrderModelMacros
      module Configuration
        def preferred_group_ordering
          @preferred_group_ordering ||= begin
            groups = @config.for_cop('Rails/OrderModelMacros')['PreferredGroupOrdering'].map(&:to_sym) || []
            groups.each_with_object({}) do |group, mapping|
              mapping[group] = target_mapping[group]
            end
          end
        end

        def custom_macros
          @custom_macros ||= (config = @config.for_cop('Rails/OrderModelMacros')['Custom'] and config.map(&:to_sym)) || []
        end

        def rails_macros
          @rails_macros ||= (@config.for_cop('Rails/OrderModelMacros')['Rails'].map(&:to_sym) || [])
        end

        def gem_macros
          @gem_macros ||= (config = @config.for_cop('Rails/OrderModelMacros')['Gem'] and config.map(&:to_sym)) || []
        end

        def association_macros
          @association_macros ||= (@config.for_cop('Rails/OrderModelMacros')['PreferredInnerGroupOrdering']['association'].map(&:to_sym) || [])
        end

        def validation_macros
          @validation_macros ||= (@config.for_cop('Rails/OrderModelMacros')['PreferredInnerGroupOrdering']['validation'].map(&:to_sym) || [])
        end
      end
    end
  end
end
