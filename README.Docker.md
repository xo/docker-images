# `docker.io/usql/usql`

Official container image for [`usql`][usql], the universal command-line
interface for SQL databases.

[usql]: https://github.com/xo/usql

# Using

Retrieve the latest container image:

```sh
$ podman pull docker.io/usql/usql:latest
```

Run with a local volume mounted and with a SQLite3 database:

```sh
# run interactive shell and mount the $PWD/data directory for use with sqlite3
$ podman run --rm -it --volume $(pwd)/data:/data docker.io/usql/usql:latest sqlite3://data/test.db
Trying to pull docker.io/usql/usql:latest...
Getting image source signatures
Copying blob af48168d69d8 done   |
Copying blob efc2b5ad9eec skipped: already exists
Copying config 917ceb411d done   |
Writing manifest to image destination
Connected with driver sqlite3 (SQLite3 3.45.1)
Type "help" for help.

sq:data/test.db=> CREATE TABLE test (id integer, name text);
CREATE TABLE
sq:data/test.db=> INSERT INTO test VALUES (1, 'a name');
INSERT 1
sq:data/test.db=> select * from test;
 id |  name
----+--------
  1 | a name
(1 row)

sq:data/test.db=> \q
```

Run PostgreSQL locally and connect:

```sh
# run postgresql
$ podman run --detach --rm --name=postgres --publish=5432:5432 --env=POSTGRES_PASSWORD=P4ssw0rd docker.io/usql/postgres
9544c561095b150fe399a0391eead08f060ba17991cbab3bd32ff6347caa0e00

# connect with usql to the above postgres instance
$ podman run --rm --network host -it docker.io/usql/usql:latest postgres://postgres:P4ssw0rd@localhost
Connected with driver postgres (PostgreSQL 16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.

pg:postgres@localhost=> create table test (id integer, name text);
CREATE TABLE
pg:postgres@localhost=> insert into test values (1, 'a name');
INSERT 1
pg:postgres@localhost=> select * from test;
 id |  name
----+--------
  1 | a name
(1 row)

pg:postgres@localhost=>
```
