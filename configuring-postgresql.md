# Configuring PostgreSQL

These instructions assume you have a fresh installation of PostgreSQL 9.4.
Later versions can be used, but these instructions will have to be modified
accordingly.

## Step 1: Initialize the database cluster and start the server

This may be done using the following commands:
```bash
sudo -s # become "root"

/usr/pgsql-9.4/bin/postgresql94-setup initdb
systemctl enable postgresql-9.4
systemctl start postgresql-9.4

exit # leave the root account
```

## Step 2: Enable password authentication for all users other than postgres


As root or as user `postgres`, open `pg_hba.conf` (probably in
`/var/lib/pgsql/9.4/data`) for editing.  Find the line for local domain socket
connections:
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     peer
```

Change "peer" to "md5".  Also, add a line for user postgres directly above this
one to allow peer authentication.  Your file should now look like this:
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     md5
```

Also, find the two lines for IPv4 and IPv6 local connections:

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# IPv4 local connections:
host    all             all             127.0.0.1/32            ident
# IPv6 local connections:
host    all             all             ::1/128                 ident
```

In both lines, change "ident" to "md5".  (This seems to be needed to run the
schema-spy documentation generator tool.)  Save and close the file.

Now restart the PostgreSQL server so that the changes take effect:
```
sudo systemctl restart postgresql-9.4
```

## Step 3: Create a new role and new database for BETYdb

By way of example, we'll call the new role for BETYdb `dbuser` and give it
password `dbpw`, and the BETYdb database will be called `betydb`.  (See the note
on placeholder names in the beginning section of [Deploying a Production Copy of
the BETYdb Web Application].

Since user `postgres` (the only database role so far) uses peer authenication,
we have to become that user to log in to the database:

```bash
sudo su postgres
```

Now start a psql session:
```bash
psql
```

In the psql session, run the following commands to create the new user and new
database and then exit the session:

```
CREATE ROLE dbuser WITH LOGIN CREATEDB NOSUPERUSER NOCREATEROLE PASSWORD 'dbpw';
CREATE DATABASE betydb WITH OWNER dbuser;
\q
```


