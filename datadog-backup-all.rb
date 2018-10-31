#!/usr/bin/env ruby
#
# Datadog Backups CLI
# Keiran Sweet <Keiran.Sweet@sourcedgroup.com>
#
# This tool provides a way to backup all the dashboards, screenboards and monitors in a
# particular Datadog team from the command line. Each of the objects are dumped in JSON 
# format that is suitable for submitting to the Datadog API to recreate them.
# As such, this means that the backups can be used to restore original copies of a backup
# but also be used to clone dashboards, screenboards and monitors across datadog teams.
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
require 'logger'
require 'yaml'
require_relative 'datadog_management'

logger = Logger.new(STDOUT)

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ]
)

def print_usage 
  puts "Datadog Backup CLI - Dump Datadog dashboards, screenboards and monitors to JSON backups"
  puts "Usage:"
  puts "#{$0} --help        - Display the help message"
  puts "#{$0} --config      - The yaml configuration file to use. Defaults to 'datadog-config.yaml'"
  exit 1
end

config_file = "datadog-config.yml"
opts.each do |opt, arg|
  case opt
  when '--help'
    print_usage
  when '--config'
    config_file = arg
  end
end

config_yaml = YAML.load_file(config_file) or abort("Could not load configuration file #{config_file}")

teams = config_yaml['teams']
teams.keys.each do |team|
  logger.info("=> Backing up Datadog team : \'#{team}\'")

  team_config = config_yaml['teams'][team]
  backup_dir = team_config['backup_dir'] or abort("backup_dir not found in the configuration file")
  name_filter_regex = Regexp.new(team_config['backup_name_filter_regex'])

  datadog = DatadogManagement.new(
    team,
    team_config['apikey'],
    team_config['appkey'],
    backup_dir,
    name_filter_regex)

  datadog.backup_screenboards()
  datadog.backup_dashboards()
  datadog.backup_monitors()
end
