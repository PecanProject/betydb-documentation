# Distributed BETYdb

## Syncing Databases

### Exporting Data

The [dump.bety.sh](https://github.com/PecanProject/pecan/blob/master/scripts/dump.bety.sh) script does the following:

* dumps all data except:
  * traits or yields where access\_level &lt; 3 or checked = -1
  * runs and workflows contents \(After implementing benchmarking, we will need to dump reference runs.\) 
* anonymizes users
  * sets user1 to carya/illinois with access\_level =1, page\_access\_level = 1, 
  * other users get access\_level = 3, page\_access\_level = 4. 
  * Users id's are preserved in order to allow admin to identify issues that are uncovered in anonymized version of db.

Output:

* schema as .sql file, named after the most recent value in migrations table, to ensure that the data can be loaded \(schema versions must match in order to sync\)
* each table exported as a csv file, and tar-zipped. \(psql function '\copy'\)

### Importing Data

You can sync a local instance of the BETYdb database with other instances. The [load.bety.sh](https://github.com/PecanProject/pecan/blob/master/scripts/load.bety.sh) script will import data from other servers.

```bash
MYSITE=X REMOTESITE=Y load.bety.sh
```

This will set the number range based on the `MYSITE` variable

> \(1,000,000,000  _MYSITE\) to \(\(1,000,000,000_  \(MYSITE + 1\)\) - 1\)

### Primary Key Allocations

Assigning a unique set of primary key values to each instance of BETYdb allows each distributed system to create new records that can later be shared, and to import new records from other databases. Ranges with no server listed are reserved but may not be deployed or are used offline.

Any changes to existing records should be done on the server that owns that record.

| Institution | server | url | id | allocated primary key values |
| :--- | :--- | :--- | :--- | :--- |
| Energy Biosciences Institute / University of Illinois | ebi-forecast.igb.illinois.edu | [https://betydb.org](https://betydb.org) | 0 | 1-1,000,000,000 |
| Boston University | psql-pecan.bu.edu | [https://psql-pecan.bu.edu/bety](https://psql-pecan.bu.edu/bety) | 1 | 1,000,000,001-2,000,000,000 |
| Brookhaven National Lab | modex.test.bnl.gov | [http://modex.test.bnl.gov/bety](http://modex.test.bnl.gov/bety) | 2 | 2,000,000,001-3,000,000,000 |
| Purdue | bety.bio.purdue.edu | [http://bety.bio.purdue.edu/](http://bety.bio.purdue.edu/) | 3 | 3,000,000,001-4,000,000,000 |
| Virginia Tech |  | 4 | 4,000,000,001-5,000,000,000 |  |
| University of Wisconsin | tree.aos.wisc.edu | [http://tree.aos.wisc.edu:6480/bety](http://tree.aos.wisc.edu:6480/bety) | 5 | 5,000,000,001-6,000,000,000 |
| TERRA Ref | 141.142.209.94 | [http://terraref.ncsa.illinois.edu/bety](http://terraref.ncsa.illinois.edu/bety) | 6 | 6,000,000,001-7,000,000,000 |
| TERRA test | 141.142.209.95 | [http://terraref.ncsa.illinois.edu/bety-test](http://terraref.ncsa.illinois.edu/bety-test) | 7 | 7,000,000,001-8,000,000,000 |
| TERRA MEPP UIUC | terra-mepp.ncsa.illinois.edu | terra-mepp.ncsa.illinois.edu/bety | 8 | 8,000,000,001-9,000,000,000 |
| TERRA TAMU |  |  | 9 | 9,000,000,001-10,000,000,000 |
| Ghent |  |  | 10 | 10,000,000,001 - 11,000,000,000 |
| TERRA Purdue |  |  | 11 | 11,000,000,001 - 12,000,000,000 |
| Development / Virtual Machine | localhost | [https://localhost:6480/bety](https://localhost:6480/bety) | 99 | 99,000,000,000-a zillion |

## Feedback Tab

New users and 'feedback tab' submissions are sent to all users with Admin privileges \([gh-56](https://github.com/PecanProject/bety/issues/)\).

## Customization

As of [BETYdb v 4.1.3](https://github.com/PecanProject/bety/releases/tag/betydb_4.13) it is possible to customize the user interface with project-specific design elements including. To do this, it is necessary to create a new file called `config/application.yml`. Details are in [config/application.template.yml](https://github.com/PecanProject/bety/blob/master/config/application.yml.template). See also [https://github.com/PecanProject/bety/issues/368](https://github.com/PecanProject/bety/issues/368)\).

Customizable elements include:

* Database name and descriptions
* Images found on the home page
* Sponsor logos and links in footer
* Database citation and data use policy
* Contact information

## Issues

* to get latest data, have to query each server \(or can get full dump from one server, but this is as out of date as the last sync\)
* to edit data from records owned by another server, must edit on that server \(or risk loosing this on next update\)

