# frozen_string_literal: true

require 'json'

module KDoc
  # Builds up key/value settings from the block
  # and applies them to a key coded node on the hash
  class Settings
    include KLog::Logging

    attr_reader :parent
    attr_reader :key

    alias kp parent

    def initialize(data, key = nil, **options, &block)
      initialize_attributes(data, key, **options)

      # Need a way to find out the line number for errors and report it correctly
      begin
        instance_eval(&block) if block_given?
        # rubocop:disable Style/RescueStandardError
      rescue => e
        # rubocop:enable Style/RescueStandardError
        puts "Invalid code block in settings_dsl: #{@key}"
        puts e.message
        raise
      end
    end

    def my_data
      @data[@key]
    end

    # def run_decorators(opts)
    #   decorators = KDoc::Decorator.decorate.decorators(opts[:decorators])

    #   return if decorators.empty?

    #   decorators.each do |decorator|
    #     decorator.send(:update, my_data) if decorator.respond_to?(:update)
    #     decorator.send(:call, my_data) if decorator.respond_to?(:call)
    #   end
    # end

    def respond_to_missing?(name, *_args, &_block)
      # puts 'respond_to_missing?'
      # puts "respond_to_missing: #{name}"
      n = name.to_s
      n = n[0..-2] if n.end_with?('=')
      my_data.key?(n.to_s) || (!@parent.nil? && @parent.respond_to?(name, true)) || super
    end

    # rubocop:disable Metrics/AbcSize
    def method_missing(name, *args, &_block)
      # puts "method_missing: #{name}"
      # puts "args.length   : #{args.length}"

      if name != :type && !@parent.nil? && @parent.respond_to?(name)
        puts "NAME: #{name}"
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
          my_data[name.to_s] = value
        end
      end
    end

    def get_value(name)
      my_data[name.to_s]
    end

    def debug
      puts JSON.pretty_generate(my_data)
    end

    private

    def initialize_attributes(data, key = nil, **options)
      @data = data
      @key = (key || FakeOpinion.new.default_settings_key).to_s

      @parent = options[:parent] if !options.nil? && options.key?(:parent)

      @data[@key] = {}
    end
  end
end
