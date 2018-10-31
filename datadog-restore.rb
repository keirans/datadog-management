#!/usr/bin/env ruby
# Datadog Restore CLI
# Keiran Sweet <Keiran.Sweet@sourcedgroup.com>
#
# This tool provides a way to restore all the dashboards, screenboards and monitors in a
# particular Datadog team from the backups JSON backups produced by the datadog-backups-cli tool
#
# This tool uses the DatadogManagement class that provides a set of additional methods to make
# working with the Datadog API's for these administration tasks a little easier.
# It is effectively a wrapper around the Datadog Ruby SDK.
#

require 'date'
require 'rubygems'
require 'dogapi'
require 'json'
require 'fileutils'
require 'getoptlong'
require 'yaml'
require_relative 'datadog_management'

logger = Logger.new(STDOUT)

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  
  [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--team', '-t', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--object', '-o', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--file', '-f', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--altname', '-a', GetoptLong::OPTIONAL_ARGUMENT ],
)

def print_usage 
    puts "Datadog Restore CLI - Restore Datadog dashboards, screenboards and monitors from JSON backups"
    puts "Usage: #{$0} --help        - Display the help message"
    puts "Usage: #{$0} [--config <yaml file>] --object {dashboard|screenboard|monitor} --file ./SomeObject.json [--altname <name>]"
    exit 1
end
  
config_file = "datadog-config.yml"

opts.each do |opt, arg|
  case opt
    when '--help'
      print_usage

    when '--config'
      config_file = arg

    when '--object'
      @object = arg

    when '--file'
      @filename = arg

    when '--altname'
      @altname = arg

  end
end

unless @object && @filename
    print_usage
end 

config_yaml = YAML.load_file(config_file) or abort("Could not load configuration file #{config_file}")

teams = config_yaml['teams']
teams.keys.each do |team|
logger.info("Restoring #{@object} to team #{team} from backup file #{@filename}")

  datadog = DatadogManagement.new(
    team,
    config_yaml['teams'][team]['apikey'],
    config_yaml['teams'][team]['appkey'])

  payload = JSON.parse(File.read(@filename))

  case @object

    when 'dashboard'

      if defined? @altname
        logger.info("Restoring dashboard with the alternative name #{@altname}")
        payload['dash']['title'] = @altname
      end

      datadog.restore_dashboard(payload['dash'])

    when 'screenboard'

      if defined? @altname
        logger.info("Restoring screenboard with the alternative name #{@altname}")
        payload['board_title'] = @altname
      end

      datadog.restore_screenboard(payload)

    when 'monitor'

      if defined? @altname
        logger.info("Restoring screenboard with the alternative name #{@altname}")
        payload['name'] = @altname
      end

      datadog.restore_monitor(payload)

    else
      puts "Error: Didnt get dashboard , screenboard, monitor"
      exit 1

  end

end
