# Ruby on Rails Application Overview

# Ruby-on-Rails: Developing, Upgrading, and Deploying

## Development and Testing

Testing is an integral part of releasing a new version of the BETYdb Rails app. Developers should test prospective code on their development machines prior to submitting a pull request, and code managers should re-test the code before accepting a pull request.  See [[running the automated tests | automated-tests]] for complete testing instructions.


## Deploying a new version:

**For up-to-date instructions on making a new release, see https://dlebauer.gitbooks.io/betydb-documentation/content/management/making_a_new_release.html**

At the end of each sprint (or set of sprints, or when ready to deploy a new version), the version should be tagged, and a "release" should be created.  See the [[Release Notes Template | Release-Notes-Template]] page for a sample draft of release notes.


(We use the terms "deploy" and "upgrade" roughly synonymously, but "deploy" connotes what code manager does when providing a new version of BETYdb to, say, the production server, and "upgrade" connotes what developers maintaining their own copies of BETYdb do to keep those copies up-to-date.  Making a new "release" is part of the deployment process but is not part of the upgrade process for individual users.

The instructions below are written mainly with the code manager in mind but are easily adapted to the needs of developers or maintainers of private copies of BETYdb.)


## Deploying or upgrading to a new version of the BETYdb Rails app

Here is an outline "script" for deploying a new version of BETYdb to the production server:

```bash
cd /usr/local/ebi # or to the Rails root of the copy you are upgrading

# Check the git status to be sure the copy is "clean".
# Generally there shouldn't be any modified files and you should be 
# on the master branch.
#
git status

# Get the latest code from Github.
#
git pull

# This is usually not necessary, but if there has been code checked in to the
# master branch since the version to be released, you will have to back up to it.
# Note that we tag releases AFTER deploying them, so we can't use the release tag
# as the git reference.
#
# git checkout <git reference to version being deployed>

# Check the gem bundle.
#
bundle check

# If the the bundle contains uninstalled Gems, run this:
#
bundle install

# Check for pending migrations.
#
RAILS_ENV=production bundle exec rake db:migrate:status
# The RAILS_ENV setting can be omitted by individual developers who only want
# to migrate their development databases.

# If there ARE pending migrations, run them (see below).

# Tell the server there is new code; you may want to run the automated tests
# BEFORE restarting the Rails server.
#
touch tmp/restart.txt
```

[Note: If you are using RVM version 1.11 or later, you can omit the "bundle exec" portion of all rake commands.  For example, the command above could be typed as just
```
RAILS_ENV=production rake db:version
```
]

If you do not wish to install the test pieces you can run `bundle install --without test`.

[Note: If you can't or don't wish to install the capybara-webkit gem, you can comment it out in the Gemfile.  It is only needed for testing the RSpec tests and it is only needed for a few of them.  To avoid running the tests that require it, run rspec with the "--tag ~js" option.]


At this point, the site can be tested, both through the browser and by running the [[automated tests]].  [To do: write hints for running automated tests on production servers]

_reference:_ [protocol for pull requests, testing etc. were discussed in [#48](https://github.com/PecanProject/bety/issues/48)]

### Running Migrations

If new code requires database migrations, then the database should be
dumped, and then the migrations should be run.  As noted above, you can find out whether there are migrations pending by comparing the result of
```
RAILS_ENV=production bundle exec rake db:version
```
with the latest migration shown by
```
ls db/migrate
```
If migrations are required, dump the database and run the migrations:
```
pg_dump ebi_production > [some suitable directory]/ebi_production.psql
# (Generally, after the dump file has been created, I rename it to include the timestamp 
# information in the file name: ebi_production_YYYYMMDDhhmm.psql.  This way multiple dump 
# files can be stored in the same directory.)
RAILS_ENV=production bundle exec rake db:migrate
```

**It is especially important to dump the database if any of the pending migrations will delete data!**

An up-to-date copy of db/production_structure.sql should be generated and checked in:

```
RAILS_ENV=production bundle exec rake db:structure:dump
git add db/production_structure.sql
git commit
git push
```

It is recommended to run this (only!) on the production version, since
it is the structure of the production database that we want to
document.  (That said, it is true that the pecandev and beta
deployments of the BetyDB database should have precisely the same
structure.  But in case they do not, we want to capture what is
actually be used live.)

Note that we no longer use the `schema.rb` file (see https://github.com/PecanProject/bety/issues/44).  The `structure.sql` files allow for complete documentation of the database structure, including features that (by default) are not expressible in the `schema.rb` file.  <strong>production_structure.sql is the canonical specification of the complete database schema, the schema which the Rails code is meant to be run against.</strong>

## Versioning and Tagging

### Protocol for defining and releasing versions

* **During Sprint**

  1. Merge pull requests into the master branch of PecanProject/bety as
  necessary (in order to avoid conflicts, preferably within one working
  day) .
  1. [to-do: clarify how we handle pre-releases and why they are necessary] Create a [pre-release](https://github.com/PecanProject/bety/releases/new). This should include a list of key expected features to be implemented during the sprint.
  1. If critical bug fix is required on production server:
      1. Create a branch off of the currently-deployed master version.  (If subsequent critical bug fixes are later needed, they can also go on this branch.)
      1. Apply the bug fix to the branch.
      1. Test on your development machine.
      1. Push the branch to PecanProject/bety.
      1. If time permits, pull the branch to pecandev, switch to the branch, do any necessary gem and database updates (see below) and test.
      1. Repeat the previous step on the production server's beta site.
      1. Repeat the previous step on the production server's live site.  The live server will now be on a branch until the next sprint release.
      1. If there were any database structure changes, regenerate the production\_schema.sql file and commit it.
      1. Tag the currently-deployed version. [to-do: decide on a schema for versioning branch releases]
      1. Push the tag (and the new production_schema.sql file if it changed) to the repository.
* **Before Sprint Review**
  1. Merge any remaining pull requests into master.
  1. Deploy and test (see below) on `pecandev.igb.illinois.edu:/usr/local/ebi`
  2. Deploy and test on `ebi-forecast.igb.illinois.edu:/usr/local/beta` (for the sprint-review demo).
* **After Sprint Review**
  2. Revise pre-release based on features implemented during sprint.
  1. If any code changes were made after the sprint review, redeploy and test on pecandev and on ebi-forecast's beta site.
  1. Deploy and test the latest master version on `ebi-forecast.igb.illinois.edu:/usr/local/ebi`
  3. Tag the published release.
  1. Ask David to 
    * post via the BETYdatabase account on Twitter
    * add doi to release 


### Version Numbering

We loosely follow [semantic versioning](http://semver.org/).

* Any tag of the form betydb\_x.x or betydb\_x.x.x refers to a version that has been tested and deployed.
* Changes in the first or second digit of the version number mark some
  significant change.  For example, the change to major version number
  2.x marks the change to a new user interface.

## Commenting in the Rails Models


Example of a properly commented citation model (
/app/models/citations.rb ):
[https://gist.github.com/e68fea1baa070e68b984](https://gist.github.com/e68fea1baa070e68b984)

And a properly commented covariates model ( /app/models/covariates.rb
):
[https://gist.github.com/5d0d96d7be1b1fd7b47c](https://gist.github.com/5d0d96d7be1b1fd7b47c)