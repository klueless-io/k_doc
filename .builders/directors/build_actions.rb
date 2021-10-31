module BuildActions
  def cd(folder_key)
    @builder.cd(folder_key)

    self
  end

  def add_file(file, **opts)
    @builder.add_file(file, **opts)

    self
  end

  def delete_file(file, **opts)
    @builder.delete_file(file, **opts)

    self
  end

  def add_clipboard(**opts)
    @builder.add_clipboard(**opts)

    self
  end

  def open
    builder.open

    self
  end
  alias o open

  def open_template
    builder.open_template

    self
  end
  alias ot open_template
end