# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data that requires tagging
  # such as unique key, type and namespace.
  # Rename: BlockProcessor
  module BlockProcessor
    attr_accessor :block
    attr_accessor :block_state

    # Proc/Handler to be called before evaluating when importing data
    attr_reader :on_init

    def initialize_block(opts, &block)
      @block = block if block_given?
      @block_state = :new
      @on_init = opts.delete(:on_init)
    end

    def evaluated?
      @block_state == :evaluated || @block_state == :actioned
    end

    def actioned?
      @block_state == :actioned
    end

    def execute_block(run_actions: nil)
      run_on_init

      # return unless dependencies_met?

      eval_block
      run_on_action if run_actions
    end

    def run_on_init
      instance_eval(&on_init) if on_init

      @block_state = :initialized
    rescue StandardError => e
      log.error('Standard error in document on_init')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end

    def eval_block
      instance_eval(&block) if block

      @block_state = :evaluated
    rescue StandardError => e
      log.error('Standard error in document')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end

    def run_on_action
      return unless block

      if respond_to?(:on_action)
        on_action
        @block_state = :actioned
      end
    rescue StandardError => e
      log.error('Standard error while running actions')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end

    def debug_block_processor
      log.kv 'block_state', block_state       , debug_pad_size if respond_to?(:block_state)
      log.kv 'evaluated'  , evaluated?        , debug_pad_size if respond_to?(:evaluated?)
      log.kv 'actioned'   , actioned?         , debug_pad_size if respond_to?(:actioned?)
    end
  end
end
