# Issuing a new release of the BETYdb Rails application

From time to time, or whenever an important and needed code change is made, the
principle maintainer of the BETYdb Rails application should issue a new release
and upgrade all of the sites under his or her purview.[^principle_site_list] In
what follows, we delineate the key steps in this process.

## Writing release notes

Begin a new release by visiting the Web page
https://github.com/PecanProject/bety/releases and clicking the _Draft a new
release_ button.  The begin writing release notes in the large textarea box.

The release notes should begin with a one-line summary of the release, written
as a level-one heading (that is, with one "#" mark flush left).  Follow this
with a paragraph describing the release in slightly greater detail.

Subsequent sections should summarize new features, bug fixes, and give some
instruction to site maintainers on doing an upgrade to the new release.

An easy way to begin writing release notes is to use an earlier version's
release notes (perhaps the notes from the previous one) as a template.  Just
click on the _Releases_ link, click the _Edit_ button of the release you choose
to be you model, copy the text from the description section to the clipboard,
and paste it into the description section for the release you are creating.
Then change the text of each section as appropriate.

To remind oneself of what changes to the code have been made since the previous
release, you can examine the Git log content starting with the previous release
using (for example) the command

```
git log betydb_x.xx..master --stat
```

(Here, `betydb_x.xx` is assumed to be the tag name for the previous release.
The `--stat` flag is used to include a list of each file that was changed in
each update.)

Once the release notes are written, it remains only to fill in the release title
and tag name text boxes and click the _Publish Release_ button.  But these final
steps should be delayed until at least the primary site,
https://www.betydb.org/, has been upgraded, especially if the release involves a
database migration.  We give more details about this below.  **For now, just click
the _Save draft_ button to ensure your release notes don't disappear.**

## Upgrading the canonical BETYdb Rails site[^canonical_site]

> **Note:** Although these instructions are specific to the primary production
> site, https://www.betydb.org, upgrading the beta site before upgrading the
> production site is **_highly recommended_**.  If there are serious problems with
> the pending release version, it is much easier if they are found while upgrading
> a test version of the site so as not to have to try to back out of an upgrade to
> the production site.  Moreover, upgrading the beta site can serve as a trial run
> for upgrading the production site.
>
> Note the following modification of the steps below when upgrading the beta
> site:
>
> * After logging in to `ebi-forecast`, `cd` to `/usr/local/beta` rather than
> `/usr/local/ebi`.
>
> * Making a backup copy of the database is unnecessary.
>
> * **Important** If a migration is done, _do not_ commit the updated
> `production_structure.sql` to the Git repository.  It is the structure of the
> canonical copy of the database—ebi_production—that we want to document.  While
> it is likely that the structure of the beta site's database and the structure
> of the production site's database are identical, it is best not to rely on
> this.

Here are the steps required to upgrade the primary BETYdb Rails site to a
newly-released version.[^newly_released].  These step are roughly the same for
_all_ the sites to be upgraded, but there are some slight differences, which we
shall make note of where appropriate.

1. Log in to the host machine ebi-forecast.igb.illinois.edu:

 ```
 ssh -X ebi-forecast.igb.illinois.edu
 ```

 The `-X` flag is needed if you intend to run the JavaScript-based RSpec tests
 on the host site (highly recommended).

1. Go to the Rails root directory for the EBI site:

 ```{bash}
 cd /usr/local/ebi
 ```

1. Check the git status to be sure the copy is "clean":

 ```
 git status
 ```

  Generally there shouldn't be any modified files and you should be on the
  master branch.[^modified_files]

1. Get the latest code from Github:

 ```
 git pull
 ```

 In rare cases, it may be that you need to release and deploy a version of the
 code other than the head of the master branch.  This should be avoided if at
 all possible, especially if the release contains one or more migrations: it
 complicates incorporating an up-to-date version of the
 `production_structure.sql` into the release.  Note that we tag releases AFTER
 deploying them, so we can't use the release tag as the git reference.

 ```
 git checkout <git reference to version being deployed>
 ```
 
1. Check the gem bundle and install new Gems if needed:

 ```
 bundle check
 ```

 If the the bundle contains uninstalled Gems, run this:

 ```
 bundle install
 ```

1. Check for pending migrations and if needed, migrate the database:

 ```
 bundle exec rake db:migrate:status RAILS_ENV=production 
 ```

 If there are no pending migrations, skip to the testing step.

1. Make a backup copy of the database:

  ```
  pg_dump ebi_production > [some suitable directory]/ebi_production.psql
  ```
  Generally, after the dump file has been created, I rename it to include the timestamp 
   information in the file name: ebi_production_YYYYMMDDhhmm.psql.  This way multiple dump 
   files can be stored in the same directory.)

1. Perform the pending migrations:

  ```
  bundle exec rake db:migrate RAILS_ENV=production
  ```

 **It is especially important to dump the database if any of the pending migrations will delete data!**

1. Generate an up-to-date copy of `db/production_structure.sql`[^schema_file]
and check it in:[^automatic_generation_of_structure_file]

 ```
 bundle exec rake db:structure:dump RAILS_ENV=production
 git add db/production_structure.sql
 git commit
 git push
 ```

1. Run automated tests:

 ```
 bundle exec rake db:test:prepare
 bundle exec rake db:fixtures:load RAILS_ENV=test
 bundle exec rspec -t ~js
 bundle exec rspec -t js
 ```

 The two rspec lines can be combined (just `rspec`), but I generally like to run
 the tests that don't require a JavaScript driver first.  They are much faster.
 _Note that running the tests that do require a JavaScript driver need an X
 server to be running._ In other words, use the `-X` option when ssh-ing into
 the production server.  For more information about automated tests, see
 [Automated Tests](automated_tests.md).

1. If the tests pass, restart the Rails server:

 ```
 touch tmp/restart.txt
 ```

1. Visit the updated site in a browser.

 This is to ensure the site is up and running.  You may also wish to check some
 of the changes the upgrade is meant to implement to make sure they are working
 as expected.

## Upgrading other production sites

The steps for upgrading other production sites is largely the same as for the
primary site https://www.betydb.org.

[To do: add details]

## Finishing the release

Now that the release has been deployed, you can finish the formal release on
GitHub.  Go to the releases list at
https://github.com/PecanProject/bety/releases and click on the draft that you
started earlier.  Give the release a title of the form "BETYdb X.XX" or "BETYdb
X.XX.XX" and a Tag version identifier of the form "betydb\_X.XX" (or
"betydb\_X.XX.XX") and click the _Publish release_ button.  (See [Version
Numbering](#version-numbering) below.)

I usually announce a new release on the Gitter chat page for BETYdb at
https://gitter.im/PecanProject/bety?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge.
Include a link to the release notes in your announcement.


### Version Numbering

We loosely follow [semantic versioning](http://semver.org/).

* Any tag of the form betydb\_x.x or betydb\_x.x.x refers to a version that has been tested and deployed.
* Changes in the first or second digit of the version number mark some
  significant change.  For example, the change to major version number
  2.x marks the change to a new user interface.

---

[^principle_site_list]: As of this writing these include deployments at https://www.betydb.org/, https://ebi-forecast.igb.illinois.edu/bety-mepp, https://terraref.ncsa.illinois.edu/bety/, and https://terraref.ncsa.illinois.edu/bety-test/.  https://www.betydb.org/ is considered the canonical copy.

[^canonical_site]: As of this writing, the primary or canonical site is the one on ebi-forecast.igb.illinois.edu at the URL https://www.betydb.org/.  We call it canonical both because it was first, because it is site 0 in the site numbering scheme, but mainly because it is the site we use when generating updates to the production_structure.sql file, which itself is considered the canonical definition of the BETYdb database schema.

[^newly_released]: By _newly released version_, we actually mean the version that is _about_ to be released, because as noted, we recommend not releasing a new version until at least the primary site has been upgraded.

[^modified_files]: In general, there _will_ be some _untracked_ files.  The untracked files that _should_ be present—database.yml for example—should be mentioned in a .gitignore file so that they don't show up in the `git status` output.  But the .gitignore files are not (at the time of this writing) up to date.  Moreover, there may on occasion be intentionally modified files—for example, if an urgent fix was needed for a particular site before a bona fide release was possible.  In these cases, it is best to save a copy of the modified file, revert the original, do the Git update, and then check if any changes from the saved copy need to be merged in.  (Delete the copy when you are done with it.)  In many cases, the custom changes will match the changes in the release.

[^schema_file]: Note that we no longer use the `schema.rb` file (see https://github.com/PecanProject/bety/issues/44).  The `structure.sql` files allow for complete documentation of the database structure, including features that (by default) are not expressible in the `schema.rb` file.  _`production_structure.sql` is the canonical specification of the complete database schema, the schema which the Rails code is meant to be run against._

[^automatic_generation_of_structure_file]: In point of fact, performing a migration of the production database _should_ automatically generate an up-to-date version of `db/production_structure.sql`, so the first line in this sequence is not strictly necessary.
