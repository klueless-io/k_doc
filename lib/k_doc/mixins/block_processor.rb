# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data that requires tagging
  # such as unique key, type and namespace.
  #
  # example usage of the container using model as the basis:
  #   KDoc.model do
  #     init do
  #       context.some_data = :xmen
  #     end
  #     settings do
  #       name context.some_data
  #     end
  #     action
  #       puts context.some_data
  #     end
  #   end
  module BlockProcessor
    include KLog::Logging

    attr_reader :block
    attr_reader :block_state

    attr_reader :init_block
    attr_reader :action_block
    attr_reader :child_blocks

    def initialize_block_processor(_opts, &block)
      @block = block if block_given?
      @block_state = :new

      @init_block = nil
      @action_block = nil
      @child_blocks = []
    end

    def execute_block(run_actions: false)
      # Evaluate the main block of code
      fire_eval # aka primary eval

      # Call the block of code attached to the init method
      fire_init

      # Call the each block in the child array of blocks in the order of creation (FIFO)
      fire_children_eval

      # Call the block of code attached to the action method
      fire_action if run_actions
    end

    # The underlying container is created and in the case of k_manager, registered
    def new?
      @block_state == :new
    end

    # The main block has been evaluated, but child blocks are still to be processed
    def evaluated?
      @block_state == :evaluated || initialized?
    end

    # Has the init block been called?
    def initialized?
      @block_state == :initialized || children_evaluated?
    end

    # The block and the data it represents has been evaluated.
    def children_evaluated?
      @block_state == :children_evaluated || actioned?
    end

    # The on_action method has been called.
    def actioned?
      @block_state == :actioned
    end

    def fire_eval
      return unless new?

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

    def init(&block)
      @init_block = block
    end

    def fire_init
      return unless evaluated?

      instance_eval(&init_block) if init_block

      @block_state = :initialized
    rescue StandardError => e
      log.error('Standard error in document on_init')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end

    def add_child(block)
      @child_blocks << block
    end

    def fire_children_eval
      return unless initialized?

      child_blocks.each do |block|
        instance_eval(&block)
      end

      @block_state = :children_evaluated
    rescue StandardError => e
      log.error('Standard error in document with one of the child blocks')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      raise
    end

    def action(&block)
      @action_block = block
    end

    def fire_action
      return unless children_evaluated?

      if action_block
        instance_eval(&action_block)
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

    # rubocop:disable Metrics/AbcSize
    def debug_block_processor
      log.kv 'block_state'        , block_state         , debug_pad_size
      log.kv 'new'                , new?                , debug_pad_size
      log.kv 'evaluated'          , evaluated?          , debug_pad_size
      log.kv 'children_evaluated' , children_evaluated? , debug_pad_size
      log.kv 'actioned'           , actioned?           , debug_pad_size
    end
    # rubocop:enable Metrics/AbcSize
  end
end
