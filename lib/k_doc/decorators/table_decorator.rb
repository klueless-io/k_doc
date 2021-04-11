# frozen_string_literal: true

# This could move into KDecor
module KDoc
  module Decorators
    class TableDecorator < BaseDecorator
      def initialize()
        super(KDoc::Table)

        self.available_behaviors = [:update_fields, :update_rows]
        self.implemented_behaviors = []
      end

      def update(target, behavior)
        update_fields(target, target.get_fields)  if behavior == :all || behavior == :update_fields
        update_rows(target, target.get_rows)      if behavior == :all || behavior == :update_rows

        target
      end

      # What responsibility will this TableDecorator take on?
      # Update fields/columns, or/and
      def update_fields(_target, _fields)
        raise KType::Error, 'Update fields not implement, you need to implement this method and '
      end

      # Update row values/structure
      def update_rows(_target, _rows); end
    end
  end
end
