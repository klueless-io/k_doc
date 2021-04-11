# frozen_string_literal: true

require 'mocks/model_info'

class ModelInfoDecorator < KDoc::Decorators::BaseDecorator
  def initialize
    super(ModelInfo)

    @implemented_behaviors = [:default]
  end

  def update(target, _behavior)
    target
  end
end
