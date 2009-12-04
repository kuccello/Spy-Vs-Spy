=begin
  Copyright notice
  =============================================================================
  Copyright (c) 2009 Kristan 'Krispy' Uccello <krispy@soldierofcode.com> - Soldier Of Code

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
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

    class Middleware
      def initialize(app=nil)
        @app = app
      end

      def call(env)

        http_user_agent = env['HTTP_USER_AGENT']

        env['soldierofcode.spy-vs-spy'] = SoldierOfCode::SpyVsSpy.new(http_user_agent)

        @app.call(env)
      end


    end
    
    class Version
      attr_accessor :major, :minor, :sub
      
      def to_s
        [major, minor, sub].compact.join('.')
      end
      
      def update(major = nil, minor = nil, sub = nil)
        self.major, self.minor, self.sub = major, minor, sub
      end
      
      def parse!(str)
        self.major, self.minor, self.sub = *str.split('.')
      end
      
      def major=(major)
        @major = major && major.to_i
      end

      def minor=(minor)
        @minor = minor && minor.to_i
      end

      def sub=(sub)
        @sub = sub && sub.to_i
      end
    end

    class OS
      
      OSS = {'Mac OS X' => :osx, 'Linux' => :linux, 'Windows' => :windows}
      OsMatchRegex = /(#{OSS.keys.map{|os| Regexp.quote(os)}.join("|")})/
      
      attr_reader :exact, :original
      
      def initialize(original)
        @original = original
        @exact = (match = OsMatchRegex.match(original)) ? match[1] : nil
      end
      
      def to_s
        original
      end
      
      OSS.each do |value, method|
        class_eval "
          def #{method}?
            OSS[exact] == #{method.inspect}
          end
        "
      end
    end

    SafariSpecialCases = {
      "1.0" =>   ["85.5", "85.6", "85.7"],
      "1,0.3" => ["85.8.1", "85.8", "85"],
      "1.2" =>   ["125", "125.1"],
      "1.2.2" => ["85.8", "125.7", "125.8"],
      "1.2.3" => ["100", "125.9"],
      "1.2.4" => ["125", "125.11", "125.12", "125.12_Adobe", "125.5.5"],
      "1.3" =>   ["312", "312.3.1"],
      "1.3.1" => ["312.3.3", "312.3.1", "312.3", "125.8", "125.9"],
      "1.3.2" => ["312.3.3", "312.5", "312.6", "312.5_Adobe"],
      "2.0" =>   ["412", "412.2.2", "412.2_Adobe"],
      "2.0.1" => ["412.5", "412.6", "412.5_Adobe"],
      "2.0.2" => ["416.13", "416.12", "312", "416.13_Adobe", "416.12_Adobe", "412.5"],
      "2.0.3" => ["417.9.3", "417.8_Adobe", "417.9.2", "417.8", "412.2"],
      "2.0.4" => ["419.3"],
      "3.0" =>   ["523.13", "522.11.3", "523.12.9", "523.6.1", "522.11.1", "522.11", "522.8.3", "522.7"],
      "3.0.1" => ["522.12.2"],
      "3.0.2" => ["522.13.1", "522.12"],
      "3.0.3" => ["522.15.5", "523.6", "522.12.1"],
      "3.0.4" => ["523.11", "523.12.2", "523.10", "523.10.6", "523.15", "523.12"],
      "3.1.1" => ["525.17", "525.18", "525.20"],
      "3.2.1" => ["525.27.1"]
    }

    attr_reader :browser, :os_version, :version, :mobile_browser, :console_browser, :agent, :os, :platform
    
    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def initialize(agent)

      @agent = agent
      
      pass1 = /^([^\(]*)?[ ]*?(\([^\)]*\))?[ ]*([^\(]*)?[ ]*?(\([^\)]*\))?[ ]*(.*)/
      if matches = pass1.match(agent)

        @product_token = matches[1] || ''
        @detail = matches[2] || ''
        @engine = matches[3] || ''
        @renderer = matches[4] || ''
        @identifier = matches[5] || ''

        @platform = identify_platform(agent)
        @mobile = is_mobile?(agent)
        @os = OS.new(@detail)
        @version = Version.new

        [:safari, :firefox, :ie, :opera, :netscape].each do |type|
          send(:"process_#{type}", agent)
          break if complete?
        end
        
      end
    end
    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def identify_platform(agent)
      (match = /(PLAYSTATION 3|wii|PlayStation Portable|Xbox|iPhone|iPod|BlackBerry|Android|HTC-|LG|Motorola|Nokia|Treo|Pre\/|Samsung|SonyEricsson)/.match(agent)) ?
        match[1] : 'Desktop'
    end

    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def is_mobile?(agent)
      /(iPhone|iPod|BlackBerry|Android|HTC-|LG|Motorola|Nokia|Treo|Pre\/|Samsung|SonyEricsson)/.match(agent)
    end

    def complete?
      browser && version.major
    end

    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def process_safari(agent_string)
      @identifier = @engine if @identifier == ""

      if agent_string.include?("Safari")
        @browser = "Safari"
      end

      if @identifier.include?("Safari") || @renderer.include?("Safari") || @detail.include?("iPhone") || @identifier.include?("iPhone")
        @browser = "Safari"

        identifier_sub = nil
        @identifier.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(" ").each do |ident|
          identifier_sub = ident.sub("Safari\/", "") if ident.include?("Safari")
          identifier_sub.gsub!(/[\+]/, '') if identifier_sub && identifier_sub.include?("+")
        end
        if identifier_sub == nil && @renderer.include?("Safari")
          renderer_gsub_gsub = @renderer.sub("\(", "").sub("\)", "")
          renderer_gsub_gsub.strip.split(",").each do |sec|
            identifier_sub = sec.sub("Safari\/", "").strip if sec.include?("Safari")
          end
        end

        SafariSpecialCases.each do |k, v|
          version_numbers = k.gsub(",", ".").split(".")
          v.each do |num|
            if identifier_sub == num
              version.update(*version_numbers)
            end
            break if version.major
          end
          # Special case 58.8 - check WebKit numbers
          # Special case 312 - check AppleWebKit
          # Special case 419.3 - could me mobile v3 check AppleWebKit for 420+

          engine_id = @engine[/AppleWebKit\/([0-9.]+)/, 1]

          case identifier_sub
          when "85.8"
            case engine_id
            when '125.2'     then version.parse!('1.2.2')
            end
          when "125"
            case engine_id
            when '125.5.5'   then version.parse!('1.2.4')
            when '124'       then version.parse!('1.2')
            when '312.5.2'   then version.parse!('1.3.1')
            when '312.1'     then version.parse!('1.3')
            end
          when '412.5'
            case engine_id
            when '416.12'    then version.parse!('2.0.2')
            end
          when '416.13'
            case engine_id
            when '417.9'     then version.parse!('2.0.3')
            end
          when '412.2'
            case engine_id
            when '412.6'     then version.parse!('2.0')
            end
          when '312.3.1'
            case engine_id
            when '312.1'     then version.parse!('1.3')
            when '312.5.1'   then version.parse!('1.3.1')
            end
          when "125.8"
            case engine_id
            when '312.5.1'   then version.parse!('1.3.1')
            when '125.2'     then version.parse!('1.2.2')
            end
          when "125.9"
            case engine_id
            when '125.4'     then version.parse!('1.2.3')
            when '125.5'     then version.parse!('1.2.3')
            when '312.5.1'   then version.parse!('1.3.1')  
            end
          when "312"
            case engine_id
            when '416.11'    then version.parse!('2.0.2')
            end
          when "312.3.3"
            case engine_id
            when '312.8'     then version.parse!('1.3.2')
            end
          when "419.3"
            case engine_id
            when "420"       then version.parse!('3.0')
            end
          end

          if (identifier_sub == "Safari") || (@identifier == "Safari/")then
            case engine_id
            when "418.9", "418.8"
              version.parse!('2.0.4')
            end
          end

          ident_sub = nil
          if @identifier.include?("Version") then
            @identifier.split(" ").each do |ident|
              version.update(*ident.split(/[.,]/).map{|v| v.gsub('Version/', '').gsub(/^(\d*)\D?.*/, '\1')}) if ident.include?('Version')
            end
          end

          if @identifier == "Safari/412 Privoxy/3.0" then
            version.parse!('2.0')
          end

          break if version.major
        end
      end

      if @browser == nil && os.osx? && agent_string.include?("AppleWebKit")
        @browser = "Safari"
      end
    end

    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def process_ie(agent)
      # @detail
      if agent.include?("MSIE")
        @browser = "MSIE"
      end
      if @detail.include?("MSIE")
        @detail.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(";").each do |sec|
          if sec.strip.index("MSIE ") == 0
            version.update(*sec.strip.sub("MSIE ", "").gsub(/0(\d)/, '0.\1').split(/[.,]/))
          end

          break if version.major
        end
      end

      unless version.major
        if match = /MSIE ([6789])\.0/.match(agent)
          @browser = "MSIE"
          version.major = match[1]
          version.minor = '0'
        end
      end
    end

    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def process_firefox(agent)
      @identifier = @engine if @identifier == ""

      if agent.include?("Firefox")
        @browser = "Firefox"
      end

      if @identifier.include?("Firefox") || @renderer.include?("Firefox") || @engine.include?("Firefox")
        @browser = "Firefox"

        identifier_sub = nil
        @identifier.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(" ").find do |ident|
          if ident.include?("Firefox")
            identifier_sub = ident.sub("Firefox\/", "").sub("Gecko/", "")
            identifier_sub.gsub!(/[\+]/, '')
          end
          identifier_sub
        end
        if identifier_sub.nil? && @renderer.include?("Firefox")
          renderer_gsub_gsub = @renderer.sub("\(", "").sub("\)", "")
          renderer_gsub_gsub.strip.split(",").each do |sec|
            identifier_sub = sec.sub("Firefox\/", "").strip if sec.include?("Firefox")
          end
        end
        if identifier_sub.nil? && @engine.include?("Firefox")
          @engine.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(" ").each do |ident|
            identifier_sub = ident.sub("Firefox\/", "").sub("Gecko/", "") if ident.include?("Firefox")
            identifier_sub.gsub!(/[\+]/, '') if identifier_sub && identifier_sub.include?("+")
          end
        end
        
        identifier_sub.gsub!(/;.*/, '')

        if identifier_sub
          version.update(*identifier_sub.split(".")[0, 3])
        end
      end
    end

    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def process_opera(agent)

    end

    #
    #
    # =======================================
    # description:
    # ----------------
    #
    # params:
    # ----------------
    #
    # returns:
    # ----------------
    def process_netscape(agent)

    end
  end
end

SOC = SoldierOfCode
