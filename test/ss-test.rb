require "rubygems"
require "rack/test"
require "test/unit"
require 'dirge'
require ~"../lib/spy_vs_spy"

class SpyVsSpyTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SOC::SpyVsSpy::Middleware.new(self)
  end

  def test_parse
    
    Dir[~'**/*.txt'].each do |file|
      browser_name, version_string = File.basename(file)[/^(.*)\.txt$/, 1].split('-')
      puts ">>> #{browser_name} -- #{version_string}"
      if version_string
        major, minor, sub = version_string.split(/[,\.]/).map{|v| v && v.to_i}
        File.open(file) do |f|
          f.each_line do |line|
            puts "testing #{line}"
            r = SoldierOfCode::SpyVsSpy.new(line)
            assert_equal browser_name.downcase, r.browser.downcase   
            assert_equal major,        r.version.major
            assert_equal minor,        r.version.minor
            assert_equal sub,          r.version.sub
          end
        end
      end
    end
  end
end
