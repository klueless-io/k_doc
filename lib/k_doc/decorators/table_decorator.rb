# frozen_string_literal: true

module KDoc
  module Decorators
    class TableDecorator < KDecor::BaseDecorator
      def initialize
        super(KDoc::Table)

        self.implemented_behaviours = %i[update_fields update_rows]
      end

      def update(target, **opts)
        behaviour = opts[:behaviour]

        update_fields(target, target.get_fields)  if %i[all update_fields].include?(behaviour)
        update_rows(target, target.get_rows)      if %i[all update_rows].include?(behaviour)

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
