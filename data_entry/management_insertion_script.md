# Management Insertion Script

The script `insert_managements.rb` is in the directory `RAILS_ROOT/script`.  The complete usage instructions (also obtainable by running `./insert_managements --man`) follow.

=====================
insert_managements.rb
=====================

Usage:
       insert_managements [options] <CSV input file>
where [options] are:
  -u, --login=<s>          The Rails login for the user running the script
                           (required)
  -o, --output=<s>         Output file (default: new_managements.sql)
  -e, --environment=<s>    Rails environment to run in (default: development)
  -m, --man                Show complete usage instructions
  -h, --help               Show this message

DESCRIPTION

This script takes a CSV file describing managements to be added to the database
as input and outputs a file containing SQL statements to do the required
insertions.

CSV FILE FORMAT

The CSV file must contain the following column headings:

	citation_author
	citation_title
	citation_year
	treatment_name
	mgmttype

Each row must have non-empty values in each of these columns.  Moreover, the
citation columns must match exactly one row in the citations row of the
database
and the treatment name must match exactly one of the treatment rows associated
with the matched citation.

Additionally, the CSV file MAY contain the following column headings:

	date
	dateloc
	level
	units
	notes

Each optional column heading corresponds to a column in the database
managements
table.  Values in these columns may be left blank in any given row.  For these
columns, if a column value is left blank, or if the column is not included in
the CSV file, the resulting column value in the database will be the
SQL-defined
default value for that column.

DATABASE SPECIFICATION

The database used by the script is determined by the environment specified by
the '--environment' option (or 'development' if not specified) and the contents
of the configuration file 'config/database.yml'.  (Run 'rake dbconf' to view
the
contents of this file on the command line.)

USING THE SCRIPT TO UPDATE THE PRODUCTION DATABASE

There are essentially three options for using this script to update the
production database.

Option A: Run the script on the production server in the Rails root directory
of
the production deployment of the BETYdb Rails app.

In detail:

1. Upload the input CSV file to the production machine.

2. Log in to the production machine and cd to the root directory of production
   deployment of the BETYdb Rails app.

3. Run the script using the '--environment=production' option and with
'--login'
   set to your own BETYdb Rails login for the production deployment.  The
   command-line argument specifying the input CSV file path should match the
   location you uploaded it to.

4. After examining the resulting output file, apply it to the database with the
   command

       psql <production database name>  <  <output file name>

(If your machine login doesn't match a PostgreSQL user name that has insert
permissions on the production database, you will have to use the '-U' option to
specify a user who does have such permission.)


Option B: Run the script on your local machine using an up-to-date copy of the
BETYdb database.

To do this:

1. Switch to the root of the copy of the BETYdb Rails app you want to use.

2. For the copy of the BETYdb database connected to this copy of the Rails app,
   ensure that at least the citations and the treatments tables are up-to-date
   with the production copy of the BETYdb database.  (If you have different
   databases specified for your development and your production environments,
be
   sure that the environment you specify with the '--environment' option points
   to the right database.)

3. Run this script.

4. Upload the output file to the production server and apply it to the
   production database using the psql command given above.


Option C: Run the script on your local machine using a Rails environment
connected to the production database.

1. Go to the copy of the BETYdb Rail app on your local machine that you wish to
   use.

2. Edit the file config/database.yml, adding the following section:

ebi:
  adapter: postgis
  encoding: utf8
  reconnect: false
  database: <production database name>
  pool: 5
  username: <user name for connecting to the production database>
  password: <password for the user specified above>
  port: 8000
  host: localhost

Most of these values can be copied from the production copy config/database.yml
if you have access to it.  The port and host entries are 'new'.

3. Set up an ssh tunnel to the production server using the command

ssh -L 8000:<production server address>:5432 <production server address>

This will log you into the production server, but at the same time it will
connect port 8000 on your local machine with port 5432 (the PostgreSQL server
port) on the production machine.  (The choice of 8000 for port number is
somewhat arbitrary, but whatever value you use should match the value you
specified for the port number in the database.yml file.)

4. Run this script with the environment option '--environment=ebi'.  (Again,
the
name 'ebi' for the environment is somewhat arbitrary, but the option value
should match the name in your database.yml file.)

5. Continue as in step 4 under option B.
 

