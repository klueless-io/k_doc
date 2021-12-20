# frozen_string_literal: true

module KDoc
  # Action is a DSL for modeling JSON data objects
  class Action < KDoc::Container
    attr_reader :file

    # Simple Ruby Action
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_action_type if not set
    # @param default: Default value (using named params), as above
    # @param [Proc] block The block is stored and accessed different types in the document loading workflow.
    def initialize(key = nil, **opts, &_block)
      super(**{ key: key }.merge(opts))
    end

    private

    def default_data_type
      String
    end

    def default_container_type
      :action
    end
  end
end
