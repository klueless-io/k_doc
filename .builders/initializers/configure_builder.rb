KBuilder.reset(:gem)
KBuilder.configure(:gem) do |config|
  # config.template_folders.add(:global     , '~/dev/kgems/k_templates/definitions/genesis')
  config.target_folders.add(:root         , File.expand_path('..', Dir.getwd))
  config.target_folders.add(:lib          , :root, 'lib', 'k_doc')
  config.target_folders.add(:spec         , :root, 'spec', 'k_doc')
end

KBuilder.reset(:design_patterns)
KBuilder.configure(:design_patterns) do |config|
  config.template_folders.add(:global     , '~/dev/kgems/k_templates/templates/ruby_design_patterns')
  config.target_folders.add(:root         , File.expand_path('..', Dir.getwd))
  config.target_folders.add(:lib          , :root, 'lib', 'k_doc')
  config.target_folders.add(:spec         , :root, 'spec', 'k_doc')
end

# KBuilder.configuration(:gem).debug

# def builder
#   @builder ||= KBuilder::BaseBuilder.init
# end

puts ':)'

# Setup.configure(:microapp) do |config|
#   config.template_folders.add(:microapp   , '~/dev/kgems/k_templates/definitions/microapp')
#   config.target_folders.add(:root         , Dir.getwd)
# end

# Setup.configure(:data) do |config|
#   # config.template_folders.add(:microapp   , '~/dev/kgems/k_templates/definitions/microapp')
#   config.target_folders.add(:root         , File.expand_path('..', Dir.getwd), '.data')
# end

# Setup.configure(:actual_app) do |config|
#   # config.template_folders.add(:microapp   , '~/dev/kgems/k_templates/definitions/microapp')
#   config.target_folders.add(:root         , File.expand_path('..', Dir.getwd))
# end
