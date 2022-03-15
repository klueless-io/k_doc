      #   interface(theme: :style_02) do
      #     format
      #       .header('IPerson')
      #       .field(:field1, type: :string)
      #       .field(:field2, type: :string)
      #       .method(:full_name, type: :string)
      #   end

      #   klass do
      #     format(:class)
      #       .header('Person')
      #       .field(:field1, type: :string)
      #       .field(:field2, type: :string)
      #       .field(:age, type: :integer)
      #       .field(:birthday, type: :date)
      #       .method(:full_name, type: :string)
      #   end
      # end
      # .cd(:spec)
      # .save('.samples/30-html-shapes.drawio')
      # .cd(:docs)
      # .export_svg('samples/html-shapes', page: 1)
KManager.action :domain_diagram do
  action do

    DrawioDsl::Drawio
      .init(k_builder, on_exist: :write, on_action: :execute)
      .diagram(theme: :style_04)
      .page('Style-Plain', margin_left: 0, margin_top: 0, rounded: 0, background: '#fafafa') do
        grid_layout(wrap_at: 6)

        klass do
          format
            .header('Container', description: 'A container acts a base data object for any data that requires tagging')
        end
        interface(theme: :style_02) do
          format
            .header('Block Processor', interface_type: 'MixIn', description: 'Provide data load events, dependency and import management')
        end
        interface(theme: :style_02) do
          format
            .header('Composable Components', interface_type: 'MixIn')
        end
        interface(theme: :style_02) do
          format
            .header('Datum', interface_type: 'MixIn', description: 'Data acts as a base data object containers')
        end
        interface(theme: :style_02) do
          format
            .header('Guarded', interface_type: 'MixIn', description: 'Guarded provides parameter warning and guarding')
        end
        interface(theme: :style_02) do
          format
            .header('Taggable', interface_type: 'MixIn', description: 'Provide tagging functionality to the underlying model')
        end
        
        square(title: 'Documents', theme: :style_01)
        klass do
          format
            .header('Action', description: 'Action is a DSL for modeling JSON data objects')
        end
        klass do
          format
            .header('Container', description: 'A container acts a base data object for any data that requires tagging')
            .field(:context, type: :open_struct)
            .field(:owner, type: :object)
            .field(:default_container_type)
            .field(:default_data_type)
        end
        klass do
          format
            .header('CSV Doc', description: 'CsvDoc is a DSL for modeling CSV data objects')
            .field(:file, type: :string)
            .field(:loaded?)
            .method(:load)
        end
        klass do
          format
            .header('JSON Doc', description: 'JsonDoc is a DSL for modeling JSON data objects')
            .field(:file, type: :string)
            .field(:loaded?)
            .method(:load)
        end
        klass do
          format
            .header('YAML Doc', description: 'YamlDoc is a DSL for modeling YAML data objects')
            .field(:file, type: :string)
            .field(:loaded?)
            .method(:load)
        end
        klass do
          format
            .header('Model')
            .field(:odata, type: :open_struct)
            .field(:oraw, type: :open_struct)
            .method(:settings)
            .method(:table)
        end
        klass do
          format
            .header('Settings')
            .field(:parent, type: :object)
            .field(:key, type: :string)
            .field(:decorators, type: :array)
            .field(:block, type: :proc)
            .field(:context)
            .field(:internal_data)
            .method(:fire_eval)
        end
        klass do
          format
            .header('Table')
            .field(:parent, type: :object)
            .field(:key, type: :string)
            .field(:decorators, type: :array)
            .field(:block, type: :proc)
            .field(:context)
            .field(:internal_data)
            .method(:fire_eval)
        end

        square(title: 'Mixins', theme: :style_01)

        interface(theme: :style_02) do
          format
            .header('Block Processor', interface_type: 'MixIn', description: 'Provide data load events, dependency and import management')
            .field(:block, type: :proc)
            .field(:block_state, type: :symbol)
            .field(:init_block, type: :proc)
            .field(:action_block, type: :proc)
            .field(:children, type: :array)
            .field(:depend_on_tags, type: :array)
            .field(:dependents, type: :array)
            .method(:depend_on)
            .method(:resolve_dependency)
            .method(:import)
            .method(:import_data)
            .method(:dependencies_met)
            .method(:execute_block)
            .method(:block_execute)
            .method(:new)
            .method(:evaluated)
            .method(:initialized)
            .method(:children_evaluated)
            .method(:actioned)
            .method(:fire_eval)
            .method(:init)
            .method(:fire_init)
            .method(:add_child)
            .method(:fire_children)
            .method(:action)
            .method(:fire_action)
        end
        interface(theme: :style_02) do
          format
            .header('Composable Components', interface_type: 'MixIn')
        end
        # # Data acts as a base data object containers
        # module Datum
        # def default_data_type
        # def set_data(value, data_action: :replace)
        interface(theme: :style_02) do
          format
            .header('Datum', interface_type: 'MixIn', description: 'Data acts as a base data object containers')
            .field(:default_data_type)
            .method(:set_data)
        end
        interface(theme: :style_02) do
          format
            .header('Guarded', interface_type: 'MixIn', description: 'Guarded provides parameter warning and guarding')
            .field(:errors)
            .field(:error_messages)
            .field(:error_hash)
            .field(:valid?)
            .method(:guard)
            .method(:warn)
        end
        interface(theme: :style_02) do
          format
            .header('Taggable', interface_type: 'MixIn', description: 'Provide tagging functionality to the underlying model')
            .field(:tag_options)
            .field(:tag)
            .field(:key)
            .field(:type)
            .field(:project)
            .field(:namespace)
        end

        square(title: 'Decorators', theme: :style_01)

        klass do
          format
            .header('Settings Decorator')
        end
        klass do
          format
            .header('Table Decorator')
            .method(:update)
            .method(:update_fields)
            .method(:update_rows)
        end
      end
      .cd(:docs)
      .save('domain.drawio')
      .export_svg('domain_model', page: 1)

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
