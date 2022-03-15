KManager.action :domain_diagram do
  action do

    # :rounded, :shadow, :sketch, :glass
    director = DrawioDsl::Drawio
      .init(k_builder, on_exist: :write, on_action: :execute)
      .diagram(theme: :style_02)
      .page('Style-Plain', margin_left: 0, margin_top: 0, background: '#fafafa') do
        grid_layout(wrap_at: 4)
        container(title: 'Container')
        container(title: 'CSV Doc')
        container(title: 'JSON Doc')
        container(title: 'YAML Doc')
        container(title: 'Model')
        container(title: 'Settings')
        container(title: 'Table')

        container(title: 'Mixins')
        container(title: 'Block Processor')
        container(title: 'Composable Components')
        container(title: 'Datum')
        container(title: 'Guarded')
        container(title: 'Taggable')

        container(title: 'Decorators')
        container(title: 'Settings Decorator')
        container(title: 'Table Decorator')
      end
      .cd(:docs)
      .save('domain.drawio')
      # .export_svg('project_in_progress', page: 1)

  end
end

KManager.opts.app_name                    = 'domain_diagram'
KManager.opts.sleep                       = 2
KManager.opts.reboot_on_kill              = 0
KManager.opts.reboot_sleep                = 4
KManager.opts.exception_style             = :short
KManager.opts.show.time_taken             = true
KManager.opts.show.finished               = true
KManager.opts.show.finished_message       = 'FINISHED :)'
