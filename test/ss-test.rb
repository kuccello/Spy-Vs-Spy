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

#      puts <<-r
#filename: #{filename}
#      r
      rx =  Regexp.new("^safari(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      #puts "#{__FILE__}:#{__LINE__} #{__method__} #{$1} - #{$2} - #{$3} - #{$4} - #{$5} - #{$6} - #{$7}"
      major_version = $3
#      puts "#{__FILE__}:#{__LINE__} #{__method__} #{major_version}"

      while (line = file.gets)

#        puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
        r = SoldierOfCode::SpyVsSpy.new.parse(line)
#        puts "#{__FILE__}:#{__LINE__} #{__method__} BROWSER: #{r.browser}"
        assert r.browser == 'Safari'

        if major_version && major_version.length > 0
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{r.browser_version_major} == #{major_version} ? #{r.browser_version_major == major_version}"
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

#      puts <<-r
#filename: #{filename}
#      r
      rx =  Regexp.new("^firefox(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      #puts "#{__FILE__}:#{__LINE__} #{__method__} #{$1} - #{$2} - #{$3} - #{$4} - #{$5} - #{$6} - #{$7}"
      major_version = $3
#      puts "#{__FILE__}:#{__LINE__} #{__method__} #{major_version}"

      while (line = file.gets)

#        puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
        r = SoldierOfCode::SpyVsSpy.new.parse(line)
#        puts "#{__FILE__}:#{__LINE__} #{__method__} BROWSER: #{r.browser}"
        assert r.browser == 'Firefox'

        if major_version && major_version.length > 0
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
#          puts "#{__FILE__}:#{__LINE__} #{__method__} [#{r.browser_version_major}] == [#{major_version}] ? #{r.browser_version_major == major_version}"
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

      file = File.new("#{File.dirname(__FILE__)}/msie/#{filename}", "r")
#
#      puts <<-r
#filename: #{filename}
#      r
      rx =  Regexp.new("^msie(\-(([0-9])(.*)))\.txt")
      rx.match(filename)
      #puts "#{__FILE__}:#{__LINE__} #{__method__} #{$1} - #{$2} - #{$3} - #{$4} - #{$5} - #{$6} - #{$7}"
      major_version = $3
#      puts "#{__FILE__}:#{__LINE__} #{__method__} #{major_version}"

      while (line = file.gets)

#        puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
        r = SoldierOfCode::SpyVsSpy.new.parse(line)
#        puts "#{__FILE__}:#{__LINE__} #{__method__} BROWSER: #{r.browser}"
        assert r.browser == 'MSIE'

        if major_version && major_version.length > 0
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{line}"
#          puts "#{__FILE__}:#{__LINE__} #{__method__} [#{r.browser_version_major}] == [#{major_version}] ? #{r.browser_version_major == major_version}"
          assert r.browser_version_major == major_version
        end

        ua_count+=1

      end


    end

    puts "Number of internet explorer agents tested: #{ua_count}"


  end

end
