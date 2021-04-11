# frozen_string_literal: true

require 'mocks/model_info'

class ModelAccount < ModelInfo
  def initialize
    super({ model: 'Account' })
  end
end
