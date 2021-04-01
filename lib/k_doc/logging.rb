# frozen_string_literal: true

require 'k_log'
module KDoc
  module Logging
    def log
      @log ||= KLog.logger
    end
  end
end
