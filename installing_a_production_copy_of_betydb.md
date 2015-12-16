# Installing a Production Copy of BETYdb on ebi-forecast or pecandev

These instructions are specifically tailored to the task of adding new instances of BETYdb to a CentOS 5 machine using the deployment scheme we already currently have in place.  Thus, they assume the following are installed:

1. Ruby version 2.1.5.
2. Apache 2.2.
3. PostgreSQL 9.3.
4. PostGIS 2.1.3.
5. Git 1.8.2.1.
6. R 3.1.0

In most or all cases later versions of these will work, and in many cases earlier versions may work as well.


**IMPORTANT! In what follows, we use the following placeholder strings to represent names that will vary with the installation:**
* **`<betyapp>` — the name of the Rails root directory for the BETY app instance**
* **`<betyappuser>` — the operating system account name for the user that will own this BETY app instance; generally, `<betyappuser>` should equal `<betyapp>`, but we distinguish them here for clarity.**
* **`<betydb>` — the name of the database this instance of the BETY app will use**
* **`<dbuser>` — the owner of database `<betydb>`**
* **`<dbpw>` — the password for database user `<dbuser>`**
* **`<bety_url>` — the path portion of the URL at which this BETY app instance will be deployed; this _usually_ (but not always) matches `<betyapp>`.**



## Step 1: Log in to the Deployment Machine.

You will need to have root access or sudo permission to add a new user and edit
the HTTPD configuration files.

## Step 2: Add a new user as the owner of the BETYdb instance

It is recommended to run each Rails app under its own user account.  By
convention, the user account will have the same name as the app.  Use the
following command to create the user:[^1]
```
CREATE_MAIL_SPOOL=no sudo useradd -M <betyappuser>
```

## Step 3: Clone a new BETYdb instance.

```sh
cd /usr/local
sudo -u <betyappuser> -H git clone https://github.com/PecanProject/bety.git <betyapp>
```

(Note that -H should only be used if you created a home directory for `<betyappuser>`.)

## Step 4: Log in as the app's user (`<betyappuser>`) and CD to the root directory of the new BETYdb instance.

You can log in by running
```
sudo -u <betyappuser> -H bash -l
```
Then do
```
cd <betyapp>
```

## Step 5: Create a Database Configuration File

To do this from the command line, just run[^2]
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

## Step 6: Create the New Database

Just run
```
createdb -U <dbuser> <betydb>
```
You will be prompted for `<dbuser>`'s password.

## Step 7: Load the Database Schema and Essential Data

Use the script `script/update-betydb.sh` to load the database schema.  `update-betydb.sh` is just a wrapper around the script `load.bety.sh`, which doesn't exist until you download it.  To do so, run `update-betydb.sh` without options:
```sh
./script/update-betydb.sh
```
Then re-run it with the -c, -e, -m, -r, -g, and -d options as follows:
```sh
./script/update-betydb.sh -c -e -m <localdb id number> -r 0 -g -d <betydb>
```
(Here, "localdb id number" is some integer that is unique to each database.  See https://github.com/PecanProject/bety/wiki/Distributed-BETYdb for further information.) 

This will create the tables, views, indices, constraints, and functions required for BETYdb.  The tables will all be empty except for the following: `formats`, `machines`, `mimetypes`, `schema_migrations`, `spacial_ref_sys`, and `users`.  A guestuser account will be added to the users table.
[^3]

## Step 8: Run the Bundler to Install Ruby Gems

To install all Ruby Gems needed by the Rails application, run
```
bundle install --deployment --without development test javascript_testing debug
```

The deployment flag installs the Gems into the vendor subdirectory rather than to
the global Ruby Gem location.  This makes your deployed instances more
independent of one another.  The `--without` flag omits installing Gems that are
only used in the test and developments environments.  (They may be installed
later if desired.)  Note that the `--deployment` and `--without` options are
remembered options.[^4]

## Step 9: Make a Site Key File

This will create the needed file:
```sh
cat > config/initializers/site_keys.rb << EOF
REST_AUTH_SITE_KEY         = 'some moderately long, unpredictable text'
REST_AUTH_DIGEST_STRETCHES = 10
EOF
```

Without this, you won't be able to log in to the BETYdb Rails app.  You can run the command
```
bundle exec rake secret
```
in the Rails root directory to generate an arbitrary key.
For the site
key to do any good, it should be kept a secret.  _Note that if you ever change
the value of `REST_AUTH_SITE_KEY`, all of your user's passwords will be
invalidated!_

## Step 10: Configure Apache HTTP Server to Serve Your New Rails App Instance[^5]

Add the following to your Apache HTTP Server configuration:
```
Alias /<bety_url> /usr/local/<betyapp>/public
<Location /<bety_url>>
    PassengerBaseURI /<bety_url>
    PassengerAppRoot /usr/local/<betyapp>
    # Also add the following as needed (see note below)
    # PassengerRuby [[path to ruby executable]]
</Location>
<Directory /usr/local/<betyapp>/public>
    Allow from all
    Options -Multiviews
    # Uncomment this if you're on Apache >= 2.4:
    # Require all granted
</Directory>
```

If you are using virtual hosting (we _are_ on pecandev and ebi-forecast, and so
we add this to a VirtualHost configuration in file
`/etc/httpd/conf.d/servers.conf`), put this inside the VirtualHost block whose
ServerName and/or ServerAlias values correspond to the URL at which you want to
access the application (pecandev.igb.illinois.edu and
ebi-forecast.igb.illinois.edu on pecandev and ebi-forecast, respectively).
Otherwise, include the configuration code at the top level.

Note that the documentation at
https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/ says to use
`Require all granted` for Apache versions _greater_ than 2.4, but it seems that
this is required for version 2.4 itself.  (As of this writing, both pecandev and
ebi-forecast use version 2.2).


Note: As of this writing, the path to the Ruby executables that should be used are
```    
/usr/local/rvm/wrappers/ruby-2.1.5@betydb_rails3/ruby
```
on pecandev, and
```
/usr/local/ruby-2.1.5/bin/ruby
```
on ebi-forecast.  Check the value of PassengerDefaultRuby in
`mod_passenger.conf`.  If the path doesn't match the appropriate setting, you
must either override it with a PassengerRuby setting or update it (being sure to
override the new default if necessary for any Rails applications that still need
to use the old setting).  If you are using a virtual host and all of the Rails
applications served by that host will use this Ruby version, you may add the
PassengerRuby directive directly inside the VirtualHost block.  Otherwise,
restrict it to a particular location by placing it in the Location block for the
app instance you are adding as shown above.



## Step 11: Restart the Apache Server

On pecandev, this works:
```
sudo apachectl restart
```

At this point you should be able to view the site at https://ebi-forecast.igb.illinois.edu/<bety_url> or http://pecandev.igb.illinois.edu/<bety_url>, depending on which machine you deployed to.

## Step 12: Create an Administrative Account

Go to the login page (https://ebi-forecast.igb.illinois.edu/<bety_url> or http://pecandev.igb.illinois.edu/<bety_url>) and click the "Register for BETYdb" button.  Fill out at least the required fields (Login, Email, and the two password fields), type the captcha text, and click "Sign Up".  You should see the "Thanks for signing up!" message.

Once you have created a user, give that user full access privileges.  To do this, use psql:
```sh
psql -U <dbuser> <betydb>
```
Once psql has started, if the login of the user you wish to alter is "betydb-admin", run
```sql
UPDATE users SET access_level = 1, page_access_level = 1 WHERE login = 'betydb-admin';
```


## Step 13: Set the Guest User Account Password

The Guest User account password will not be set correctly unless you
used 'thisisnotasecret' as the site key in step 6, and you shouldn't
use this as a site key on a production server.  So you need to reset
the guestuser password.

Log in as the administrative user and go to the Users list.  Search
for "guestuser" and click the edit button for that user.  Check the
"change password" checkbox and then enter "guestuser" in both password
fields; then click the "Update" button.

Now log out and try the "Log in as Guest" button.

___

[^1] The relevant Phusion Passenger documentation is at
https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/nginx/oss/rubygems_norvm/deploy_app.html.
You may wish to give the <betyappuser> account a home directory—for example, to
be able to log in as that user with an ssh key.  In this case, leave out the `-M`
option.

[^2] This sets up a bare-bones `database.yml` file for the production environment only.  You may wish to add sections for the development and test environments.  See the template file `config/database.yml.template` for a model.  It may be convenient in certain cases to use the same database for both development and production.  **_The test database, however, should always be different!_**

[^3] All table, views, constraints, indices, and functions for the BETY database are defined in the file db/production_structure.sql.  We could have loaded the database schema by loading this file: 
``` 
bundle exec rake db:structure:load RAILS_ENV=production DB_STRUCTURE=db/production_structure.sql 
``` 
(The `RAILS_ENV` variable tells which block in `config/database.yml` to consult when looking up the database name, and the `DB_STRUCTURE` variable tells which file contains the database schema definition.)  This would have created an entirely empty database, however, and would not set the initial indices for newly-generated ids so as to be compatible with the database synchonization scripts.

For the developement environment's database, this all probably does not matter; if you wanted to also set up a development database, then, assuming you have a block for the development environment section of `config/database.yml` that uses the database name `betydb_dev` with the same username and password, you would first run
```sh
createdb -U <dbuser> betydb_dev
```
and then run
```sh
bundle exec rake db:structure:load RAILS_ENV=development DB_STRUCTURE=db/production_structure.sql
```
The development environment is usually the default, so the `RAILS_ENV` setting is most likely not strictly necessary.  **_Note that we still pull the database schema definition from `db/production_structure.sql` even though we are setting up a development database!_**

[^4] If you set up the development and test database specifications in step 5, this means you probably actually want to be able to use these environments.  In this case you should omit the `--without` flag.

Some users may want to do _some_ testing but may have trouble installing
Capybara Webkit.  If you don't care about using Capabara Webkit for testing, you
can add the `--without javascript_testing` option to your bundle install command
to skip installing it.  Similarly, add `--without debug` to skip installation of
the Selenium web driver, or skip both with `--without javascript_testing debug`.
Again, this is a "remembered" option: subsequent "bundle install" commands will
automatically re-use the `--without` option unless you remove it from the
bundler configuration.  But note that if you specify the `--without` option a
second time, the list of groups to skip will overwrite any previous remembered
list; you must specify the complete list of groups you wish to skip each time
unless the list is the same as it was the last time you ran `bundle install`.

[^5] Instructions here are for sub-URL deployments.  These are deployments where the Rails root is reached via a URL of the form
```
http(s)://hostname/directoryname
```
Look at VirtualHost block for ServerName `www.betydb.org` on ebi-forecast for an example of a top-level deployment.  We need only specify the public directory of the instance as the DocumentRoot, obviating the need for a PassengerBaseURI directive.




