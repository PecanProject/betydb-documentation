# Installing a Production Copy of BETYdb on ebi-forecast or pecandev

These instructions are specifically tailored to the task of adding a new instance of BETYdb to a CentOS 5 machine using the deployment scheme we already currently have in place.  Thus, they assume the following are installed:

1. Ruby version 2.1.5.
2. Apache 2.2.
3. PostgreSQL 9.3.
4. PostGIS 2.1.3.
5. Git 1.8.2.1.


**In what follows, we assume the new Rails root directory has the name `betyapp`, the new BETY database copy has the name `betydb` with owner `dbuser` having password `dbpw`, and the deployment URL will be to a directory called `bety_url`. Substitute whatever names you wish for these.**



## Step 1: Clone a new BETYdb instance.[^1]

```sh
cd /usr/local
git clone https://github.com/PecanProject/bety.git betyapp
```

## Step 2: Create a Database Configuration File

To do this from the command line, just run[^2]
```sh
cat > config/database.yml << EOF
production:
  adapter: postgis
  encoding: utf-8
  reconnect: false
  database: betydb
  pool: 5
  username: dbuser
  password: dbpw
EOF
```

## Step 3: Create the New Database

Just run
```
createdb -U dbuser betydb
```
You will be prompted for dbuser's password.

## Step 4: Load the Database Schema

All table, views, constraints, indices, and functions for the BETY database are defined in the file db/production_structure.sql.  To load this file, run
```
bundle exec rake db:structure:load RAILS_ENV=production DB_STRUCTURE=db/production_structure.sql
```
The `RAILS_ENV` variable tells which block in `config/database.yml` to consult when looking up the database name, and the `DB_STRUCTURE` variable tells which file contains the database schema definition.[^3]

## Step 5: Run the Bundler to Install Ruby Gems

To install all Ruby Gems needed by the Rails application, run
```sh
bundle install --deployment
```

The deployment flag installs the Gems into the vendor subdirectory rather the to the global Ruby Gem location.  This makes your deployed instances more independent of one another.  Note that the `--deployment` option is a remembered option.[^4]

## Step 6: Make a Site Key File

This will create the needed file:
```sh
cat > config/initializers/site_keys.rb << EOF
REST_AUTH_SITE_KEY         = 'some moderately long, unpredictable text'
REST_AUTH_DIGEST_STRETCHES = 10
EOF
```

Without this, you won't be able to log in to the BETYdb Rails app.  For the site key to do any good, it should be kept a secret.

## Step 7: Configure Apache HTTP Server to Serve Your New Rails App Instance[^5]

First of all, create a symbolic link from the DocumentRoot directory `/var/www/html` to the public directory of you Rails instance:
```sh
cd /var/www/html
sudo ln -s /usr/local/bety_url/public bety_url
```

Now edit the VirtualHost configuration in file `/etc/httpd/conf.d/servers.conf` by adding the following inside 
```
<VirtualHost>


</VirtualHost>
```

First add a new RackBaseURI:
```
RackBaseURI /bety_url
```
Then add a new Directory block:
```
<Directory /var/www/html/bety_url>
    PassengerRuby [[path to ruby executable]]
</Directory>
```
Here, "path to ruby executable" varies with the machine.[^6]  On pecandev it is
```    
/usr/local/rvm/wrappers/ruby-2.1.5@betydb_rails3/ruby
```
On ebi-forecast, it is
```
/usr/local/ruby-2.1.5/bin/ruby
```

## Step 8: Restart the Apache Server

On pecandev, this works:
```
sudo apachectl restart
```

## Step 9: Create a  User

Go to the login page (ebi-forecast.igb.illinois.edu/bety_url or pecandev.igb.illinois.edu/bety_url) and click the "Register for BETYdb" button.  Fill out at least the required fields (Login, Email, and the two password fields), type the captcha text, and click "Sign Up".  You should see the "Thanks for signing up!" message.

**Note: In order for the "Login as Guest" button to work, you should create a user with login "guestuser" and password "guestuser".**

Once you have created a user, you may wish to given that user full access privileges.  To do this, use psql:
```sh
psql -U dbuser betydb
```
Once psql has started, if the login of the user you wish to alter is "myself", run
```sql
UPDATE users SET access_level = 1, page_access_level = 1 WHERE login = 'myself';
```
While you are at it, the guestuser should have privileges 4,4, so run
```sql
UPDATE users SET access_level = 4, page_access_level = 4 WHERE login = 'guestuser';
```

## Step 10: Test the New Deployment!






[^1] Except as noted, these instructions assume you are running commands as "yourself", that is, not as root or any other user with special permissions.

[^2] This sets up a bare-bones `database.yml` file for the production environment only.  You may wish to add sections for the development and test environments.  See the template file `config/database.yml.template` for a model.  It may be convenient in certain cases to use the same database for both development and production.  **_The test database, however, should always be different!_**

[^3] If you wanted to also set up a development database, then, assuming you had a block for the development environment section of `config/database.yml` that used the database name `betydb_dev` with the same username and password, you would first run
```sh
createdb -U dbuser betydb_dev
```
and then run
```sh
bundle exec rake db:structure:load RAILS_ENV=development DB_STRUCTURE=db/production_structure.sql
```
The development environment is usually the default, so the `RAILS_ENV` setting is most likely not strictly necessary.  **_Note that we still pull the database schema definition from `db/production_structure.sql` even though we are setting up a development database!_**

[^4] If you have trouble installing Capybara Webkit and you don't care about using it for testing, you can add the `--without=javascript_testing` option to your bundle install command to skip installing it.  This is a "remembered" option.  Subsequent "bundle install" commands will automatically use this option unless you remove it from the bundler configuration.

[^5] Instructions here are for sub-URL deployments.  These are deployments where the Rails root is reached via a URL of the form
```
http(s)://hostname/directoryname
```
Look at VirtualHost block for ServerName `www.betydb.org` on ebi-forecast for an example of a top-level deployment.  We need only specify the public directory of the instance as the DocumentRoot, obviating the need for a RackBaseURI directive.

[^6] The path to the ruby executable need not be set at the directory level if it is set globally to the version you want to use.  Therefore, this `<Directory` block may be unnecessary.



