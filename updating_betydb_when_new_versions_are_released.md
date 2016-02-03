# Updating BETYdb When New Versions are Released

## Updating BETY database

A new system is in place which will allow you to update the BETY database without losing any local changes (this is still BETA though). See the section [Distributed BETYdb](distributed_betydb.md) wiki for details on updating a local database in a way that retains any local changes.

If you are a BETYdb Ruby-on-Rails developer, you probably don't care about losing changes to your copy of the BETY database.  You probably just want a reasonably up-to-date copy that you can use to test code changes with.  If so, you may use the script `update-betydb.sh` in the `script` directory.  This is just a wrapper for `load.bety.sh` script that makes it easy to download that script (without having to download all of Pecan) and easy to run it with the options you probably want.  Step for doing this are:

1. Run `script/update-bety.sh` without options to download a copy of `load.bety.sh`.
2. Run `script/update-bety.sh -i` to write a stock configuration file.  This file will contain the following settings:

    ```
    export DATABASE=bety   # update database "bety"; change this name as needed
    export CREATE=YES      # completely overwrite the database you are updating with new content
    export FIXSEQUENCE=YES # needed for the CREATE option
    export USERS=YES       # create a stock set of users of various permission levels to use when testing
    ```

**DO NOT RUN THIS IF YOU HAVE DATA IN YOUR DATABASE!!!!!!!!!!!**

The CREATE=YES **WILL** destroy all data in your database

3. Run `script/update-bety.sh` again with no options.  This will read the config file you just created and use the settings to update your database copy.


## Update the Rails app and schema

If you have an instance of BETY and you might want to update it to the latest version at certain points for the following reasons.
- security updates
- new functionality
- importing data and remote server has newer version

To update BETY you can use the following steps to update your system (this is assuming the VM, if you installed BETY in another location please change the path accordingly). This requires the development version of ruby.

```bash
sudo -s
# change to BETY
cd /usr/local/bety
# update BETY to latest version
git pull
# install all required gems
bundle install --without test
# update database
RAILS_ENV="production" rake db:migrate 
# restart BETY
touch tmp/restart.txt
```

At this point your database should have migrated to the latest version and the BETY application should have restarted.

## Load a fresh version of database

See the section of Updating BETY database above that pertains to BETYdb Ruby-on-Rails developers. 