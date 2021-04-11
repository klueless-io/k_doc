# frozen_string_literal: true

class SetDbTypeTableDecorator < KDoc::Decorators::TableDecorator
  def initialize
    super(:update_rows)
  end

  def update_rows(_target, rows)
    rows.each do |row|
      next unless row['db_type'].nil?

      row['db_type'] = case row['type']
                       when 'int'
                         'INTEGER'
                       else
                         'VARCHAR'
                       end
    end
  end
end
