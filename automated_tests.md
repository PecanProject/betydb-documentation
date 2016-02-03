# Automated Tests

We use RSpec with Capybara for testing the BETYdb Rails application.  If you are involved in changing code, you should run the entire test suite before submitting a pull request.  If you discover a bug, you may wish to _write_ a failing test that demonstrates the bug, one that will pass once the bug is fixed.

# Running the RSpec tests on BETYdb.

## Preparing the test database.

[Note: The instructions below assume that the current Rails environment is `development` (the default).  If you have set it to something else--for example, by running `export RAILS_ENV=production` (you might do this, for example, if you only run BETYdb in production mode and didn't bother to set up a development environment or a development database)--modify these instructions accordingly.]

1. If you haven't yet done so, add the PostGIS extension to the default template database, `template1`.  The simplest way to do this is to add the PostGIS extension to the `template1` database template (`psql -d template1 -c 'CREATE EXTENSION postgis'`).  This is needed because the test database is dropped and recreated every time you run the "prepare" task, and you want it to be created with the PostGIS extension so that tables that rely on it can be recreated.
Alternatively, create a new template database that includes the PostGIS extension.  (See [below](#creating-a-new-postgis-enabled-database-template) for instructions.)
1. Go to the root directory of the copy of BETYdb that you are testing.
1. Ensure Rails has a test database configuration: Open the file `config/database.yml`.  It should have a section that looks something like

    ```yaml
    test:
      adapter: postgis
      encoding: unicode
      reconnect: false
      database: test
      pool: 5
      username: bety
      password: bety

    ```
If it doesn't, you can copy the section for `development` and then change the heading and the database specification to `test`.  If you wish to use a template database other than the default (`template1`), also add a line of the form

    ```yaml
      template: [your template name]
    ````

1. Create the test database by running

    ```
    bundle exec rake db:test:prepare
    ```
[Note: If you are using RVM version 1.11 or later, you can omit the "bundle exec" portion of all rake and rspec commands.  For example, the command above could just be typed as
   ```
   rake db:test:prepare
   ```
]
This will check for any pending migrations in the development database.  If there are none, it will re-create the `db/development_structure.sql` file, create the database for the testing environment ("test" if you use the configuration listed above), and then create the tables, views, functions, etc. mentioned in the _structure_ file.  _Note that we no longer use the `schema.rb` file_ (see https://github.com/PecanProject/bety/issues/44). The `config.active_record.schema_format` setting has been changed from `:ruby` to `:sql` to permit complete documentation of the database structure, including features that (by default) are not expressible in the `schema.rb` file.  <strong>production_structure.sql is the canonical specification of the complete database schema for the last-released version of BETYdb; this is the schema which the latest release of the Rails code is meant to be run against.</strong>
1. If there are pending migrations, run them ("`bundle exec rake db:migrate`") and repeat the previous step.
*Note: I found that I ran into permissions problems when attempting this step.  To get around this, I started psql as a superuser and then ran "ALTER USER bety WITH SUPERUSER;" to make user `bety` a superuser as well.  This shouldn't be a security worry if you are just running tests on your own copy of BETYdb.]
1. Populate the database from the fixtures:

    ```
    RAILS_ENV=test bundle exec rake db:fixtures:load
    ```
(The fixtures are YAML files under `test/fixtures`.)


## Running the tests

* The simplest way to run the tests is to simply run 

    ```
    bundle exec rspec
    ```
(or just `rspec` if you are using RVM > 1.11) from the root directory of the copy BETYdb that you are testing. This will run all the tests under the "spec" directory.
* If you did not install capybara-webkit, you can run all the tests that do not need webkit support with the command

    ```
    bundle exec rspec --tag ~js
    ```
This will skip all the tests that have the tag `:js => true` and run all the others.  (See the [Troubleshooting](#troubleshooting) section below for an alternative to capybara-webkit for running tests that need a JavaScript driver.)  Conversely, to run _only_ the tests requiring capybara-webkit, use the command

    ```
    RAILS_ENV=test_js bundle exec rspec --tag js
    ```

* **_Note that if you are logging in remotely to run the tests, you will need an X-server running in order to run the tests requiring capybara-webkit!_**  If you see the error

    ```
    webkit_server: cannot connect to X server
    ```
this probably means you connected without the -X option.  If you see the error

    ```
    webkit_server: Fatal IO error: client killed
    ```
this probably means the X-server is no longer running.  In either case, re-log in with an X-enabled connection.

* To run a specific file of tests, run `bundle exec rspec path/to/testfile`, optionally using the --tag option to skip certain tests.
* You can run a specific test in a file by appending a line number: 

    ```
    bundle exec rspec path/to/testfile:line_number_of_first_line_of_test
    ```
This command will appear under the "Failed examples" section of a test run (assuming the test failed); for example 

    ```
    bundle exec rspec ./spec/features/management_integration_spec.rb:48
    ```
* Some useful options to rspec are: 
  1. --fail-fast: abort the run on first failure
  2. --format documentation (-fd for short): get nicely formatted output
  3. --backtrace (-b for short): get a full backtrace

## Troubleshooting

Sometimes it is useful to carry out a features test manually as a web site user.  To do this, start up the rails server in the _test_ environment using the command `rails s -etest`.  Many or most of the features tests are written in such a way that you can figure out exactly what actions to carry out in order to mimic the test.

Alternatively, use the the Selenium JavaScript driver in place of Capybara Webkit.  The spec_helper file is set up to switch drivers automatically if you have set the environment variable RAILS_DEBUG=true.  For example:

   
        RAILS_DEBUG=true bundle exec rspec -t js
   

will run all your JavaScript-based tests using the Selenium JavaScript driver.  _As with Capybara Webkit, if you are logging in to a UNIX machine remotely in order to run the tests, you must have X11-forwarding in effect_ (use the -X option to your ssh command).  Otherwise all of your Javascript-enabled tests will time out (but not for a full minute!) and then fail.

With the Selenium JavaScript driver in place, each test having `js: true` in its opening line will be run by opening a copy of Firefox and replicating all of the actions specified in the test.  If you wish to insert a break point at any point in the test so that you can see the state of the browser at that point, add the line `binding.pry` at the point at which you want to suspend the test.  When running the test, pressing `Ctrl-D` at the command line will signal the test to continue.  [Note: `binding.pry` will cause an error if your JavaScript driver is not Selenium.  So if you switch back to running your test under Capybara Webkit, remove or comment out your breakpoints.]

Note that even tests that don't normally use a JavaScript driver can be debugged with Selenium--simply change the opening line.  For example, if you change the opening line of a test from

    it 'should return "Editing Citation" ' do

to

    it 'should return "Editing Citation" ', js: true do

the test will be run with a JavaScript driver (Selenium, if you set RAILS_DEBUG=true).  Then you can add `binding.pry` breakpoint lines as needed and see the test in action.

## Creating a new PostGIS-enabled database template

As mentioned above, you must have a PostGIS-enabled database template set up in order for the `rake db:test:prepare` command to work.  The easiest way to do this is to add the PostGIS extension to the default database template, which is called `template`.  This can be done with the command

    psql -d template1 -c 'CREATE EXTENSION postgis'

But you may not want to do this, as this will cause _all_ the databases you create to be PostGIS-enabled unless you explicitly specify a non-default template when you are creating them.

So here is how to create a new PostGIS-enabled database template:

1. Start psql and then run the following commands:
1. `CREATE DATABASE template_bety;`.  (You can name the template anything you like as long as it's not the name of an existing database.  Also, if you have made changes to template1 and want to ensure that template_bety is created from a "pristine" template, create it from template0:
   ```
   CREATE DATABASE template_bety TEMPLATE template0;
   ```
)
1. `\c template_bety`
1. `CREATE EXTENSION postgis;`
1. Change the owner of the newly-created table `spacial_ref_sys` to `bety` (or to the user whose username you specified in the "test" section of `config/database.yml`):

   ```
   ALTER TABLE spatial_ref_sys OWNER TO bety;
   ```
This will avoid permissions problems when you try to load fixtures into your test database in the case where you haven't made user `bety` a superuser.
1. `UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_bety';`
1. Finally, add the line

   ```
   template: template_bety
   ```
to the test database section of your `database.yml` file.