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

abort("DD_API_KEY env var must be defined") unless ENV['DD_API_KEY'] 
abort("DD_APP_KEY env var must be defined") unless ENV['DD_APP_KEY'] 

gopts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  
  [ '--object', '-o', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--file', '-f', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--alt-name', '-a', GetoptLong::OPTIONAL_ARGUMENT ],
)

opts = {}
gopts.each { |p, a| opts[p] = a }

def print_usage(error = nil)
  puts "ERROR: #{error}\n" if error
    puts "Datadog Restore CLI - Restore Datadog dashboards, screenboards and monitors from JSON backups"
    puts "Usage: #{$0} --help        - Display the help message"
    puts "Usage: #{$0} --object {dashboard|screenboard|monitor} --file ./SomeObject.json [--alt-name <name>]"
    exit 1
end
  
object = opts['--object'] or print_usage("--object missing")
file = opts['--file'] or print_usage("--file missing")
alt_name = opts['--alt-name']

datadog = DatadogManagement.new(
  ENV['DD_API_KEY'],
  ENV['DD_APP_KEY'])


logger.info("Restoring #{object} from backup file #{file}")

payload = JSON.parse(File.read(file))

case object

when 'dashboard'

  if defined? alt_name
    logger.info("Restoring dashboard with the alternative name #{alt_name}")
    payload['dash']['title'] = alt_name
  end

  datadog.restore_dashboard(payload['dash'])

when 'screenboard'

  if defined? alt_name
    logger.info("Restoring screenboard with the alternative name #{alt_name}")
    payload['board_title'] = alt_name
  end

  datadog.restore_screenboard(payload)

when 'monitor'

  if defined? alt_name
    logger.info("Restoring screenboard with the alternative name #{alt_name}")
    payload['name'] = alt_name
  end

  datadog.restore_monitor(payload)

else
  puts "Error: Didnt get dashboard , screenboard, monitor"
  exit 1

end

