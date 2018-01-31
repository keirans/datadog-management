#!/usr/bin/env ruby
#
# Datadog Management for QCP
# Keiran Sweet <Keiran.Sweet@sourcedgroup.com>
#
# This file contains a set of methods used by the Datadog management CLI tools to make 
# development and maintence of them a little easier. It' is effectively a wrapper around the 
# Datadog Ruby SDK.
#
# See: https://docs.datadoghq.com/api/?lang=ruby#monitors
#
# Class methods
# --------------
#
# initialize
# - Pass in a team name and the backup directory and it will create a datadog connection object
#   for that team by looking up the api and application keys for that team from the datadog configuration file.
#
# backup_screenboards
# - List all screenboards in a particular team, then loop through them, dumping their JSON out to a file.
#   This can be used later on to restore it to the same team, or a different team for cloning and replication tasks
#
# backup_dashboards
# - List all dashboards in a particular team, then loop through them, dumping their JSON out to a file.
#   This can be used later on to restore it to the same team, or a different team for cloning and replication tasks
#
# backup_monitors
# - List all monitors in a particular team, then loop through them, dumping their JSON out to a file.
#   This can be used later on to restore it to the same team, or a different team for cloning and replication tasks
#
# restore_dashboard / restore_screenboard / restore_monitor
# - When passed a JSON payload these methods create the dashboard / screenboard / monitor in the particular account
#   as per the content held within. This is used to restore or clone datadog objects from the 
#
# configure_users
# - When passed an array of users email addresses and a string value of the datadog role type (admin, readonly or standard)
#   The user is invited to the datadog team if they are not present (with the suitable role), if they do exist, they are
#   checked to see if they are configured correctly with the right role, ammending their account in the event that it is incorrect.
#   Finally, if all is OK, no action is taken.
#
# Development note: the Datadog REST Client returns the HTTP code as the first element of the response array,
# followed by the JSON response, thus why we use the [1]
#


require 'dogapi'
require 'json'
require 'fileutils'
require 'logger'

class DatadogManagement
    def initialize(team, apikey, appkey)
        @team    = team
        @appkey  = appkey
        @apikey  = apikey
        @dog = Dogapi::Client.new(@apikey, @appkey)
        @logger = Logger.new(STDOUT)
    end

    def status
        @logger.debug("Datadog management conneciton status")
        @logger.debug("The status for #{@team}")
        @logger.debug("Application Key: #{@appkey}")
        @logger.debug("API Key: #{@apikey}")
        @logger.debug("")
    end

    def backup_screenboards(backupdir, backupdate)
        @logger.info("Backing up screenboards for team \'#{@team}\'")
        @screenboards = @dog.get_all_screenboards[1]['screenboards']
        @screenboards.each do | screenboard |
            @logger.info("  Processing \'#{screenboard['title']}\'")
            filename = "#{screenboard['title'].gsub(/[\/]/, '_')}.json"
            backup_path = "#{backupdir}/#{@team}/#{backupdate}/screenboards/"
            backup_full_path = "#{backupdir}/#{@team}/#{backupdate}/screenboards/#{filename}"

            @logger.info("    Backup file \'#{backup_full_path}\'")
            FileUtils.mkdir_p(backup_path)
            content = JSON.pretty_generate(@dog.get_screenboard(screenboard['id'])[1])
            File.write(backup_full_path, content)
        end
    end

    def backup_dashboards(backupdir, backupdate)
        @logger.info("Backing up dashboards for team \'#{@team}\'")
        dashboards = @dog.get_dashboards[1]['dashes']
        dashboards.each do | dashboard |
            filename = "#{dashboard['title'].gsub(/[\/]/, '_')}.json"
            backup_path = "#{backupdir}/#{@team}/#{backupdate}/dashboards/"
            backup_full_path = "#{backup_path}/#{filename}"

            @logger.info("  Processing \'#{dashboard['title']}\'")
            @logger.info("    Backup file  \'#{backup_full_path}\'")
            FileUtils.mkdir_p(backup_path)
            content = JSON.pretty_generate(@dog.get_dashboard(dashboard['id'])[1])
            File.write(backup_full_path, content)
        end
    end

    def backup_monitors(backupdir, backupdate)
        @logger.info("Backing up monitors for team \'#{@team}\''")
        monitors = @dog.get_all_monitors[1]
        monitors.each do | monitor |
            filename = "#{monitor['name'].gsub(/[\/]/, '_')}.json"
            backup_path = "#{backupdir}/#{@team}/#{backupdate}/monitors/"
            backup_full_path = "#{backup_path}/#{filename}"

            @logger.info("  Processing \'#{monitor['name']}\'")
            @logger.info("    Backup file #{backup_full_path}")
            FileUtils.mkdir_p(backup_path)
            content = JSON.pretty_generate(@dog.get_monitor(monitor['id'])[1])
            File.write(backup_full_path, content)
        end
    end

    def restore_dashboard(payload)
        @logger.info("Restoring dashboard #{payload['title']} to team \'#{@team}\''")
        @dog.create_dashboard(payload['title'], payload['description'],  payload['graphs'] , payload['template_variables'] )
    end

    def restore_screenboard(payload)
        @logger.info("Restoring screenboard #{payload['board_title']} to team \'#{@team}\''")
        @dog.create_screenboard(payload)
    end

    def restore_monitor(payload)
        @logger.info("Restoring monitor #{payload['name']} to team \'#{@team}\''")
        @dog.monitor(payload['type'], payload['query'], :name => payload['name'], :message => payload['message'], :tags => payload['tags'], :options => payload['options'])
    end


    def configure_users(users, role) 

      @logger.info("Configuring datadog #{role} user accounts in team #{@team}")
      @logger.info("The users to be processed are :")
      @logger.info(users)

      users.each do | user | 

        user_status = @dog.get_user(user)[0]
        user_config = @dog.get_user(user)[1]['user']

        if user_status == '200'
          @logger.info("  => User: #{user} DOES EXIST - #{user_status}")
          @logger.info("    => Validating the configuration of User: #{user}")
          
          if user_config['access_role'] == role
            @logger.info("    => User: #{user} IS configured as #{role} as required - #{user_config['access_role']}") 
          else
            @logger.info("    => User: #{user} IS NOT configured as #{role} as required - #{user_config['access_role']}")
            @logger.info("    => Updating user account #{user} to role #{role}")
            update_status = @dog.update_user(user, :access_role => role )[0]
           
            if update_status == '200'
              @logger.info("    => Updated #{user} to #{role} all OK - #{update_status}") 
            else
              @logger.warn("    => UNABLE to update #{user} to #{role} - #{update_status}")
            end

          end

        else
          @logger.info("  => User: #{user} DOES NOT exist - #{user_status}")
          @logger.info("    => Creating user #{user} with role #{role}")
          create_status = @dog.create_user(:handle => user, :access_role => role)[0]

            if create_status == '200'
              @logger.info("    => Created #{user} with #{role} all OK - #{create_status}")
            else
              @logger.warn("    => UNABLE to create #{user} wth #{role} - #{create_status}")
            end
        end

      end

    end

end
