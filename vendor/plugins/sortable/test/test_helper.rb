ENV["RAILS_ENV"] = 'test'

require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))

require 'test/unit'
require 'test_help'

class Test::Unit::TestCase

  self.fixture_path = File.expand_path( File.join(File.dirname(__FILE__), 'fixtures') )

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

end