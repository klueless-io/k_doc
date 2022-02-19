# frozen_string_literal: true

module KDoc
  # Builds up key/value settings from the block
  class Settings
    include KLog::Logging

    attr_reader :parent
    attr_reader :key
    attr_reader :decorators
    attr_reader :block

    def initialize(parent, data, key = nil, **opts, &block)
      @parent = parent
      @data = data
      @key = (key || FakeOpinion.new.default_settings_key).to_s
      @data[@key] = {}
      @decorators = build_decorators(opts) # TODO: add tests for decorators
      @block = block
    end

    def fire_eval
      return unless block

      instance_eval(&block)
      run_decorators

      # rubocop:disable Style/RescueStandardError
    rescue => e
      # rubocop:enable Style/RescueStandardError
      log.error("Standard error while running settings for key: #{@key}")
      log.error(e.message)
      raise
    end

    def context
      parent.context
    end

    # Return these settings which are attached to a data container using :key
    # internal_data is a bad name, but it is unlikely to interfere with any setting names
    # Maybe I rename this to raw_data
    def internal_data
      @data[@key]
    end

    def respond_to_missing?(name, *_args, &_block)
      # puts 'respond_to_missing?'
      # puts "respond_to_missing: #{name}"
      n = name.to_s
      n = n[0..-2] if n.end_with?('=')
      internal_data.key?(n.to_s) || (!@parent.nil? && @parent.respond_to?(name, true)) || super
    end

    # rubocop:disable Metrics/AbcSize
    def method_missing(name, *args, &_block)
      # puts "method_missing: #{name}"
      # puts "args.length   : #{args.length}"

      if name != :type && !@parent.nil? && @parent.respond_to?(name)
        puts "Settings.method_missing - NAME: #{name}"
        return @parent.public_send(name, *args, &block)
      end
      raise KDoc::Error, 'Multiple setting values is not supported' if args.length > 1

      add_getter_or_param_method(name)
      add_setter_method(name)

      send(name, args[0]) if args.length == 1 # name.end_with?('=')

      super unless self.class.method_defined?(name)
    end
    # rubocop:enable Metrics/AbcSize

    # Handles Getter method and method with single parameter
    # object.my_name
    # object.my_name('david')
    def add_getter_or_param_method(name)
      # log.progress(1, 'add_getter_or_param_method')
      self.class.class_eval do
        # log.progress(2, 'add_getter_or_param_method')
        name = name.to_s.gsub(/=$/, '')
        # log.progress(3, 'add_getter_or_param_method')
        define_method(name) do |*args|
          # log.progress(4, 'add_getter_or_param_method')
          # log.kv 'add_getter_or_param_method', name
          raise KDoc::Error, 'Multiple setting values is not supported' if args.length > 1

          if args.length.zero?
            get_value(name)
          else
            send("#{name}=", args[0])
          end
        end
      end
    end

    # Handles Setter method
    # object.my_name = 'david'
    def add_setter_method(name)
      # log.progress(1, 'add_setter_method')
      self.class.class_eval do
        # log.progress(2, 'add_setter_method')
        name = name.to_s.gsub(/=$/, '')
        # log.progress(3, 'add_setter_method')
        # log.kv 'add_setter_method', name
        define_method("#{name}=") do |value|
          # log.progress(4, 'add_setter_method')
          # log.kv 'value', value
          internal_data[name.to_s] = value
        end
      end
    end

    def get_value(name)
      internal_data[name.to_s]
    end

    def debug
      puts JSON.pretty_generate(internal_data)
    end

    private

    # This method can move into decorator helpers
    def run_decorators
      decorators.each { |decorator| decorator.decorate(self, :settings) }
    end

    def build_decorators(opts)
      decorator_list = opts[:decorators].nil? ? [] : opts[:decorators]

      decorator_list.map(&:new)
                    .select { |decorator| decorator.compatible?(self) }
    end
  end
end
