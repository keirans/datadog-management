Datadog Management Tooling
----------------
Welcome to the Datadog Management repository.

This repository contains a set of tools to provide the following capabilities for Datadog users and administrators that are not available natively today from Datadog.

- datadog-backups-cli
    - Backup your Datadog teams Dashboards, Screenboards and Monitors to JSON locally.
- datadog-restore-cli
    - Restore your Datadog objects Dashboards, Screenboards and Monitors to your Datadog teams from the local JSON backups produced from backups.
- datadog-users-cli
    - Configure and invite users as admins, standard users and read only users across all your defined teams without having to use the console

The tools are built around a common DatadogManagement class that provides an administrative interface to Datadog leveraging the Datadog SDK.


Usage
---------------------------
1. Ensure you have a suitable Ruby 2.3.x+ version available
2. Clone the repository 
3. Bundle install 
4. Setup the configuration file YAML (See structure below)
5. Execute the tools


Configuration file structure
---------------------------
The configuration file should be called `datadog-config.yaml1 and it must reside in the root directory of the cloned repo.
A sample configuration file exists as `datadog-config.yaml-sample`

A Sample is also below for your reference

-  Config section
    - Global tool configuration attributes
        - backupdir     - The directory to store the backup data
        - dateformat    - The date format string used for storing date seperated backup files
    - Teams section     - A hash of Teams and their corrosponding API and APP Keys to allow the tools to access the APIs of each datadog team.
    - Users section     - A hash of hashes of Arrays of users for each type of user (Admin, Standard, Read only) that is used by the datadog-users-cli command to create and invite users across all the teams defined in the configuration file.


---------------------------

    ---
    config:
        https_proxy: http://hostname:8080
        http_proxy: http://hostname:8080
        backupdir: "./datadog-backups"
        dateformat: "%F"
    teams:
        Team1:
            apikey: APIKEY
            appkey: APPKEY
        Team2:
            apikey: APIKEY
            appkey: APPKEY
        Team3:
            apikey: APIKEY
            appkey: APPKEY
        Team4:
            apikey: APIKEY
            appkey: APPKEY
    users:
        adm:
            - adminuser1@domain.com.au
        st: 
            - standarduser1@domain.com.au
            - standarduser2@domain.com.au
        ro: 
            - readonly1@domain.com.au
            - readonly2@domain.com.au
            - readonly3@domain.com.au



Example Usages
---------------------------
### Backing up a single team
You can use the datadog-backups-cli tool to export all the dashboards, screenboards and monitors for a specific team configured in the configuration file.

    $ datadog-backups-cli --team Team1
    I, [2017-12-20T04:28:22.741970 #1074]  INFO -- : => Backing up Datadog team : 'Team1'
    I, [2017-12-20T04:28:22.743962 #1074]  INFO -- : Backing up screenboards for team 'Team1'
    I, [2017-12-20T04:28:24.350793 #1074]  INFO -- :   Processing 'keiran.sweet's ScreenBoard 29 Nov 2017 16:41'
    I, [2017-12-20T04:28:24.351055 #1074]  INFO -- :     Backup file './datadog-backups/Team1/2017-12-20/screenboards/keiran.sweet's ScreenBoard 29 Nov 2017 16:41.json'
    I, [2017-12-20T04:28:25.783140 #1074]  INFO -- :   Processing 'Generic Dashboard'
    I, [2017-12-20T04:28:25.783283 #1074]  INFO -- :     Backup file './datadog-backups/Team1/2017-12-20/screenboards/Generic Dashboard.json'
    I, [2017-12-20T04:28:27.485822 #1074]  INFO -- :   Processing 'Number of Agents or EC2 reporting'
    I, [2017-12-20T04:28:27.485990 #1074]  INFO -- :     Backup file './datadog-backups/Team1/2017-12-20/screenboards/Number of Agents or EC2 reporting.json'
    I, [2017-12-20T04:28:30.251171 #1074]  INFO -- : Backing up dashboards for team 'Team1'
    I, [2017-12-20T04:28:32.182882 #1074]  INFO -- :   Processing 'keiran.sweet's TimeBoard 11 Dec 2017 16:26'
    I, [2017-12-20T04:28:32.183172 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//keiran.sweet's TimeBoard 11 Dec 2017 16:26.json'
    I, [2017-12-20T04:28:33.958075 #1074]  INFO -- :   Processing 'Keirans Recovery Test Dashboard'
    I, [2017-12-20T04:28:33.958277 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//Keirans Recovery Test Dashboard.json'
    I, [2017-12-20T04:28:35.639670 #1074]  INFO -- :   Processing 'Bamboo CI - Development'
    I, [2017-12-20T04:28:35.639759 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//Bamboo CI - Development.json'
    I, [2017-12-20T04:28:37.197096 #1074]  INFO -- :   Processing 'Mickey Learn Teraffom and Datadog'
    I, [2017-12-20T04:28:37.197288 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//Mickey Learn Teraffom and Datadog.json'
    I, [2017-12-20T04:28:38.678012 #1074]  INFO -- :   Processing 'NONPROD'
    I, [2017-12-20T04:28:38.678492 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//NONPROD.json'
    I, [2017-12-20T04:28:40.121134 #1074]  INFO -- :   Processing 'Backup'
    I, [2017-12-20T04:28:40.121340 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//Backup.json'
    I, [2017-12-20T04:28:41.504553 #1074]  INFO -- :   Processing 'Non Prod Wide metrics'
    I, [2017-12-20T04:28:41.504763 #1074]  INFO -- :     Backup file  './datadog-backups/Team1/2017-12-20/dashboards//Non Prod Wide metrics.json'
    I, [2017-12-20T04:28:42.947587 #1074]  INFO -- : Backing up monitors for team 'Team1''
    I, [2017-12-20T04:28:44.316292 #1074]  INFO -- :   Processing '[Auto] Clock in sync with NTP'
    I, [2017-12-20T04:28:44.316624 #1074]  INFO -- :     Backup file ./datadog-backups/Team1/2017-12-20/monitors//[Auto] Clock in sync with NTP.json
    I, [2017-12-20T04:28:45.826189 #1074]  INFO -- :   Processing 'This is an example please ignore'
    I, [2017-12-20T04:28:45.826276 #1074]  INFO -- :     Backup file ./datadog-backups/Team1/2017-12-20/monitors//This is an example please ignore.json
    I, [2017-12-20T04:28:47.343203 #1074]  INFO -- :   Processing 'Autoheal alert testing'
    I, [2017-12-20T04:28:47.343395 #1074]  INFO -- :     Backup file ./datadog-backups/Team1/2017-12-20/monitors//Autoheal alert testing.json
    $

Pro Tip: You can use 'all' as the team name and all teams will be backed up in sequence.


### Restoring a backup screenboard to a specific team fom JSON
Using the restore CLI, the below example shows how we can restore a screenboard to a team from a backup file.
This capability also allows you to clone / deploy screenboards across teams which Datadog doesnt currently allow you to do natively.

    $ ./datadog-restore-cli --team Team1  --object screenboard --file "datadog-backups/Team1/2017-12-19/screenboards/Generic Dashboard.json"
    I, [2017-12-20T04:38:46.504454 #1277]  INFO -- : Restoring screenboard to team Team1 from backup file datadog-backups/Team1/2017-12-19/screenboards/Generic Dashboard.json
    I, [2017-12-20T04:38:46.508257 #1277]  INFO -- : Restoring screenboard Generic Dashboard to team 'Team1''
    $

### Restoring a backup monitor with an alternate name
Using the restore CLI, the below example shows how we can restore a monitor to a team from a backup file.
This capability also allows you to clone / deploy screenboards across teams which Datadog doesnt currently allow you to do natively.
In this example, we also use the --altname option to restore the monitor with a different name, which is useful for deploying copies alongside existing monitors.

    $ datadog-restore-cli --team Team1 --object monitor --file "./datadog-backups/Team1/2017-12-20/monitors/[Auto] Clock in sync with NTP.json" --altname "This is the monitors new name"
    I, [2017-12-20T04:56:29.273593 #1333]  INFO -- : Restoring monitor to team Team1 from backup file ./datadog-backups/Team1/2017-12-20/monitors/[Auto] Clock in sync with NTP.json
    I, [2017-12-20T04:56:29.276744 #1333]  INFO -- : Restoring screenboard with the alternative name This is the monitors new name
    I, [2017-12-20T04:56:29.276837 #1333]  INFO -- : Restoring monitor This is the monitors new name to team 'Team1''
    $
 
### Inviting a user as an Administrator to a specific team
Using the users CLI you can configure a set of users in the configuration file as either Admin (ad), Standard (st) and Read Only (ro) and then have it create / invite those users to the team if they are found to be missing. If the user is found to exist, it will validate that the user account is set with the correct permissions, and if they are not correct, it will update their account accordingly.

The example below shows how a single user account - keiran.sweet@sourcedgroup.com in the adm: array can be invited to a single team.

Using all as the team name will invite to all configured teams as an admin.

    $ ./datadog-users-cli --team Team1 --class adm
    I, [2018-01-17T02:21:45.450038 #319]  INFO -- : => Setting up users of role type 'adm' in Datadog team : 'Team1'
    I, [2018-01-17T02:21:45.452550 #319]  INFO -- : Configuring datadog adm user accounts in team Team1
    I, [2018-01-17T02:21:45.452717 #319]  INFO -- : The users to be processed are :
    I, [2018-01-17T02:21:45.452762 #319]  INFO -- : ["adminuser1@domain.com.au"]
    I, [2018-01-17T02:21:47.874661 #319]  INFO -- :   => User: adminuser1@domain.com.au DOES NOT exist - 404
    I, [2018-01-17T02:21:47.875022 #319]  INFO -- :     => Creating user kadminuser1@domain.com.au with role adm
    I, [2018-01-17T02:21:50.297291 #319]  INFO -- :     => Created adminuser1@domain.com.au with adm all OK - 200
    $

Re-running the command shows that the user is already configured as required and no changes need to be made for that particular team.

    $ ./datadog-users-cli --team Team1 --class adm
    I, [2018-01-17T02:23:36.896413 #325]  INFO -- : => Setting up users of role type 'adm' in Datadog team : 'Team1'
    I, [2018-01-17T02:23:36.898898 #325]  INFO -- : Configuring datadog adm user accounts in team Team1
    I, [2018-01-17T02:23:36.898960 #325]  INFO -- : The users to be processed are :
    I, [2018-01-17T02:23:36.899001 #325]  INFO -- : ["adminuser1@domain.com.au"]
    I, [2018-01-17T02:23:39.108504 #325]  INFO -- :   => User: adminuser1@domain.com.au DOES EXIST - 200
    I, [2018-01-17T02:23:39.108642 #325]  INFO -- :     => Validating the configuration of User: adminuser1@domain.com.au
    I, [2018-01-17T02:23:39.108704 #325]  INFO -- :     => User: adminuser1@domain.com.au IS configured as adm as required - adm

If we change the user account to be a standard user and it is configured in the tool as an admin, Re-running the command shows that the user is misconfigured and it updates the users configuration to be admin as required.

    $ ./datadog-users-cli --team Team1 --class adm
    I, [2018-01-17T02:24:47.496904 #331]  INFO -- : => Setting up users of role type 'adm' in Datadog team : 'Team1'
    I, [2018-01-17T02:24:47.498925 #331]  INFO -- : Configuring datadog adm user accounts in team Team1
    I, [2018-01-17T02:24:47.498982 #331]  INFO -- : The users to be processed are :
    I, [2018-01-17T02:24:47.499004 #331]  INFO -- : ["adminuser1@domain.com.au"]
    I, [2018-01-17T02:24:50.348166 #331]  INFO -- :   => User: adminuser1@domain.com.au DOES EXIST - 200
    I, [2018-01-17T02:24:50.348318 #331]  INFO -- :     => Validating the configuration of User: adminuser1@domain.com.au
    I, [2018-01-17T02:24:50.348392 #331]  INFO -- :     => User: adminuser1@domain.com.au IS NOT configured as adm as required - st
    I, [2018-01-17T02:24:50.348430 #331]  INFO -- :     => Updating user account adminuser1@domain.com.au to role adm
    I, [2018-01-17T02:24:51.498306 #331]  INFO -- :     => Updated adminuser1@domain.com.au to adm all OK - 200
    $


##### Additional information
- Future enhancements
The following enhancements are on the roadmap for this tool.
    - Validating the JSON responses written to disk to ensure that they are valid for restores
    - Validating the JSON files prior to attempting to restoring them
    - Validating the team passed to the CLI's are defined correctly in the configuration file and return a clean error message.


- This tool uses the Datadog Ruby SDK and the Datadog APIs, you can read more about them below;
    - [Datadog Ruby SDK](https://github.com/DataDog/dogapi-rb)
    - [Datadog API](https://docs.datadoghq.com/api/)

