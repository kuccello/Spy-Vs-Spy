require "rack/test"

class SpyVsSpyTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SoldierOfCode::SpyVsSpy.new
  end

  def test_nothing
    
  end

end
