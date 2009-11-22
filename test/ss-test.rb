require "rubygems"
require "rack/test"
require "test/unit"
require "../lib/spy-vs-spy"

class SpyVsSpyTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SoldierOfCode::SpyVsSpy.new(self)
  end

  def test_safari_parse

    basedir = File.dirname(__FILE__)+"/safari"
    contains = Dir.new(basedir).entries
    contains.delete(".")
    contains.delete("..")

    ua_count = 0

    contains.each do |filename|

      file = File.new("#{File.dirname(__FILE__)}/safari/#{filename}", "r")

      puts <<-r
        #{__FILE__}:#{__LINE__} #{__method__}
------------------------------
filename: #{filename}
------------------------------
      r
      rx =  Regexp.new("^safari(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      #puts "#{__FILE__}:#{__LINE__} #{__method__} #{$1} - #{$2} - #{$3} - #{$4} - #{$5} - #{$6} - #{$7}"
      major_version = $3
#      puts "#{__FILE__}:#{__LINE__} #{__method__} #{major_version}"

      while (line = file.gets)

        puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
        r = SoldierOfCode::ParseUserAgent.new.parse(line)
        puts "#{__FILE__}:#{__LINE__} #{__method__} BROWSER: #{r.browser}"
        assert r.browser == 'Safari'

        if major_version && major_version.length > 0
          puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
          puts "#{__FILE__}:#{__LINE__} #{__method__} #{r.browser_version_major} == #{major_version} ? #{r.browser_version_major == major_version}"
          assert r.browser_version_major == major_version
        end

        ua_count+=1

      end


    end

    puts "#{__FILE__}:#{__LINE__} #{__method__} Number of safari agents tested: #{ua_count}"


  end

end
