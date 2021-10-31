require 'initializers/_'
require 'directors/_'

klue
  .reset
  .register(:design_patterns           , DesignPatternDirector)

klue
  .with(:design_patterns) do
    composite(
      relative_path: 'mixins',
      name: :composable_components,
      namespace: 'KDoc',
      children_name: :component,
      children_name_plural: :components)
  end

puts '...'