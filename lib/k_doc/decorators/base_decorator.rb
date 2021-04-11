# frozen_string_literal: true

# This could move into KDecor
require 'delegate'
module KDoc
  module Decorators
    class BaseDecorator
      include KLog::Logging

      # Compatible type will store the Object Type that this decorator
      # is suitable for processing
      attr_accessor :compatible_type
      
      # What behaviors are available to this decorator, any base decorator 
      # may be called from multiple places with slightly different behaviors.
      #
      # These behaviors can be listed on the base class and they provide
      # some safety against calling child decorators incorrectly.
      attr_accessor :available_behaviors

      # What are the specific behaviors of this decorator
      #
      # If you wish to use a decorator to run against a compatible data type
      # and not worry about what method fired the decorator then leave
      # the behavior as :all
      #
      # But if this decorator type only targets certain behaviors then give it a
      # specific :behavior to perform. e.g. KDoc::Decorators::TableDecorator can
      # be responsible for updating rows, fields or both.
      attr_accessor :implemented_behaviors

      def initialize(compatible_type)
        @compatible_type = compatible_type
        @available_behaviors = [:default]
        @implemented_behaviors = []
      end

      # Does the decorator implement the behavior
      def has_behavior?(behavior) #, any = false)
        # (any == true && behaviors.include?(:all)) || 
        behaviors.include?(behavior)
        # required_behaviors.any? { |required_behavior| behaviors.include?(required_behavior) }
      end

      def compatible?(target)
        target.is_a?(compatible_type)
      end

      def decorate(target, behavior = :all)
        raise KType::Error, "#{self.class} is incompatible with data object" unless compatible?(target)
        raise KType::Error, "#{self.class} has not implemented an update method" unless respond_to?(:update)

        update(target, behavior)
      end
    end
  end
end
