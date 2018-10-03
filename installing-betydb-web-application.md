# Deploying a Production Copy of the BETYdb Web Application

These instructions are specifically tailored to the task of setting up a new
instance of BETYdb on a CentOS 7 machine.  We assume the following are installed:

1. Ruby Version Manager (RVM).
1. Bundler
1. Phusion Passenger
1. Apache 2.2 or greater.
1. PostgreSQL 9.3 or greater.
1. PostGIS 2.1.0 or greater.
1. Git 1.8.2.1 or greater.
1. R 3.1.0 or greater.[^package_notes]
1. Graphviz dot version 2.2.1 or a version greater than 2.4.[^package_notes]
1. Java 1.8 or greater.[^package_notes]
1. nodejs and npm
1. curl
1. Your preferred editor.

In addition, we assume:

1. You have an account on the machine, and that account has sudo access.
2. The PostgreSQL server is running and there is a machine user account called
   `postgres` with password-less (_peer_) access to all PostgreSQL databases.
3. PostgreSQL has been configured so that all non-postgres database roles can
   log in to the PostgreSQL server using a password, both using a UNIX domain
   socket connection and using a connection to `localhost` over TCP/IP.

Information about installing CentOS, adding users, installing the requisite
software, and setting up and starting the PostgreSQL server is contained in
various subsections below.

**IMPORTANT! In what follows, we use the following placeholder names to
  represent names that will vary with the installation:**

* Operating system accounts:
  * **`<adminuser>` — the operating system account name for a user with complete sudo access**
  * **`<betyappuser>` — the operating system account name for the user that will
      own this BETY app instance; generally, `<betyappuser>` should equal
      `<betyapp>`, but we distinguish them here for clarity**
* Path names:  
  * **`<betyapp>` — the name of the parent directory of the Rails root directory for the BETY app instance**
* Database-related names:
  * **`<betydb>` — the name of the database this instance of the BETY app will use**
  * **`<dbuser>` — the owner of database `<betydb>`**
  * **`<dbpw>` — the password for database user `<dbuser>`**

For convenience, we generally leave off the angle brackets below as if these are
the actual names that we will be using.  In practice, sometimes the same name
will be used for several of these; for example, often `<betyappuser>`,
`<betyapp>`, `<betydb>`, `<dbuser>`, and `<dbpw>` will all be
"bety".


## Installing and Configuring Ruby and Rails Code

### Step 1: Log in to the deployment machine as an administrator {-}

This is the account we refer to as `<adminuser>` above.  This user will need to
have sudo permissions to do such tasks as adding a new user, deploying the
BETYdb code base, editing the HTTPD configuration files, and starting and
restarting the Web server.

### Step 2: Add a new user as the owner of the BETYdb instance {-}

It is recommended that each Rails app be run under its own user account.  Use
the following command to create the user:[^phusion_passenger]

```
sudo useradd <betyappuser>
```

Also, you may want to ensure this user has your SSH key installed:
```bash
sudo mkdir -p ~betyappuser/.ssh
touch $HOME/.ssh/authorized_keys
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~betyappuser/.ssh/authorized_keys"
sudo chown -R betyappuser: ~betyappuser/.ssh
sudo chmod 700 ~betyappuser/.ssh
sudo sh -c "chmod 600 ~betyappuser/.ssh/*"
```


### Step 3: Choose a location for the application code {-}

In this example, we'll choose `/var/www/betyapp` as the parent directory for the
Rails root directory, which we'll call `code`.

### Step 4: Create the target parent directory and clone the BETYdb code from the GitHub repository: {-}

```bash
sudo mkdir -p /var/www/betyapp
sudo chown betyappuser: /var/www/betyapp
cd /var/www/betyapp
sudo -u betyappuser -H git clone https://github.com/PecanProject/bety.git code
```

### Step 5: If you have not already done so, install the correct version of Ruby {-}

First cd to the Rails root directory:
```bash
cd /var/www/betyapp/code
```

If you haven't installed any versions of Ruby using the Ruby Version Manager,
you should get a warning that the required version of Ruby is not installed
along with the command to run to install it.  Go ahead and install this version.
This command should have the form

```
rvm install "ruby-X.X.X"
```
where "ruby-X.X.X" matches the contents of the file `.ruby-version`.

You can use
```
rvm list
```
to check that you have the correct version of Ruby installed, and
```
rvm current
```
to check that you have the correct version activated.


_The next several steps should be run as the app's user (`<betyappuser>`)._


### Step 6: Log in to the application's user account and make sure you are in the Rails root directory: {-}

```bash
sudo -u betyappuser -H bash -l
cd /var/www/betyapp/code
```

You may get error about not being able to create a gemset, which you may ignore,
but you should check that the correct version of Ruby is active:
```
rvm current
```

### Step 7: Use the Bundler to install the application Gems: {-}

```bash
bundle install --deployment --without development test javascript_testing debug
```

If the bundler fails to install the "pg" Gem, use the "bundle config" command to
add an option as follows and then re-run the bundle install command:[^sticky_bundle_configuration]
```bash
bundle config --local build.pg --with-pg-config=/usr/pgsql-9.4/bin/pg_config
bundle install
```

### Step 8: Create a database configuration file {-}

To do this from the command line, just run
```
cat > config/database.yml << EOF
production:
  adapter: postgis
  encoding: utf-8
  reconnect: false
  database: <betydb>
  pool: 5
  username: <dbuser>
  password: <dbpw>
EOF
```
replacing the placeholders `<betydb>`, `<dbuser>`, and `<dbpw>` with whatever
identifiers you chose to user for these entities.

### Step 9: Create a Rails application customization file {-}

The most important purpose of this file is to override the default site key so
that your site will be more secure.

First, generate a secret key using the command
```bash
bundle exec rake secret
```
Then run
```bash
cat > config/application.yml << EOF
production:
  rest_auth_site_key: '<secret key>'
EOF
```
where `<secret key>` is the result of the `rake secret` command.

This is a minimal application configuration file.  There are many other settings
that may be used to customize the appearance of your site.  See the sample file
`config/application.yml.template` for details.  At the very least, it is highly
recommended to set the contact information appropriate for your site.

Below, we show how to modify this file to enable the SchemaSpy documentation
generator.
   
### Step 10: Compile Rails assets: {-}
```bash
bundle exec rake assets:precompile RAILS_ENV=production
```

**Important!** If you are planning to deploy the BETYdb app to a sub-URI of your
server name—to `yourserver.com/suburi`, say, instead of `yourserver.com`—then
you need to set the RAILS_RELATIVE_URL_ROOT variable when precompiling:

```bash
bundle exec rake assets:precompile RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/suburi
```

## Loading the BETYdb Database

_For this first step you should still be logged in as `<betyappuser>` and still
be in the `/var/www/betyapp/code` directory._

### Step 11: Download the load.bety.sh script from the PEcAn repository: {-}
```bash
curl https://raw.githubusercontent.com/PecanProject/pecan/develop/scripts/load.bety.sh > script/load.bety.sh
chmod +x script/load.bety.sh
```

Now exit the `<betyappuser>` account:
```bash
exit
```

You should now be back to the administrator account `<adminuser>` that you
originally logged in to.

### Step 12: If you aren't already there, cd to the application root directory: {-}
```bash
cd /var/www/betyapp/code
```

### Step 13: Log in as user postgres: {-}
```bash
sudo su postgres
```

### Step 14: Create a role and a database for the BETYdb app {-}

First start psql:

```bash
psql
```

Now run the `CREATE ROLE` and `CREATE DATABASE` commands in psql:

```
CREATE ROLE dbuser WITH LOGIN CREATEDB NOSUPERUSER NOCREATEROLE PASSWORD 'dbpw';
CREATE DATABASE betydb WITH OWNER dbuser;
\q
```

### Step 15: Run the load.bety.sh script: {-}
```bash
script/load.bety.sh -a postgres -c -d betydb -e -g -m <localdb id number> -o dbuser -r 0
```

Here, `<localdb id number>` is some integer that is unique to each database. See
[Distributed BETYdb](distributed_betydb.md#primary-key-allocations) for further
information.


This will create the tables, views, indices, constraints, and functions required
for BETYdb, replicating the database schema found on machine 0, the Energy
Biosciences Institute server for BETYdb, whose BETYdb database schema is
considered the "canonical" or "official" schema.[^schema] (Other machines may
have a slightly modified schema, so it is important to use the creation (`-c`)
option only when the remote machine is machine 0.)  The tables will all be empty
except for the following: `formats`, `machines`, `mimetypes`,
`schema_migrations`, `spacial_ref_sys`, and `users`.  A guest user account
("guestuser") will be added to the users table.

This machine's database contains the most extensive metadata, so you may want
load the _data_ from this machine, not just the database schema.  To do so, run
the above command without the "-e" option.

### Step 16: (Optional) Load data from another machine: {-}
```bash
script/load.bety.sh -a postgres -d betydb -m <localdb id number> -o dbuser -r <remotedb id number>
```

This may be executed multiple times with different remote database id numbers.
Again, consult [Distributed
BETYdb](distributed_betydb.md#primary-key-allocations) to see what data sources
are available.

(If you used the `-e` option in the previous step but then decided you want the
full data from machine 0 after all, you can chose `<remotedb id number>`=0.)

### Step 17: Exit the postgres user account: {-}

```bash
exit
```

You should now once again be in the administrative account (`<adminuser>`) and
in the BETYdb app's root directory, `/var/www/betyapp/code`.


## Complete Apache and Passenger configuration

### Step 18: Check that the correct version of Ruby is enabled: {-}

```bash
rvm current
```

This should be the version listed in the file .ruby-version

### Step 19: Find the path to the Ruby interpreter: {-}

```bash
passenger-config about ruby-command
```

Use the location given in the resulting output as the value of `path-to-ruby` in
the next step.

### Step 20: Configure the Apache Server {-}

Create a new Apache configuration file (call it, say, `bety.conf`) in the
configuration directory `/usr/httpd/conf.d` and open it in an editor.  Add the
following contents to the file:[^ssl]

      <VirtualHost *:80>
          ServerName yourserver.com

          # Tell Apache and Passenger where your app's 'public' directory is
          DocumentRoot /var/www/betyapp/code/public

          PassengerRuby /path-to-ruby

          # Relax Apache security settings
          <Directory /var/www/betyapp/code/public>
            Allow from all
            Options -MultiViews

            SetEnv SECRET_KEY_BASE <secret key>
            # (Alternatively, put "export SECRET_KEY_BASE=<secret key>" in the
              .bash_profile file for user <betyappuser>.)

            # Uncomment this if you're on Apache >= 2.4:
            #Require all granted
          </Directory>
      </VirtualHost>

   Here, replace `yourserver.com` with your server's host name and replace
   `/path-to-bety` with the path found above using the `passenger-config`
   command.

   Also, replace `<secret key>` with some long, random word.  You can generate a
   suitable value using the command

      bundle exec rake secret

   (As noted in the comment, this setting can be put in the environment of
   `<betyappuser>` instead of here in the server configuration file.)

   Note: If you want your app to be served at a sub-URI of your server name,
   say, `yourserver.com/suburi`, use the following configuration instead:

      <VirtualHost *:80>
          ServerName yourserver.com
          
          PassengerRuby /path-to-ruby

          Alias /suburi /var/www/betyapp/code/public
          <Location /suburi>
              PassengerBaseURI /suburi
              PassengerAppRoot /var/www/betyapp/code
          </Location>
          <Directory /var/www/betyapp/code/public>
              Allow from all
              Options -MultiViews

              SetEnv SECRET_KEY_BASE <secret key>

              # Uncomment this if you're on Apache >= 2.4:
              #Require all granted
          </Directory>
      </VirtualHost>

### Step 21: Restart Apache: {-}

      sudo apachectl restart

### Step 22: Test: {-}

      curl yourserver.com

   or, if you deployed to a suburi,

      curl yourserver.com/suburi

   Alternatively, try visiting the URL in a browser.


## Final Steps

### Step 23: Create a BETYdb administrative account {-}

In a browser, visit the home page of your new BETYdb site and click the
"Register for BETYdb" button.  Fill out the form; at a minimum, you must supply
values for "Login", "Email", "Password", and "Confirm Password" and click the
"I'm not a robot" checkbox.  It is highly recommended to fill out the "Name"
field as well since this is the name that will be displayed when you are logged
in as the new user.  Note that you cannot re-use a previously used login or
e-mail address.

After completing the form, click "Sign Up".  You should see the "Thanks for
signing up!"  message.

Once you have created a user, give that user full access privileges.  To do this, use psql:
```bash
psql -U <dbuser> <betydb>
```

Once psql has started, if the login of the user you wish to alter is "admin",
run these commands in the psql session:

```sql
UPDATE users SET access_level = 1, page_access_level = 1 WHERE login = 'admin';
\q
```


### Step 24: Re-Set the Guest user account password {-}

The Guest User account password will not be set correctly unless you use
'thisisnotasecret' as the site key.  But for security reasons, you shouldn't use
this as a site key on a production server (which was the reason for overriding
the value of `rest_auth_site_key` in the customization file
`config/application.yml`).  So you need to reset the Guest User account's
password to get it to work again.

Log in to BETYdb as the administrative user you created in the previous step and
go to the Users list (menu item `Data/Users`).  Search for "guestuser" and click
the edit button for that user.  Check the "change password" checkbox and then
enter "guestuser" in both password fields; then click the "Update" button.

Now log out and try the "Log in as Guest" button to make sure that it works.


### Step 25: Ensure images for Priors pages are generated {-}

BETYdb uses `R` to generate images for the Priors pages on the fly if they don't
already exist.  In order for this to work, the `ggplot2` `R` package must be
installed.

To do this, start up `R` using
```bash
sudo R --vanilla
```
Then, inside the `R` session, issue the command
```R
install.packages(c("ggplot2"))
```

This will likely take a few minutes.  To check that all is well, open the BETYdb
app in a browser and navigate to the Data/Priors page.  The images in the middle
column should start being generated on the fly.

### Step 26: Ensure the SchemaSpy documentation can be generated {-}

SchemaSpy documentation is generated using Java.  Two Jar files are needed, a
PostgreSQL JDBC Driver file and a customized version of the SchemaSpy file.
These need to be downloaded to a suitable location.  By way of example, we'll
put them in `/var/www/betyapp/code/lib/tasks/jar`.  To do this, first log in to
the `betyappuser` account:

```bash
sudo -u betyappuser -H bash -l
```

Then run the following commands:

```bash
cd /var/www/betyapp/code/lib/tasks
mkdir jar
cd jar
wget https://www.dropbox.com/s/j50hk7cbqw7680u/schemaSpy.jar
wget https://jdbc.postgresql.org/download/postgresql-42.2.4.jar
```
Here, we use the latest JDBC Driver file as of this writing,
postgresql-42.2.4.jar.

Now, append to the `config/application.yml` configuration file as follows (be
sure to use `>>` instead of `>`):
```
cat >> config/application.yml << EOF

schema_spy_settings:
    java_executable: java
    postgresql_driver_jar_file: lib/tasks/jar/postgresql-42.2.4.jar
    settings_for_customized_documentation:
        schema_spy_jar_file: lib/tasks/jar/schemaSpy.jar
        output_directory: .
        remove_root_dir_files: true

EOF
```

Run the `rake` task to generate the SchemaSpy documentation as follows:
```bash
bundle exec rake bety:dbdocs RAILS_ENV=production
```

Restart the Rails app with
```bash
touch tmp/restart.txt
```
and try visiting the database documentation in a browser by going to the URL for
your running BETYdb instance and clicking the `Schema` menu item under the
`Docs` menu.

**You should now have a fully-functional BETYdb instance.**

___
[^package_notes]: BETYdb will mostly run without R, dot, and Java.  R is needed for generating preview images on the Priors pages.  Java is needed in order to generate the database schema documentation, and dot is needed to generate diagrams for that documentation.

[^phusion_passenger]: The relevant Phusion Passenger documentation is at https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/apache/oss/el7/deploy_app.html#rails_login-to-your-server-create-a-user-for-the-app

[^sticky_bundle_configuration]: We don't need to repeat all the options to `bundle install` that we used earlier because these options are "sticky": they are stored in the bundle configuration file and will be used automatically until explicitly removed.

[^schema]: Unless otherwise noted, we use the word "schema" in its traditional sense, where it refers to the logical structure of a database, including the tables, views, functions, and integrity constraints it comprises.  We are not using "schema" in its PostgreSQL-specific sense, where it refers to a namespace within a database.

[^ssl]: If the Web site is to be served using SSL (Secure Sockets Layer), the virtual host directive should be `<VirtualHost *:443>`.  Data providers that are particularly concerned about data security are advised to use SSL.  If SSL is used, it is recommended to redirect calls to port 80 (http) to port 443 (https) using a directive such as the following:
```
<VirtualHost *:80>
    ServerName yourserver.com
    Redirect permanent / https://yourserver.com
</VirtualHost>
```
or, for suburi deployments,
```
<VirtualHost *:80>
    ServerName yourserver.com
    Redirect permanent /suburi https://yourserver.com/suburi
</VirtualHost>
```



