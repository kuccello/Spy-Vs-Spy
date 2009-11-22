=begin
  Copyright notice
  =============================================================================
  Copyright (c) 2008-2009 Soldier Of Code

  Material published by Soldier Of Code in this file is copyright Soldier Of Code
  and may not be reproduced without permission. Copyright exists in all other
  original material published on the internet by employees of Soldier Of Code and
  may belong to the author or to Soldier Of Code. depending on the circumstances of
  publication.
  ==============================================================================

  This middleware is based on work initialy done by Jackson Miller with his
  parse-user-agent project (http://github.com/jaxn/parse-user-agent). Jackson
  can be reached at jackson.h.miller@gmail.com - parse-user-agent uses a
  MIT/X Consortium License

  ==============================================================================
  LICENSE
  ==============================================================================
  see LICENSE file for details
  
=end
module SoldierOfCode

  class SpyVsSpy

    def initialize(app)
      @app = app
    end

    def call(env)

      http_user_agent = env['HTTP_USER_AGENT']

      env['soldierofcode.spy-vs-spy'] = deconstruct(http_user_agent)

      @app.call(env)
    end

    def deconstruct(agent)
      ParseUserAgent.new.parse(agent)
    end

  end

  class ParseUserAgent

    @@safari = {
            "1.0" => ["85.5", "85.6", "85.7"],
            "1,0.3" => ["85.8.1", "85.8", "85"],
            "1.2" => ["125", "125.1"],
            "1.2.2" => ["85.8", "125.7", "125.8"],
            "1.2.3" => ["100", "125.9"],
            "1.2.4" => ["125", "125.11", "125.12", "125.12_Adobe", "125.5.5"],
            "1.3" => ["312"],
            "1.3.1" => ["312.3.3", "312.3.1", "312.3"],
            "1.3.2" => ["312.5", "312.6", "312.5_Adobe"],
            "2.0" => ["412", "412.2.2", "412.2_Adobe"],
            "2.0.1" => ["412.5", "412.6", "412.5_Adobe"],
            "2.0.2" => ["416.13", "416.12", "312", "416.13_Adobe", "416.12_Adobe"],
            "2.0.3" => ["417.9.3", "417.8_Adobe", "417.9.2", "417.8", "412.2"],
            "2.0.4" => ["419.3"],
            "3.0" => ["523.13", "522.11.3", "523.12.9", "523.6.1", "522.11.1", "522.11", "522.8.3", "522.7"],
            "3.0.1" => ["522.12.2"],
            "3.0.2" => ["522.13.1", "522.12"],
            "3.0.3" => ["522.15.5", "523.6", "522.12.1"],
            "3.0.4" => ["523.11", "523.12.2", "523.10", "523.10.6", "523.15", "523.12"],
            "3.1.1" => ["525.17", "525.18", "525.20"],
            "3.2.1" => ["525.27.1"]
    }


    attr_reader :ostype, :browser, :os_version, :browser_version_major, :browser_version_minor, :browser_version_sub, :mobile_browser, :console_browser

    def parse(agent)

      pass1 = Regexp.new("^([^\\(]*)?[ ]*?(\\([^\\)]*\\))?[ ]*([^\\(]*)?[ ]*?(\\([^\\)]*\\))?[ ]*(.*)")
      pass1.match(agent)

      @product_token = $1 || ''
      @detail = $2 || ''
      @engine = $3 || ''
      @renderer = $4 || ''
      @identifier = $5 || ''

      #puts "#{__FILE__}:#{__LINE__} #{__method__} [#{@product_token}] [#{@detail}] [#{@engine}] [#{@renderer}] [#{@identifier}]"

      @platform = identify_platform(agent)
      @mobile = is_mobile?(agent)
      @ostype = identify_os

      matched = process_safari(agent)
      matched = process_ie(agent) unless matched
      matched = process_firefox(agent) unless matched
      matched = process_opera(agent) unless matched
      matched = process_netscape(agent) unless matched

      self
    end

    def identify_platform(agent)
      platform = "Desktop"
      ["PLAYSTATION 3", "wii", "PlayStation Portable", "Xbox", "iPhone", "iPod", "BlackBerry", "Android", "HTC-", "LG", "Motorola", "Nokia", "Treo", "Pre/", "Samsung", "SonyEricsson"].each do |agt|
        platform = agt if @platform=="Desktop" && agent.include?(agt)
      end
      platform
    end

    def is_mobile?(agent)
      ["iPhone", "iPod", "BlackBerry", "Android", "HTC-", "LG", "Motorola", "Nokia", "Treo", "Pre/", "Samsung", "SonyEricsson"].each do |mobile_agt|
        return true if agent.include?(mobile_agt)
      end
    end

    def identify_os
      os_list = ["Mac OS X", "Linux", "Windows"]
      os = nil
      os_list.each do |o|
        os = o if @detail.include?(o)
      end
      os
    end

    def process_safari(agent_string)
      # engine & identifier @renderer
      #AppleWebKit/85.8.5
      #(KHTML, like Gecko)
      #Safari/85.8.1
      @identifier = @engine if @identifier == ""

      if @renderer.include?("Safari")
        @browser = "Safari"
      end

      if @identifier.include?("Safari") || @renderer.include?("Safari") || @detail.include?("iPhone") || @identifier.include?("iPhone")
        @browser = "Safari"

        identifier_sub = nil
        @identifier.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(" ").each do |ident|
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{ident}"
          identifier_sub = ident.sub("Safari\/", "") if ident.include?("Safari")
          identifier_sub.gsub!(/[\+]/, '') if identifier_sub && identifier_sub.include?("+")
        end
        if identifier_sub == nil && @renderer.include?("Safari")
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{@renderer} #{@renderer.sub("\(", "").class.name}"
          renderer_gsub_gsub = @renderer.sub("\(", "").sub("\)", "")
#          puts "#{__FILE__}:#{__LINE__} #{__method__} #{renderer_gsub_gsub.inspect}"
          renderer_gsub_gsub.strip.split(",").each do |sec|
            identifier_sub = sec.sub("Safari\/", "").strip if sec.include?("Safari")
          end
        end

#        puts "#{__FILE__}:#{__LINE__} #{__method__} #{identifier_sub}"

        @@safari.each do |k, v|
          version_numbers = k.gsub(",", ".").split(".")
          v.each do |num|
#            puts "#{__FILE__}:#{__LINE__} #{__method__} here #{num} ? = #{identifier_sub}"
            if identifier_sub == num
#              puts "#{__FILE__}:#{__LINE__} #{__method__} here #{identifier_sub} = #{num}"
              @browser_version_major = version_numbers[0] if version_numbers.size > 0
              @browser_version_minor = version_numbers[1] if version_numbers.size > 1
              @browser_version_sub = version_numbers[2] if version_numbers.size > 2
#              puts "#{__FILE__}:#{__LINE__} #{__method__} #{@browser_version_major} #{version_numbers}"
            end
            break if @browser_version_major
          end
          # Special case 58.8 - check WebKit numbers
          # Special case 312 - check AppleWebKit
          # Special case 419.3 - could me mobile v3 check AppleWebKit for 420+

          if identifier_sub == "312" then
            engine_sub = @engine.sub("AppleWebKit/", "")
            if engine_sub.include? "416.11" then
              puts "#{__FILE__}:#{__LINE__} #{__method__} here"
              @browser_version_major = '2'
              @browser_version_minor = '0'
              @browser_version_sub = '2'
            else
            end
          end

          if identifier_sub == "419.3" then
            engine_sub = @engine.sub("AppleWebKit/", "")
            if engine_sub.include?("420") then
              puts "#{__FILE__}:#{__LINE__} #{__method__} here"
              @browser_version_major = '3'
              @browser_version_minor = '0'
              @browser_version_sub = nil
            else
            end
          end

          if (identifier_sub == "Safari") || (@identifier == "Safari/")then
            engine_sub = @engine.sub("AppleWebKit/", "")
            if engine_sub.include?("418.9") || engine_sub.include?("418.8") then
              @browser_version_major = '2'
              @browser_version_minor = '0'
              @browser_version_sub = '4'
            else
            end
          end

          ident_sub = nil
          if @identifier.include?("Version") then
            @identifier.split(" ").each do |ident|
              ident_sub = ident.sub("Version\/", "") if ident.include?("Version")
              if ident_sub then
                vs = ident_sub.gsub(",", ".").split(".")
                @browser_version_major = vs[0] if vs.size > 0
                @browser_version_minor = vs[1] if vs.size > 1
                @browser_version_sub = vs[2] if vs.size > 2
              end
            end
          end

          if @identifier == "Safari/412 Privoxy/3.0" then
            @browser_version_major = '2'
            @browser_version_minor = '0'
            @browser_version_sub = nil
          end

          break if @browser_version_major
        end
      end

      if @browser == nil && agent_string.include?("Mac OS X") && agent_string.include?("AppleWebKit")
        @browser = "Safari"
      end

      return true if @browser && @browser_version_major
      false
    end

    def process_ie(agent)

    end

    def process_firefox(agent)

    end

    def process_opera(agent)

    end

    def process_netscape(agent)

    end

=begin

    def known_browser(browser)

      browsers = %w[ Firefox Safari MSIE ]
      flag = false
      browsers.each do |b|
        flag = true if b == browser
      end

      flag
    end

    def known_safari_agent_string(string)
      agents = []
      agents << "AppleWebKit"
      agents << "iPhone"

      agents.each do |agent|
        return true if string.include?(agent)
      end
      false
    end

    def mobile_browser?(string)
      agents = []
      agents << "iPhone"

      agents.each do |agent|
        if string.include?(agent)
          @mobile_browser = agent
          return true
        end
      end
      false
    end

    def console_browser?(string)
      agents = []

      agents.each do |agent|
        if string.include?(agent)
          @console_browser = agent
          return true
        end
      end
      false
    end

    def is_safari?(str)
      s = []
      s << "iPhone"
      s << "Safari"

      flag = false
      s.each do |st|
        flag = true if str.include?(st)
      end
      flag
    end

    def parse(user_agent)
      if '-' == user_agent
        raise 'Invalid User Agent'
      end

      @user_agent = user_agent

      # fix Opera
      #useragent =~ s/Opera (\d)/Opera\/$1/i;
      useragent = @user_agent.gsub(/(Opera [\d])/, 'Opera\1')

      # grab all Agent/version strings as 'agents'
      @agents = Array.new
      @user_agent.split(/\s+/).each {|string|
        if string =~ /\//
          @agents<< string
        end
      }

      # cycle through the agents to set browser and version (MSIE is set later)
      if @agents && @agents.length > 0
        @agents.each {|agent|

          parts = agent.split('/')
          @browser = parts[0]
          @browser_version = parts[1]

          if @browser == 'Firefox'
            @browser_version_major = parts[1].slice(0, 3)
            @browser_version_minor = parts[1].sub(@browser_version_major, '').sub('.', '')

          elsif @browser == 'Safari'
            rx = Regexp.new("Version/([0-9]+)\.([0-9]+)\.([0-9]+)")
            rx.match(user_agent)

            @browser_version_major = $1
            @browser_version_minor = $2
            @browser_version_sub = $3

            unless $1

              v1_0_3 = []
              v1_0_3 << "85.8.1"
              v1_0_3 << "85"
              v1_0_3 << "85.8"


              vs = parts[1].split("\.")
              vs1 = vs[0].to_i
              if vs1 < 126
                @browser_version_major = '1'

                if vs[1].to_i < 8
                  @browser_version_minor = '0'
                  @browser_version_sub = '0'
                elsif vs[1].to_i >= 8
                  @browser_version_minor = '0'
                  @browser_version_sub = '3'
                end

              end

            end

          else
#            puts "#{__FILE__}:#{__LINE__} #{__method__} here---"
            @browser_version_major = parts[1].slice(0, 1)
          end
        }
      end


      if !known_browser(@browser) then

        @browser = 'Safari' if is_safari?(user_agent) || known_safari_agent_string(user_agent)

      end

      # I'm thinking of making this a lazy call....
      mobile_browser?(user_agent)
      console_browser?(user_agent)

      # grab all of the properties (within parens)
      # should be in relation to the agent if possible
      @detail = @user_agent
      @user_agent.gsub(/\((.*)\)/, '').split(/\s/).each {|part| @detail = @detail.gsub(part, '')}
      @detail = @detail.gsub('(', '').gsub(')', '').lstrip
      @properties = @detail.split(/;\s+/)

      # cycle through the properties to set known quantities
      @properties.each {|property|
        if property =~ /^Win/
          @ostype = 'Windows'
          @os = property
          if parts = property.split(/ /, 2)
            if parts[1] =~ /^NT/
              @ostype = 'Windows'
              subparts = parts[1].split(/ /, 2)
              if subparts[1] == '5'
                @os_version = '2000'
              elsif subparts[1] == '5.1'
                @os_version = 'XP'
              else
                @os_version = subparts[1]
              end
            end
          end
        end
        if property == 'Macintosh'
          @ostype = 'Macintosh'
          @os = property
        end
        if property =~ /OS X/
          @ostype = 'Macintosh'
          @os_version = 'OS X'
          @os = property
        end
        if property =~ /^Linux/
          @ostype = 'Linux'
          @os = property
        end
        if property =~ /^MSIE/
          @browser = 'MSIE'
          @browser_version = property.gsub('MSIE ', '').lstrip
          @browser_version_major, @browser_version_minor = @browser_version.split('.')
        end
      }
      self
    end

=end
  end
end
