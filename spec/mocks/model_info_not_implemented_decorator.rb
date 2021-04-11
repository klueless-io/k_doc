# frozen_string_literal: true

require 'mocks/model_info'

class ModelInfoNotImplementedDecorator < KDoc::Decorators::BaseDecorator
  def initialize
    super(ModelInfo)
  end
end
