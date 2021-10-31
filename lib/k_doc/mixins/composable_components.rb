# frozen_string_literal: true

module KDoc
  # Composite Design Pattern: https://refactoring.guru/design-patterns/composite
  module ComposableComponents
    # Parent allows upwards navigation to parent component
    attr_reader :parent

    # Components allow downwards navigation plus access to sub-components
    attr_reader :components

    def attach_parent(parent)
      @parent = parent
    end

    def navigate_parent
      parent.nil? ? self : parent
    end

    def root?
      parent.nil?
    end

    # Implement as needed (Implement is not provided here because you may want to use hash or array and have additional logic)
    # def reset_components
    # end
    # def add_component
    # end
    # def remove_component
    # end
    # def get_components
    # end
    # def has_component?
    # end
    # def execute
    # end
  end
end
