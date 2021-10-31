class DesignPatternDirector < Director
  include BuildActions

  def del(file, *_params, **opts)
    delete_file(file, **opts)

    self
  end
  alias dadd del

  def add(output_file, template_file = nil, **opts)
    template_file = output_file if template_file.nil?
      
    opts = {
      template_file: template_file,
      on_exist: :write
    }.merge(opts)

    add_file(output_file, **opts)
    puts output_file

    self
  end

  # This pattern would be great as a configurable generic class
  #
  # children could be renamed as:
  # - directors
  # - components
  # - elements
  def composite(name:, relative_path:, **opts)
    opts = { name: name }.merge(opts)
    cd(:lib)
    add(File.join(relative_path, "#{name}.rb"), "composite/composite.rb", **opts)
    cd(:spec)
    add(File.join(relative_path, "#{name}_spec.rb"), "composite/composite_spec.rb", **opts)
    self
  end
end
