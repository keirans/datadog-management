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

abort("DD_API_KEY env var must be defined") unless ENV['DD_API_KEY'] 
abort("DD_APP_KEY env var must be defined") unless ENV['DD_APP_KEY'] 

gopts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--backup-dir', '-d', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--name-filter-regex', '-f', GetoptLong::REQUIRED_ARGUMENT ],
)
opts = {}
gopts.each { |p, a| opts[p] = a }

def print_usage(error = nil)
  puts "ERROR: #{error}\n" if error
  puts "Datadog Backup CLI - Dump Datadog dashboards, screenboards and monitors to JSON backups"
  puts "Usage:"
  puts "#{$0} --help        - Display the help message"
  puts "#{$0} --backup-dir <dir> --name-filter-regex <regex>"
  exit 1
end

print_usage if opts['--help']
backup_dir = opts['--backup-dir'] or print_usage("--backup-dir missing")
name_filter_regex =
  if opts['--name-filter-regex']
    Regexp.new(opts['--name-filter-regex'])
  else
    print_usage("--name-filter-regex missing")
  end

datadog = DatadogManagement.new(
  ENV['DD_API_KEY'],
  ENV['DD_APP_KEY'],
  backup_dir,
  name_filter_regex)

datadog.backup_screenboards()
datadog.backup_dashboards()
datadog.backup_monitors()
