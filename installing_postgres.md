# Installing Postgres

# Instructions for Installing and Configuring PostgreSQL

These instructions are for installation on Ubuntu.  For other Linux-like systems, the steps are similar.  Mainly the file locations and the installation command (`apt-get` here) will be different.

1. Run `sudo apt-get install postgresql`.
2. Create user bety:  Run `sudo -u postgres createuser -P bety`.  Type `bety` when prompted for a password.  This is the default user the the BetyDB Rails application connects to the database as.
3. [Optional:] If you wish to administer the database without switching to user postgres (so that you don't have to prefix all your commands with `sudo -u postgres`) add yourself as a superuser: `sudo -u postgres createuser -s <your_ubuntu_login_name>`.  This will allow you to run all PostgreSQL commands as yourself without a password.
4. Edit the pg_hba.conf file to allow bety to log in using a password.  On Ubuntu, this file is most likely located at `/etc/postgresql/9.3/main/pg_hba.conf` (assuming you are using version 9.3).  In detail:

    ```
sudo su # this allows accessing and editing the conf file
cd /etc/postgresql/9.3/main
cp pg_hba.conf pg_hba.conf-original # optional convenience if you need to start over
emacs pg_hba.conf # use your favorite editor
```
In this file, you will see a line like this
`local       all       all      peer`
Assuming this is a fresh install of PostgreSQL, you can give password access to user bety by adding the line
`local       bety      bety     md5`
immediately _before_ this.  Then save the file.
5. In order for the configuration to take effect, you must reload the config files:
`sudo /etc/init.d/postgresql reload`
6. You can test that user bety exists and can log in by running the following:
```
sudo -u postgres createdb -O bety bety
psql -U bety
```
 


### Manually dumping and installing BETYdb

In this example, we are dumping BETY from "betyhost" to "myserver"
```sh
ssh betyhost
pg_dump -U postgres bety > bety_YYYYMMDD.sql
rsync bety_YYYYMMDD.sql myserver:  
```

#### Create Copy of BETY

```sh
ssh myserver
createdb -U postgres bety_copy
```

#### Enable PostGIS

```sh
psql -U postgres
postgres=# \c bety_copy
postgres=# CREATE EXTENSION POSTGIS;
```

Also see [[Creating a New PostGIS Enabled Database Template | Automated-Tests#creating-a-new-postgis-enabled-database-template]]

#### Import database

```shell
psql -U postgres bety_copy < bety_YYYYMMDD.sql
```
