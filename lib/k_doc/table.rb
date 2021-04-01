# frozen_string_literal: true

module KDoc
  # Build rows (aka DataTable) with field definitions and rows of data
  class Table
    attr_reader :parent
    attr_reader :name

    def initialize(data, name = nil, **options, &block)
      initialize_attributes(data, name, **options)

      instance_eval(&block) if block_given?
    end

    def fields(field_definitions)
      fields = @data[@name]['fields']

      field_definitions.each do |fd|
        fields << if fd.is_a?(String) || fd.is_a?(Symbol)
                    field(fd, nil, :string)
                  else
                    fd
                  end
      end
    end

    # rubocop:disable Metrics/AbcSize
    def row(*args, **named_args)
      fields = @data[@name]['fields']

      raise "To many values for row, argument #{i}" if args.length > fields.length

      # Apply column names with defaults
      row = fields.each_with_object({}) do |f, hash|
        hash[f['name']] = f['default']
      end

      # Override with positional arguments
      args.each_with_index do |arg, i|
        row[fields[i]['name']] = KUtil.data.clean_symbol(arg)
      end

      # Override with named args
      named_args.each_key do |key|
        row[key.to_s] = named_args[key]
      end

      @data[@name]['rows'] << row
      row
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Naming/AccessorMethodName
    def get_fields
      @data[@name]['fields']
    end

    def get_rows
      @data[@name]['rows']
    end
    # rubocop:enable Naming/AccessorMethodName

    def find_row(key, value)
      @data[@name]['rows'].find { |r| r[key] == value }
    end

    # Field definition
    #
    # @param [String|Symbol] name Name of the field
    # @param args[0] Default value if not specified, nil if not set
    # @param args[1] Type of data, string if not set
    # @param default: Default value (using named params), as above
    # @param type: Type of data (using named params), as above
    # @return [Hash] Field definition
    def field(name, *args, default: nil, type: nil)
      # default value can be found at position 0 or default: tag (see unit test edge cases)
      default_value = if args.length.positive?
                        args[0].nil? ? default : args[0]
                      else
                        default
                      end

      # type can be found at position 1 or type: tag
      type_value = (args.length > 1 ? args[1] : type) || :string

      {
        'name' => KUtil.data.clean_symbol(name),
        'default' => KUtil.data.clean_symbol(default_value),
        'type' => KUtil.data.clean_symbol(type_value)
      }
    end
    alias f field

    private

    def initialize_attributes(data, name = nil, **options)
      @data = data
      @name = (name || FakeOpinion.new.default_table_key.to_s).to_s

      @parent = options[:parent] if !options.nil? && options.key?(:parent)

      @data[@name] = { 'fields' => [], 'rows' => [] }
    end

    def respond_to_missing?(name, *_args, &_block)
      (!@parent.nil? && @parent.respond_to?(name, true)) || super
    end

    def method_missing(name, *args, &block)
      return super unless @parent.respond_to?(name)

      @parent.public_send(name, *args, &block)
    end
  end
end
