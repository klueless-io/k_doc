# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data that requires tagging
  # such as unique key, type and namespace.
  # Rename: BlockProcessor
  module BlockProcessor
    attr_accessor :block

    def initialize_block(_opts, &block)
      @block = block if block_given?
    end

    def execute_block(run_actions: nil)
      eval_block
      run_on_action if run_actions
    end

    def eval_block
      return if @block.nil?
      instance_eval(&@block)
    rescue StandardError => e
      log.error('Standard error in document')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end

    def run_on_action
      return if @block.nil?
      on_action if respond_to?(:on_action)
    rescue StandardError => e
      log.error('Standard error while running actions')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end
  end
end
