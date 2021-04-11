# frozen_string_literal: true

# REFACTOR: I need to support both rows and fields as different decorators
#           because fields need to set before rows are added
#       and rows need to be setup after rows are added
class SetEntityFieldsTableDecorator < KDoc::Decorators::TableDecorator
  def initialize
    super(:update_fields)
  end

  def update_fields(target, fields)
    fields.clear
    fields << target.f(:name)
    fields << target.f(:type, :string)
    fields << target.f(:db_type, 'VARCHAR')
  end
end
