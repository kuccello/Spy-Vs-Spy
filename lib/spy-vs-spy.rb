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
      ParseUserAgent.new(agent)
    end

  end

  class ParseUserAgent

    attr_reader :ostype, :browser, :os_version, :browser_version_major

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
            if parts[1].slice(0, 3).to_f < 400
              @browser_version_major = '1'
            else
              @browser_version_major = '2'
            end
          else
            @browser_version_major = parts[1].slice(0, 1)
          end
        }
      end

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


  end
end
