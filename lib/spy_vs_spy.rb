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
class String
  def starts_with?(str)
    self.index(str) == 0
  end
end

module SoldierOfCode

  class SpyVsSpy

    class Middleware
      def initialize(app=nil)
        @app = app
      end

      def call(env)

        http_user_agent = env['HTTP_USER_AGENT']

        env['soldierofcode.spy-vs-spy'] = ParseUserAgent.new(http_user_agent)

        @app.call(env)
      end


    end
    
    class Version
      attr_accessor :major, :minor, :sub
      
      def to_s
        [major, minor, sub].compact.join('.')
      end
      
      def update(major = nil, minor = nil, sub = nil)
        @major, @minor, @sub = major, minor, sub
      end
      
    end

    @@safari = {
      "1.0" => ["85.5", "85.6", "85.7"],
      "1,0.3" => ["85.8.1", "85.8", "85"],
      "1.2" => ["125", "125.1"],
      "1.2.2" => ["85.8", "125.7", "125.8"],
      "1.2.3" => ["100", "125.9"],
      "1.2.4" => ["125", "125.11", "125.12", "125.12_Adobe", "125.5.5"],
      "1.3" => ["312", "312.3.1"],
      "1.3.1" => ["312.3.3", "312.3.1", "312.3", "125.8", "125.9"],
      "1.3.2" => ["312.3.3", "312.5", "312.6", "312.5_Adobe"],
      "2.0" => ["412", "412.2.2", "412.2_Adobe"],
      "2.0.1" => ["412.5", "412.6", "412.5_Adobe"],
      "2.0.2" => ["416.13", "416.12", "312", "416.13_Adobe", "416.12_Adobe", "412.5"],
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

    attr_reader :ostype, :browser, :os_version, :version, :mobile_browser, :console_browser, :agent
    
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
      
      pass1 = Regexp.new("^([^\\(]*)?[ ]*?(\\([^\\)]*\\))?[ ]*([^\\(]*)?[ ]*?(\\([^\\)]*\\))?[ ]*(.*)")
      if matches = pass1.match(agent)

        @product_token = matches[1] || ''
        @detail = matches[2] || ''
        @engine = matches[3] || ''
        @renderer = matches[4] || ''
        @identifier = matches[5] || ''

        #puts "#{__FILE__}:#{__LINE__} #{__method__} [#{@product_token}] [#{@detail}] [#{@engine}] [#{@renderer}] [#{@identifier}]"

        @platform = identify_platform(agent)
        @mobile = is_mobile?(agent)
        @ostype = identify_os
        @version = Version.new

        [:safari, :firefox, :ie, :opera, :netscape].each do |type|
          send(:"process_#{type}", agent) and break
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
      ["PLAYSTATION 3", "wii", "PlayStation Portable", "Xbox", "iPhone", "iPod", "BlackBerry", "Android", "HTC-", "LG", "Motorola", "Nokia", "Treo", "Pre/", "Samsung", "SonyEricsson"].find do |agt|
        agent.include?(agt)
      end || "Desktop"
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
      ["iPhone", "iPod", "BlackBerry", "Android", "HTC-", "LG", "Motorola", "Nokia", "Treo", "Pre/", "Samsung", "SonyEricsson"].any? do |mobile_agt|
        agent.include?(mobile_agt)
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
    def identify_os
      ["Mac OS X", "Linux", "Windows"].find do |agt|
        @detail.include?(agt)
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

        @@safari.each do |k, v|
          version_numbers = k.gsub(",", ".").split(".")
          v.each do |num|
            if identifier_sub == num
              @version.major = version_numbers[0] if version_numbers.size > 0
              @version.minor = version_numbers[1] if version_numbers.size > 1
              @version.sub = version_numbers[2] if version_numbers.size > 2
            end
            break if @version.major
          end
          # Special case 58.8 - check WebKit numbers
          # Special case 312 - check AppleWebKit
          # Special case 419.3 - could me mobile v3 check AppleWebKit for 420+

          if identifier_sub == "85.8" then
            case @engine
            when /AppleWebKit\/125.2/
              @version.update('1', '2', '2')
            end
          elsif identifier_sub == "125" then
            case @engine
            when /AppleWebKit\/124/
              @version.update('1', '2')
            when /AppleWebKit\/312\.5\.2/
              @version.update('1', '3', '1')
            when /AppleWebKit\/312\.1/
              @version.update('1', '3')
            end
          elsif identifier_sub == '412.5' then
            case @engine
            when /AppleWebKit\/416\.12/
              @version.update('2','0','2')
            end
          elsif identifier_sub == '416.13' then
            case @engine
            when /AppleWebKit\/417\.9/
              @version.update('2','0','3')
            end
          elsif identifier_sub == '412.2' then
            case @engine
            when /AppleWebKit\/412\.6/
              @version.update('2','0')
            end
          elsif identifier_sub == '312.3.1' then
            case @engine
            when /AppleWebKit\/312\.1/
              @version.update('1', '3')
            when /AppleWebKit\/312\.5\.1/
              @version.update('1', '3', '1')
            end
          elsif identifier_sub == "125.8" then
            case @engine
            when /AppleWebKit\/312\.5\.1/
              @version.update('1', '3', '1')
            when /AppleWebKit\/125\.2/
              @version.update('1', '2', '2')
            end
          elsif identifier_sub == "125.9" then
            case @engine
            when /AppleWebKit\/125\.4/
              @version.update('1', '2', '3')
            when /AppleWebKit\/125\.5/
              @version.update('1', '2', '3')
            end
          elsif identifier_sub == "312" then
            engine_sub = @engine.sub("AppleWebKit/", "")
            if engine_sub.include? "416.11" then
              @version.update('2', '0', '2')
            end
          elsif identifier_sub == "312.3.3" then
            case @engine
            when /AppleWebKit\/312\.8/
              @version.update('1', '3', '2')
            end
          elsif identifier_sub == "419.3" then
            engine_sub = @engine.sub("AppleWebKit/", "")
            if engine_sub.include?("420") then
              @version.major = '3'
              @version.minor = '0'
              @version.sub = nil
            else
            end
          end

          if (identifier_sub == "Safari") || (@identifier == "Safari/")then
            engine_sub = @engine.sub("AppleWebKit/", "")
            if engine_sub.include?("418.9") || engine_sub.include?("418.8") then
              @version.major = '2'
              @version.minor = '0'
              @version.sub = '4'
            else
            end
          end

          ident_sub = nil
          if @identifier.include?("Version") then
            @identifier.split(" ").each do |ident|
              ident_sub = ident.sub("Version\/", "") if ident.include?("Version")
              if ident_sub then
                vs = ident_sub.gsub(",", ".").split(".")
                @version.major = vs[0] if vs.size > 0
                @version.minor = vs[1] if vs.size > 1
                @version.sub = vs[2] if vs.size > 2
              end
            end
          end

          if @identifier == "Safari/412 Privoxy/3.0" then
            @version.major = '2'
            @version.minor = '0'
            @version.sub = nil
          end

          break if @version.major
        end
      end

      if @browser == nil && agent_string.include?("Mac OS X") && agent_string.include?("AppleWebKit")
        @browser = "Safari"
      end

      return true if @browser && @version.major
      false
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
          if sec.strip.starts_with?("MSIE ") then
            s = sec.strip.sub("MSIE ", "").gsub(/0(\d)/, '0.\1').sub(",", ".").split(".")
            @version.major = s[0]
            @version.minor = s[1]
            @version.sub =   s[2]
          end

          break if @version.major
        end
      end

      unless @version.major
        if agent.include?("MSIE 6.0")
          @browser = "MSIE"
          @version.major = '6'
          @version.minor = '0'
        end
        if agent.include?("MSIE 7.0")
          @browser = "MSIE"
          @version.major = '7'
          @version.minor = '0'
        end
        if agent.include?("MSIE 8.0")
          @browser = "MSIE"
          @version.major = '8'
          @version.minor = '0'
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
        @identifier.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(" ").each do |ident|
          identifier_sub = ident.sub("Firefox\/", "").sub("Gecko/", "") if ident.include?("Firefox")
          identifier_sub.gsub!(/[\+]/, '') if identifier_sub && identifier_sub.include?("+")
        end
        if identifier_sub == nil && @renderer.include?("Firefox")
          renderer_gsub_gsub = @renderer.sub("\(", "").sub("\)", "")
          renderer_gsub_gsub.strip.split(",").each do |sec|
            identifier_sub = sec.sub("Firefox\/", "").strip if sec.include?("Firefox")
          end
        end
        if identifier_sub == nil && @engine.include?("Firefox")
          @engine.gsub(/[\\:\?'"%!@#\$\^&\*\(\)\+]/, '').split(" ").each do |ident|
            identifier_sub = ident.sub("Firefox\/", "").sub("Gecko/", "") if ident.include?("Firefox")
            identifier_sub.gsub!(/[\+]/, '') if identifier_sub && identifier_sub.include?("+")
          end
        end
        
        identifier_sub.gsub!(/;.*/, '')

        if identifier_sub
          version_numbers = identifier_sub.split(".")
          @version.major = version_numbers[0] if version_numbers.size > 0
          @version.minor = version_numbers[1] if version_numbers.size > 1
          @version.sub = version_numbers[2] if version_numbers.size > 2
        end

      end
      return true if @browser && @version.major
      false
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
