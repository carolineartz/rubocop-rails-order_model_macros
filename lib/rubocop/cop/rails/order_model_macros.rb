module RuboCop
  module Cop
    module Rails
      class OrderModelMacros < Cop
        include RuboCop::Rails::OrderModelMacros::Configuration

        MSG = "Macros are not properly sorted."
        MSG_OUTER_GROUPS = "Macro method groups not sorted. Move %{group1} above %{group2}.".freeze
        MSG_WITHIN_GROUP = "Not sorted within %{type}. Move %{method1} above %{method2}.".freeze

        DEFAULT_SCOPE = :default_scope
        CLASS_METHODS = /^[mc]attr_(reader|writer|accessor)/
        ENUM = :enum
        CALLBACKS = /^(before|around|after)_\w*/
        DELEGATE = :delegate
        SCOPE = :scope

        GROUPED = %i(
          association
          validation
        ).freeze

        def on_class(node)
          _name, superclass, body = *node

          return unless body && body.begin_type?
          return unless superclass && superclass.descendants.any?
          return unless %w(ActiveRecord ApplicationRecord).include?(superclass.descendants.first.const_name)

          targets = target_methods(body)
          return true if correct_grouping?(targets) && correct_within_groups?(targets)

          add_offense(body, :expression, @message || MSG)
        end

        private

        def target_types(targets)
          targets.map { |target| method_type(target) }
        end

        def correct_within_groups?(targets)
          grouped = targets
            .group_by { |target| method_type(target) }
            .keep_if { |type, _targets| GROUPED.include?(type) }

          grouped.all? do |type, targets_for_type|
            ordered_for_type = preferred_group_ordering[type]
            squeezed = squeeze(targets_for_type.map(&:method_name))

            mixed = squeezed != squeezed.uniq

            a = (ordered_for_type & squeezed)
            b = (squeezed & ordered_for_type)

            a = squeezed.drop_while { |el| squeezed.count(el) > 1 } if mixed

            a == b or set_within_group_error_message(type, a, b) && false
          end
        end

        def plural_form(group)
          group.to_s + "s"
        end

        def correct_grouping?(targets)
          target_types = target_types(targets)
          return false unless single_groups?(target_types)

          type_order = preferred_group_ordering.keys
          squeezed = squeeze(target_types)

          a = type_order & squeezed
          b = squeezed & type_order

          a == b or set_outer_group_error_message(a, b) && false
        end

        def single_groups?(targets)
          squeeze(targets) == targets.uniq
        end

        def squeeze(targets)
          targets.each_with_object([]) do |el, squeezed|
            squeezed << el unless squeezed.last == el
          end
        end

        def target_methods(body)
          body.children.compact.select(&method(:match)).map(&method(:match))
        end

        def match(child)
          return child if child.send_type? && matches_targets?(child.method_name)
          child.children && child.children.first && match(child.children.first)
        end

        def matches_targets?(declared)
          all_targets[:regexps].any? { |regex| regex === declared } || all_targets[:names].include?(declared)
        end

        def all_targets
          types = preferred_group_ordering
            .values
            .flatten
            .partition { |target_type| target_type.is_a?(Regexp) }

          {
            regexps: types.first, # array of Regexps
            names: types.last # array of Symbols
          }
        end

        def target_mapping
          {
            default_scope: DEFAULT_SCOPE,
            class_method: CLASS_METHODS,
            enum: ENUM,
            association: association_macros,
            validation: validation_macros,
            callback: CALLBACKS,
            delegate: DELEGATE,
            rails: rails_macros,
            gem: gem_macros,
            custom: custom_macros,
            scope: SCOPE
          }
        end

        def method_type(target)
          case target.method_name
          when DEFAULT_SCOPE          then :default_scope
          when CLASS_METHODS          then :class_method
          when ENUM                   then :enum
          when CALLBACKS              then :callback
          when DELEGATE               then :delegate
          when SCOPE                  then :scope
          when *association_macros    then :association
          when *custom_macros         then :custom
          when *gem_macros            then :gem
          when *rails_macros          then :rails
          when *validation_macros     then :validation
          else raise "Unreachable code"
          end
        end

        def set_outer_group_error_message(a, b)
          first_error = a.zip(b).find { |x, y| x != y }
          @message = MSG_OUTER_GROUPS % {group1: plural_form(first_error.first), group2: plural_form(first_error.last)}
        end

        def set_within_group_error_message(type, a, b)
          first_error = a.zip(b).find { |x, y| x != y }
          @message = MSG_WITHIN_GROUP % {type: plural_form(type), method1: first_error.first, method2: first_error.last}
        end
      end
    end
  end
end
