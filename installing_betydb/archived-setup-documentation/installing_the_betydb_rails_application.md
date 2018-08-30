# Installing the BETYdb Rails Application

## Installing the BETYdb Rails Application

_Note:_ This guide is aimed at Rails developers and testers. If you are a Pecan developer, you may want to use the notes in the [PEcAn documentation](https://pecan.gitbooks.io/pecan-documentation/content/installation/Installing-PEcAn.html) instead of or in addition to the notes below.

_quick start_ The install\_pecan.sh script contains [steps used to create a Virtual Machine on line 398](https://github.com/PecanProject/pecan/blob/master/scripts/install_pecan.sh#L398) and [dependencies for different OS's on line 102](https://github.com/PecanProject/pecan/blob/master/scripts/install_pecan.sh#L102)

## Prerequisites

1. Git
2. Ruby 2.1.5 \(Anything later than version 1.9.3 will probably work, but 2.1.5 is the officially supported version.\) If you are doing Rails development or if you are using Ruby for outside of BETYdb, you may want to install RVM so that you can easily switch between Rails versions and Gem sets.
3. PostgreSQL with the PostGIS extension \(see [Installing and Configuring PostgreSQL](https://github.com/PecanProject/betydb-documentation/tree/3435da5bf429a7fbc0a72861937e41612834f3f8/Installing-PostgreSQL/README.md) for information on installing and configuring PostgreSQL\)
4. Apache web server \(optional; developers in particular can simply use the built-in Rails server\)

In addition, the scripts below assume you have a working Bash shell. \(Windows users might be able to use Cygwin or some other some other port of Linux tools.\)

## Installing the Rails Application

### Installing the Rails code and Ruby Gems

Run these commands to get the Rails code and the Ruby Gems that it uses:

```bash
# This can be any place you have write permissions for, probably something under your home directory:
INSTALLATION_DIRECTORY=~/projects

# install bety
cd $INSTALLATION_DIRECTORY

# Developers who will be submitting Git pull requests should make a fork of bety.git on GitHub and then
# replace the URL below with the address of their own copy:
git clone https://github.com/PecanProject/bety.git

# install gems
cd bety
gem install bundler # not needed if you already have bundler
bundle install # Use the --without option to avoid installing certain groups of Gems; see below.
exit
```

\[Note: If you can't or don't wish to install the capybara-webkit gem, you can comment it out in the Gemfile before running bundle install.

Note: If you receive "checking for pg\_config... no" and the associated errors then you may need update build.pg using the "bundle config" command. For example, to update the bundle executable with the location of the pg\_config command you can run: _bundle config build.pg --with-pg-config=/usr/pgsql-9.4/bin/pg\_config_ This assumes your pg\_config is located at _/usr/pgsql-9.4/bin/_. Update this path as necessary for your local PostgreSQL/Postgis install\]

#### Minimizing Gem Installation

Certain Ruby Gems are difficult or time-consuming to install on certain platforms, and if they are not essential to your work, you may wish to avoid installing them. \(If this isn't a concern, you may skip this section.\)

If you look at the Gemfile in the root directory of the BETYdb Rails code, you will see the certain Gems are specified within _group_ blocks; this means they are intended to be used only in certain contexts. If you don't intend to use BETYdb within those contexts, you may safely use the `--without` option to `bundle install` to exclude the Gems used only in those contexts.

As an example, the passenger Gem is used only in the production environment. Therefore, it is in a `production` group within the Gemfile. If you run

```text
bundle install --without=production
```

the bundler will skip installation of passenger.

Moreover, this is a "remembered" option: the next time you run `bundle install`, it will remember not to install production-only Gems even if you haven't specified the `--without` option. Furthermore, this "remembered option" is also respected by WEBrick, the default Rails server, so it won't complain that you didn't install the passenger Gem.

As another example, the `capybara-webkit` Gem is difficult and time-consuming to install on some platforms, and unless you are running the RSpec tests, you can do without it. \(In fact, even if you _are_ running RSpec tests, most of the tests don't use `capybara-webkit`, and for those that do, you can either skip them or tell them to use `selenium-webdriver` instead.\)

`capybara-webkit` is in a group called `javascript_testing`, so to avoid installing it, run

```text
bundle install --without=javascript_testing
```

To see what the remembered "without" options are, run

```text
bundle config
```

You can also use `bundle config` to specify directly what groups Bundler should skip. For example, to tell Bundler to ignore all groups except the production group, pass a colon-separated list containing all of the _other_ groups to `bundle config --local without`:

```text
bundle config --local without development:test:javascript_testing:debug
```

To revert to installing everything when you run `bundle install`, remove the `without` setting from the configuration with

```text
bundle config --delete without
```

### Configuring Rails

Configure the BETYdb Rails application using the following commands:

```bash
cd $INSTALLATION_DIRECTORY/bety

# setup bety database configuration
cat > config/database.yml << EOF
development:
  adapter: postgis
  encoding: utf-8
  reconnect: false
  database: bety
  pool: 5
  username: bety
  password: bety
EOF

# Optional: Override some of the default configuration settings given in config/defaults.yml.
cp config/application.yml.template config/application.yml
# Read the comments in this file and set the variable values you are interested in; delete the other settings.
```

### Installing the Database

_**Note**_ to join the distributed network of databases, see the chapter ["Distributed BETYdb"](../../betydb-system-administration/distributed_betydb.md)

In the `script` directory of the bety Rails installation, find and run the update-betydb.sh script:

```text
./update-betydb.sh
```

This script is a wrapper script for the script `load.bety.sh` from the Pecan project. The latter can be downloaded by running `update-betydb.sh` without options. Use the `-h` option for more information.

## Updating / Syncing the database

See instructions \[\[Updating-BETY\]\]

## Starting the BETYdb Rails Web Application

1. cd to the bety directory, the directory you cloned the Rails code to.
2. Run `rails s`.
3. You should now be able to visit the web application at [http://localhost:3000](http://localhost:3000).
4. To log in, use `Login: carya`, `Password: illinois`

## Logrotation

To prevent the log files from growing to large it is recommended to use logrotation. This will rotate the logs \(for example every week\) and append .1 etc to the logfiles. The following can be used on an Ubuntu system.

Edit `/etc/logrotate.conf` and add the following snippet at the bottom \(replacing /home/bety/bety with the actual path to the installation of bety\):

```text
/home/bety/bety/log/*.log {
  daily
  missingok
  rotate 7
  compress
  delaycompress
  notifempty
  copytruncate
}
```

Once this installed you can force a logrotate to happen \(or wait till Sunday\) by using: `sudo /usr/sbin/logrotate -f /etc/logrotate.conf`

