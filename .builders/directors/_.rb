require_relative './build_actions'
require_relative './director'
# require_relative './gem_director'
require_relative './klue_director'
require_relative './design_pattern_director'

def klue
  @klue ||= KlueDirector.new
end

