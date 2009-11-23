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

  def test_safari_parse

    basedir = File.dirname(__FILE__)+"/safari"
    contains = Dir.new(basedir).entries
    contains.delete(".")
    contains.delete("..")

    ua_count = 0

    contains.each do |filename|

      file = File.new("#{File.dirname(__FILE__)}/safari/#{filename}", "r")
      rx =  Regexp.new("^safari(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      major_version = $3

      while (line = file.gets)
        r = SoldierOfCode::SpyVsSpy.new(line)
        assert r.browser == 'Safari'

        if major_version && major_version.length > 0
          assert r.browser_version_major == major_version
        end
        ua_count+=1

      end


    end

    puts "Number of safari agents tested: #{ua_count}"


  end

  def test_firefox_parse

    basedir = File.dirname(__FILE__)+"/firefox"
    contains = Dir.new(basedir).entries
    contains.delete(".")
    contains.delete("..")

    ua_count = 0

    contains.each do |filename|

      file = File.new("#{File.dirname(__FILE__)}/firefox/#{filename}", "r")
      rx =  Regexp.new("^firefox(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      major_version = $3
      while (line = file.gets)
        r = SoldierOfCode::SpyVsSpy.new(line)
        assert r.browser == 'Firefox'

        if major_version && major_version.length > 0
          assert r.browser_version_major == major_version
        end

        ua_count+=1
      end
    end

    puts "Number of firefox agents tested: #{ua_count}"
  end

  def test_msie_parse

    basedir = File.dirname(__FILE__)+"/msie"
    contains = Dir.new(basedir).entries
    contains.delete(".")
    contains.delete("..")

    ua_count = 0

    contains.each do |filename|

      file = File.new("#{File.dirname(__FILE__)}/msie/#{filename.sub("\n","")}", "r")
      rx =  Regexp.new("^msie(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      major_version = $3

      while (line = file.gets)

        r = SoldierOfCode::SpyVsSpy.new(line)
        assert r.browser == 'MSIE'

        if major_version && major_version.length > 0
          assert r.browser_version_major == major_version
        end
        ua_count+=1
      end
    end

    puts "Number of internet explorer agents tested: #{ua_count}"
  end
end
