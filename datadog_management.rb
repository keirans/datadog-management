# This file contains a set of methods used by the Datadog Management
# CLI scripts. It uses the Datadog Ruby SDK.
#
# See: https://docs.datadoghq.com/api/?lang=ruby
#
# Development note: the Datadog REST Client returns the HTTP code as
# the first element of the response array, followed by the JSON
# response, thus why we use the [1]

require 'dogapi'
require 'json'
require 'fileutils'
require 'logger'

class DatadogManagement
    def initialize(apikey, appkey, base_backup_dir = nil, name_filter_regex = '.*')
        @appkey  = appkey
        @apikey  = apikey
        @base_backup_dir = base_backup_dir
        @name_filter_regex = name_filter_regex
        @dog = Dogapi::Client.new(@apikey, @appkey)
        @logger = Logger.new(STDOUT)
    end

    def status
    end

    def backup_screenboards()
        @logger.info("Backing up screenboards matching #{@name_filter_regex.to_s}")
        @screenboards = @dog.get_all_screenboards[1]['screenboards']
        backup_dir = File.join(@base_backup_dir, 'screenboards')
        FileUtils.mkdir_p(backup_dir)
        @screenboards.
          select { |screenboard| (screenboard['title'] || '').match?(@name_filter_regex) }. 
          each do |screenboard|
            @logger.info("  Processing \'#{screenboard['title']}\'")
            filename = "#{screenboard['title'].gsub(/[\/]/, '_')}.json"
            backup_file_path = "#{backup_dir}/#{filename}"
            @logger.info("  Backing up \'#{screenboard['title']}\' to #{backup_file_path}")
            content = JSON.pretty_generate(@dog.get_screenboard(screenboard['id'])[1])
            File.write(backup_file_path, content)
        end
    end

    def backup_dashboards()
        @logger.info("Backing up dashboards matching #{@name_filter_regex.to_s}")
        dashboards = @dog.get_dashboards[1]['dashes']
        backup_dir = File.join(@base_backup_dir, 'dashboards')
        FileUtils.mkdir_p(backup_dir)
        dashboards.
          select { |dashboard| (dashboard['title'] || '').match?(@name_filter_regex) }. 
          each do |dashboard|
            filename = "#{dashboard['title'].gsub(/[\/]/, '_')}.json"
            backup_file_path = "#{backup_dir}/#{filename}"
            @logger.info("  Backing up \'#{dashboard['title']}\' to #{backup_file_path}")
            content = JSON.pretty_generate(@dog.get_dashboard(dashboard['id'])[1])
            File.write(backup_file_path, content)
        end
    end

    def backup_monitors()
        @logger.info("Backing up monitors matching #{@name_filter_regex.to_s}")
        monitors = @dog.get_all_monitors[1]
        backup_dir = File.join(@base_backup_dir, 'monitors')
        FileUtils.mkdir_p(backup_dir)
        monitors.
          select { |monitor| (monitor['name'] || '').match?(@name_filter_regex) }. 
          each do |monitor|
            filename = "#{monitor['name'].gsub(/[\/]/, '_')}.json"
            backup_file_path = "#{backup_dir}/#{filename}"
            @logger.info("  Backing up \'#{monitor['name']}\' to #{backup_file_path}")
            content = JSON.pretty_generate(@dog.get_monitor(monitor['id'])[1])
            File.write(backup_file_path, content)
        end
    end

    def restore_dashboard(payload)
        @logger.info("Restoring dashboard #{payload['title']}")
        @dog.create_dashboard(payload['title'], payload['description'],  payload['graphs'] , payload['template_variables'] )
    end

    def restore_screenboard(payload)
        @logger.info("Restoring screenboard #{payload['board_title']}")
        @dog.create_screenboard(payload)
    end

    def restore_monitor(payload)
        @logger.info("Restoring monitor #{payload['name']}")
        @dog.monitor(payload['type'], payload['query'], :name => payload['name'], :message => payload['message'], :tags => payload['tags'], :options => payload['options'])
    end

end
