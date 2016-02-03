# Distributed instances of BETYdb

## Syncing Databases

The database synchronization consists of 2 parts:
- Getting the data from the remote servers to your server
- Sharing your data with everybody else

## How does it work?

Each server that runs the BETY database will have a unique machine_id and a sequence of ID's associated. Whenever the user creates a new row in BETY it will receive an ID in the sequence. This allows us to uniquely identify where a row came from. This is information is crucial for the code that works with the synchronization since we can now copy those rows that have an ID in the sequence specified. If you have not asked for a unique ID your ID will be 99.

The synchronization code itself is split into two parts, loading data with the `load.bety.sh` script and exporting data using `dump.bety.sh`. If you do not plan to share data, you only need to use `load.bety.sh` to update your database.

### Exporting Data

The [dump.bety.sh](https://github.com/PecanProject/pecan/blob/master/scripts/dump.bety.sh) script does the following:
* dumps all data except:
 * traits or yields where access_level < 3 or checked = -1
 * runs and workflows contents (After implementing benchmarking, we will need to dump reference runs.) 
* anonymizes users
 * sets user1 to carya/illinois with access_level =1, page_access_level = 1, 
 * other users get access_level = 3, page_access_level = 4. 
 * Users id's are preserved in order to allow admin to identify issues that are uncovered in anonymized version of db.

Output: 
* schema as .sql file, named after the most recent value in migrations table, to ensure that the data can be loaded (schema versions must match in order to sync)
* each table exported as a csv file, and tar-zipped. (psql function '\copy')

### Importing Data

You can sync a local instance of the BETYdb database with other instances. The [load.bety.sh](https://github.com/PecanProject/pecan/blob/master/scripts/load.bety.sh) script will import data from other servers.

```sh
MYSITE=X REMOTESITE=Y load.bety.sh
```

This will set the number range based on the `MYSITE` variable

> (1,000,000,000 * MYSITE) to ((1,000,000,000 * (MYSITE + 1)) - 1)


### Primary Key Allocations

Assigning a unique set of primary key values to each instance of BETYdb allows each distributed system to create new records that can later be shared, and to import new records from other databases.

Any changes to existing records should be done on the server that owns that record.

|Institution | server | url | id | allocated primary key values| 
|---|---|---|---|---|
| Energy Biosciences Institute / University of Illinois|ebi-forecast.igb.illinois.edu| https://betydb.org| 0 | 1-1,000,000,000|
| Boston University| psql-pecan.bu.edu |https://psql-pecan.bu.edu/bety | 1 | 1,000,000,001-2,000,000,000|
| Brookhaven National Lab|modex.test.bnl.gov|http://modex.test.bnl.gov/bety|  2 | 2,000,000,001-3,000,000,000|
| Purdue| bety.bio.purdue.edu | http://bety.bio.purdue.edu/ | 3 | 3,000,000,001-4,000,000,000|
| Virginia Tech| | | 4 | 4,000,000,001-5,000,000,000|
| University of Wisconsin | tree.aos.wisc.edu | http://tree.aos.wisc.edu:6480/bety | 5 | 5,000,000,001-6,000,000,000|
| TERRA Ref Danforth |  | terraref.ncsa.illinois.edu/bety | 6 | 6,000,000,001-7,000,000,000|
| TERRA test |  | terraref.ncsa.illinois.edu/bety-test  | 7 | 7,000,000,001-8,000,000,000|
| TERRA MEPP UIUC | ebi-forecast.igb.illinois.edu | ebi-forecast.igb.illinois.edu/mepp-bety | 8 | 8,000,000,001-9,000,000,000|
| TERRA TAMU |  | *.tamu.edu/tamu-bety | 9 | 9,000,000,001-10,000,000,000|
| Development / Virtual Machine |localhost| https://localhost:6480/bety| 99 | 99,000,000,000-a zillion|

## Feedback Tab

New users and 'feedback tab' submissions are sent to all users with Admin privileges ([gh-56](https://github.com/PecanProject/bety/issues/)).
 
## Planned features

* [GitHub issue 368](https://github.com/PecanProject/bety/issues/368) will implement the capacity to specify institution or project-specific design elements (e.g. colors, header, title, text, attribution on the front page). 
* to edit data from records owned by another server, must edit on that server (or risk loosing this on next update)


## Fetch latest data

When logged into the machine you can fetch the latest data using the load.bety.sh script. The script will check what site you want to get the data for and will remove all data in the database associated with that id. It will then reinsert all the data from the remote database.

The script is configured using environment variables.  The following variables are recognized:
- DATABASE: the database where the script should write the results.  The default is `bety`.
- OWNER: the owner of the database (if it is to be created).  The default is `bety`.
- PG_OPT: additional options to be added to psql (default is nothing).
- MYSITE: the (numerical) ID of your site.  If you have not requested an ID, use 99; this is used for all sites that do not want to share their data (i.e. VM). 99 is in fact the default.
- REMOTESITE: the ID of the site you want to fetch the data from.  The default is 0 (EBI).
- CREATE: If 'YES', this indicates that the existing database (`bety`, or the one specified by DATABASE) should be removed. Set to YES (in caps) to remove the database.  **THIS WILL REMOVE ALL DATA** in DATABASE.  The default is NO.
- KEEPTMP: indicates whether the downloaded file should be preserved.  Set to YES (in caps) to keep downloaded files; the default is NO.
- USERS: determines if default users should be created.  Set to YES (in caps) to create default users with default passwords.  The default is NO.

All of these variables can be specified as command line arguments, to see the options use -h.

```
load.bety.sh -h
./scripts/load.bety.sh [-c YES|NO] [-d database] [-h] [-m my siteid] [-o owner] [-p psql options] [-r remote siteid] [-t YES|NO] [-u YES|NO]
 -c create database, THIS WILL ERASE THE CURRENT DATABASE, default is NO
 -d database, default is bety
 -h this help page
 -m site id, default is 99 (VM)
 -o owner of the database, default is bety
 -p additional psql command line options, default is empty
 -r remote site id, default is 0 (EBI)
 -t keep temp folder, default is NO
 -u create carya users, this will create some default users

dump.bety.sh -h
./scripts/dump.bety.sh [-a YES|NO] [-d database] [-h] [-l 0,1,2,3,4] [-m my siteid] [-o folder] [-p psql options] [-u YES|NO]
 -a use anonymous user, default is YES
 -d database, default is bety
 -h this help page
 -l level of data that can be dumped, default is 3
 -m site id, default is 99 (VM)
 -o output folder where dumped data is written, default is dump
 -p additional psql command line options, default is -U bety
 -u should unchecked data be dumped, default is NO
```

## Sharing data

Sharing your data requires a few steps. First, before entering any data, you will need to request an ID from the PEcAn developers. Simply open an issue at github and we will generate an ID for you.  If possible, add the URL of your data host.

You will now need to synchronize the database again and use your ID.  For example if you are given ID=42 you can use the following command: `MYID=42 REMOTEID=0 ./scripts/load.bety.sh`. This will load the EBI database and set the ID's such that any data you insert will have the right ID.

To share your data you can now run the dump.bey.sh. The script is configured using environment variables, the following variables are recognized:
- DATABASE: the database where the script should write the results.  The default is `bety`.
- PG_OPT: additional options to be added to psql (default is nothing).
- MYSITE: the ID of your site.  If you have not requested an ID, use 99, which is used for all sites that do not want to share their data (i.e. VM).  99 is the default.
- LEVEL: the minimum access-protection level of the data to be dumped (0=private, 1=restricted, 2=internal collaborators, 3=external collaborators, 4=public).  The default level for exported data is level 3.
   - note that currently only the traits and yields tables have restrictions on sharing. If you share data, records from other (meta-data) tables will be shared. If you wish to extend the access_level to other tables please [submit a feature request](https://github.com/pecanproject/bety/issues/new).
- UNCHECKED: specifies whether unchecked traits and yields be dumped.  Set to YES (all caps) to dump unchecked data.  The default is NO.
- ANONYMOUS: specifies whether all users be anonymized.  Set to YES (all caps) to keep the original users (**INCLUDING PASSWORD**) in the dump file.  The default is NO.
- OUTPUT: the location of where on disk to write the result file.  The default is `${PWD}/dump`.

## Tasks

Following is a list of tasks we plan on working on to improve these scripts:
- [pecanproject/pecan#149](https://github.com/PecanProject/pecan/issues/149) : add server to EBI, currently we will assign ID by hand and the range is based on this ID and is computed in the scripts. This information should be stored in the database, as well as the URL where to get the data from. This will allow a user to update the URL.
- [pecanproject/bety#368](https://github.com/PecanProject/bety/issues/368) allow site-specific customization of information and UI elements including title, contacts, logo, color scheme.