class Director
  include KType::Composite
  # Should this be on the base class, or setup as needed on child directors?

  attr_reader :builder

  # Maybe Deprecate
  attr_reader :director_types

  def initialize(parent = nil, **opts)
    attach_parent(parent)

    reset_settings
    process_options(opts)
  end

  def init(opts)
    reset_settings
    process_options(opts)
    
    self
  rescue => ex
    log.exception(ex)
  end

  def reset
    reset_settings

    self
  rescue => ex
    log.exception(ex)
  end

  def register(name, klass)
    register_director(name, klass)

    self
  rescue => ex
    log.exception(ex)
  end

  def back
    navigate_parent
  end

  def with(director, &block)
    change_director = director(director)
    change_director.instance_eval(&block)
    navigate_parent
  end

  def help(*topics) #**opts)
    if topics.blank?
      help_actions
      return
    end

    help_actions          if topics.include?(:all)
    help_channels         if topics.include?(:channels)
  rescue => ex
    log.exception(ex)
  end

  def director(name)
    @director ||= Hash.new do |add_to_hash, key|
      raise "Director not registered: #{key}" unless has_child?(key)
      director = get_child(key)
      add_to_hash[key] = director.klass.new(self).init(builder_config_name: key)
    end
    @director[name]
  rescue => ex
    log.exception(ex)
  end

  def guard(message)
    log.error(message)

    self
  end
  

  # def director(type, name)
  #   Setup.config(type).debug
  # end

  def debug
    # puts 'debug'
    # puts children
    # puts director_types
    if builder
      builder.debug
    else
      log.error "No builder"
    end

    director_types.keys.each do |key|
      log.section_heading(key)
      log.structure director_types[key]
    end
    
    self
  end

  private

  # Composite Pattern Custom Implementation - BEGIN

  def has_child?(key)
    @children.key?(key)
  end

  def get_child(key)
    @children[key]
  end

  def add_child(key, child)
    @children[key] = child
  end

  def reset_children
    @children = {}
  end

  # Composite Pattern Custom Implementation - END

  def register_director(name, klass)
    if has_child?(name)
      log.error "Director has already been registered: #{name}"
      return
    end

    add_director(name, klass)
  rescue => ex
    log.exception(ex)
  end

  def add_director(name, klass)
    director = OpenStruct.new(name: name, klass: klass)

    # Adding a director should create a new method for accessing that director
    add_child(name, director)
  rescue => ex
    log.exception(ex)
  end

  # HELP

  def help_actions
    log.warn 'Help about actions available from this class'
  end

  def help_channels
    log.warn 'Help about channels'
    debug
  end

  def reset_settings
    @builder = nil
    reset_children
    @director_types = {}
  end

  def process_options(opts)
    attach_builder(opts)
  rescue => ex
    log.exception(ex)
  end

  # If builder is provided then use it
  # If builder configuration is provided
  # If builder config_name is provided

  def attach_builder(opts)
    return if @builder

    log.warning("options :builder and :builder_config_name are mutually exclusive, will use opts[:builder]") if opts[:builder] && opts[:builder_config_name]

    # Use the provided builder
    @builder = opts[:builder] if opts[:builder]

    return if @builder

    @builder = KBuilder::BaseBuilder.init(KConfig.configuration(opts[:builder_config_name]))
  end
end
