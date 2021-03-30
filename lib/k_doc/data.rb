# frozen_string_literal: true

# module KDoc
#   # TODO
#   # Missing tests around errors
#   # Make sure that error writes to resource or document appropriately
#   # Puts errors onto a project manager pipeline so that they can be be printed out after the documents
#   #
#   # General purpose document DSL
#   #
#   # Made up of 0 or more setting groups and table groups
#   class Data
#     extend Forwardable

#     attr_reader :key
#     attr_reader :type
#     attr_reader :namespace
#     attr_reader :options
#     attr_reader :error

#     # State of document
#     # - :initializing
#     # - :initialized
#     # - :loading
#     # - :loaded
#     # - :executing
#     # - :executed
#     attr_reader :state

#     # Shortcut to formatter
#     attr_reader :f

#     attr_accessor :resource

#     def_delegator :resource, :project

#     def state=(state)
#       @state = state
#       # if [:initialized, :loaded, :executed].include?(state) &&
#       #   (project.nil? || project.name == 'k_dsl')
#       #   # pname = project.nil? ? '' : "#{project&.name} "
#       #   L.kv "#{unique_key} - state", state
#       # end
#       @state
#     end

#     # Create document
#     #
#     # @param [String|Symbol] name Name of the document
#     # @param args[0] Type of the document, defaults to KDsl.config.default_document_type if not set
#     # @param default: Default value (using named params), as above
#     def initialize(key = SecureRandom.alphanumeric(8), *args, **options, &block)
#       @key = key
#       @type = args.length.positive? ? args[0] || KDsl.config.default_document_type : KDsl.config.default_document_type

#       @options = options || {}
#       @namespace = options[:namespace] || ''
#       default_data = options[:default_data] || {}

#       @namespace = @namespace.to_s
#       @error = nil

#       self.state = :initializing

#       # Most documents live within a hash, some tabular documents such as
#       # CSV will use an []
#       set_data(default_data)

#       @f = KDsl::Util.format

#       @block = block if block_given?

#       self.state = :initialized
#     end

#     def execute_block(run_actions: nil)
#       return if @block.nil?

#       # The DSL actions method will only run on run_actions: true
#       @run_actions = run_actions

#       # if unique_key == 'template_options_entity'
#       #   L.kv '2:CLASS_ID', object_id
#       # end
#       if initialized?
#         self.state = :loading
#         instance_eval(&@block)
#         self.state = :loaded
#       end
#       # if unique_key == 'template_options_entity'
#       #   L.kv '3:CLASS_ID', resource_document.object_id
#       # end

#       if loaded? && run_actions && respond_to?(:on_action)
#         @state = :executed
#         on_action
#       end
#     rescue KDsl::Error => e
#       L.error('KDsl::Error in document')
#       L.kv 'key', unique_key
#       L.kv 'file', KDsl::Util.data.console_file_hyperlink(resource.file, resource.file)
#       L.error(e.message)
#       @error = e
#       # L.heading "Invalid code block in document_dsl during registration: #{k_key}"
#       # L.exception exception
#       raise
#     rescue StandardError => e
#       L.error('Standard error in document')
#       L.kv 'key', unique_key
#       L.kv 'file', KDsl::Util.data.console_file_hyperlink(resource.file, resource.file)
#       L.error(e.message)
#       @error = e
#       # L.exception exception2
#       raise
#     ensure
#       @run_actions = nil
#       return
#     end

#     def initialized?
#       @state == :initialized
#     end

#     def loaded?
#       @state == :loaded
#     end

#     def executed?
#       @state == :executed
#     end

#     def unique_key
#       @unique_key ||= KDsl::Util.dsl.build_unique_key(key, type, namespace)
#     end

#     def settings(key = nil, **options, &block)
#       options ||= {}

#       opts = {}.merge(@options) # Document Options
#                .merge(options)  # Settings Options

#       settings = settings_instance(@data, key, parent: self, &block)
#       settings.run_decorators(opts)
#       settings
#     end

#     def table(key = :table, &block)
#       # NEED to add support for run_decorators I think
#       table_instance(@data, key, parent: self, &block)
#     end
#     alias rows table

#     # Sweet add-on would be builders
#     # def builder(key, &block)
#     #   # example
#     #   KDsl::Builder::Shotstack.new(@data, key, &block)
#     # end

#     def set_data(data)
#       @data = data
#     end

#     def data
#       @data.clone
#     end

#     def data_struct
#       KDsl::Util.data.to_struct(data)
#     end
#     alias d data_struct

#     def raw_data_struct
#       KDsl::Util.data.to_struct(raw_data)
#     end

#     def get_node_type(node_name)
#       node_name = KDsl::Util.data.clean_symbol(node_name)
#       node_data = @data[node_name]

#       raise KDsl::Error, "Node not found: #{node_name}" if node_data.nil?

#       if node_data.keys.length == 2 && (node_data.key?('fields') && node_data.key?('rows'))
#         :table
#       else
#         :settings
#       end
#     end

#     # Removes any meta data eg. "fields" from a table and just returns the raw data
#     def raw_data
#       # REFACT, what if this is CSV, meaning it is just an array?
#       #         add specs
#       result = data

#       result.each_key do |key|
#         # ANTI: get_node_type uses @data while we are using @data.clone here
#         data[key] = if get_node_type(key) == :table
#                       result[key].delete('fields')
#                     else
#                       result[key]
#                     end
#       end

#       data
#     end

#     # Move this out to the logger function when it has been refactor
#     def debug(include_header = false)
#       debug_header if include_header

#       # tp dsls.values, :k_key, :k_type, :state, :save_at, :last_at, :data, :last_data, :source, { :file => { :width => 150 } }
#       # puts JSON.pretty_generate(data)
#       L.o(raw_data_struct)
#     end

#     def debug_header
#       L.heading self.class.name
#       L.kv 'key', key
#       L.kv 'type', type
#       L.kv 'namespace', namespace
#       L.kv 'error', error
#       L.kv 'state', state
#       L.kv 'respond_to?(:on_import)', respond_to?(:on_import)
#       L.kv 'respond_to?(:david)', respond_to?(:david)
#       david if respond_to?(:david)
#       # L.kv 'INITALIZED', resource_document.initialized?
#       # L.kv 'EXECUTED', resource_document.executed?

#       options&.keys.reject { |k| k == :namespace }&.each do |key|
#         L.kv key, options[key]
#       end

#       L.line
#     end

#     # Helpers that often get called by extensions

#     def project
#       project ||= resource&.project
#     end

#     # Warning message
#     def warn(message)
#       L.warn message
#       nil
#     end

#     private

#     def settings_instance(data, key, **options, &block)
#       KDsl.config.settings_class.new(data, key, **options, &block)
#     end

#     def table_instance(data, key, **options, &block)
#       KDsl.config.table_class.new(data, key, **options, &block)
#     end
#   end
# end
