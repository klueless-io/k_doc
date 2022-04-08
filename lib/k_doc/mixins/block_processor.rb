# frozen_string_literal: true

module KDoc
  # Provide data load events, dependency and import management
  #
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
    attr_reader :children

    # TODO: Can dependencies be extracted to their own module?
    attr_reader :depend_on_tags
    attr_reader :dependents

    def initialize_block_processor(_opts, &block)
      @block = block if block_given?
      @block_state = :new

      @init_block = nil
      @action_block = nil
      @children = []

      @depend_on_tags = []
      @dependents = {}
      @block_executed = false
    end

    def depend_on(*document_tags)
      document_tags.each do |document_tag|
        @depend_on_tags << document_tag
      end
    end

    def resolve_dependency(document)
      @dependents[document.tag] = document
    end

    def import(tag)
      @dependents[tag]
    end

    def import_data(tag, as: :document)
      doc = import(tag)

      return nil unless doc&.data

      # log.error 'about to import'
      doc.debug(include_header: true)

      return KUtil.data.to_open_struct(doc.data) if %i[open_struct ostruct].include?(as)

      doc.data
    end

    def dependencies_met?
      depend_on_tags.all? { |tag| dependents[tag] }
    end

    def execute_block(run_actions: false)
      block_execute
      fire_action if run_actions
    end

    def block_execute
      return if @block_executed

      # Evaluate the main block of code
      fire_eval # aka primary eval

      return unless dependencies_met?

      # Call the block of code attached to the init method
      fire_init

      # Call the each block in the child array of blocks in the order of creation (FIFO)
      fire_children

      @block_executed = true
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
      @children << block
    end

    # Run blocks associated with the children
    #
    # A child can follow one of three patterns:
    # 1. A block that is evaluated immediately against the parent class
    # 2. A class that has its own custom block evaluation
    # 3. A class that has a block which will be evaluated immediately against the child class
    # rubocop:disable Metrics/AbcSize
    def fire_children
      return unless initialized?

      children.each do |child|
        if child.is_a?(Proc)
          instance_eval(&child)
        elsif child.respond_to?(:fire_eval)
          child.fire_eval
        elsif child.respond_to?(:block)
          child.instance_eval(&child.block)
        end
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
    # rubocop:enable Metrics/AbcSize

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
