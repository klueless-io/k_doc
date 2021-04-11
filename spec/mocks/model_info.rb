# frozen_string_literal: true

class ModelInfo
  attr_accessor :data

  def initialize(data = nil)
    @data = if data.nil?
              {
                model: 'Person'
              }
            else
              data
            end
  end

  def model
    @data[:model]
  end

  def model_plural
    @data[:model_plural]
  end
end
