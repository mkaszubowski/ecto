# Changelog

## v1.1.9

### Bug fixes

  * Don't automatically reconnect postgrex connection. This fixes a bug where we wouldn't trigger `after_connect` for some connections
  * Allow read after writes on non primary key fields for MySQL (although still autoincrementing on the database)

## v1.1.8

### Enhancements

* Support Elixir v1.3 calendar types
* Remove warnings on Elixir v1.3

## v1.1.7

### Bug fixes

* Fix bug where `^left in ^right` in queries would emit parameters in the wrong order

## v1.1.6

### Enhancements

* Also support Poison ~> 2.0

### Bug fixes

* Ensure optimistic_lock reads data from changes
* Ensure BIT(1) type can be loaded as type :boolean for MYSQL

## v1.1.5

### Bug fixes

* Fix Mariaex requirement for 0.5.x and 0.6.x

## v1.1.4

### Enhancements

* Support Mariaex 0.5.x and 0.6.x
* Wrap each pool in a supervisor

## v1.1.3

### Enhancements

* Require Postgrex 0.11.0

## v1.1.2

### Bug fixes

* Be restrict on mariaex and postgrex dependencies

## v1.1.1

### Bug fixes

* Remove documentation for unfinished `on_replace` option in `cast_assoc`, `cast_embed`, `put_assoc` and `put_embed`. The option could be given and applied to the changeset but it would never reach the repository, giving the impression it works as expected but ultimately failing in the repository operation

### Deprecations

* Add missing deprecation on `EctoOne.Changeset.cast/3`

## v1.1.0

EctoOne v1.1.0 brings many improvements and bug fixes.

In particular v1.1.0 deprecates functionality that has been shown by developers to be confusing, unclear or error prone. They include:

* `EctoOne.Model`'s callbacks have been deprecated in favor of composing with changesets and of schema serializers
* `EctoOne.Model`'s `optimistic_lock/1` has been deprecated in favor of `EctoOne.Changeset.optimistic_lock/3`, which gives more fine grained control over the lock by relying on changesets
* Giving a model to `EctoOne.Repo.update/2` has been deprecated as it is ineffective and error prone since changes cannot be tracked
* `EctoOne.DateTime.local/0` has been deprecated
* The association and embedded functionality from `EctoOne.Changeset.cast/4` has been moved to `EctoOne.Changeset.cast_assoc/3` and `EctoOne.Changeset.cast_embed/3`
* The association and embedded functionality from `EctoOne.Changeset.put_change/3` has been moved to `EctoOne.Changeset.put_assoc/3` and `EctoOne.Changeset.put_embed/3`

Furthermore, the following functionality has been soft-deprecated (they won't emit warnings for now, only on EctoOne v2.0):

* `EctoOne.Model` has been soft deprecated. `use EctoOne.Schema` instead of `use EctoOne.Model` and invoke the functions in `EctoOne` instead of the ones in `EctoOne.Model`

Keep on reading for more general information about this release.

### Enhancements

* Optimize EctoOne.UUID encoding/decoding
* Introduce pool timeout and set default value to 15000ms
* Support lists in `EctoOne.Changeset.validate_length/3`
* Add `EctoOne.DataType` protocol that allows an Elixir data type to be cast to any EctoOne type
* Add `EctoOne.Changeset.prepare_changes/2` allowing the changeset to be prepared before sent to the storage
* Add `EctoOne.Changeset.traverse_errors/2` for traversing all errors in a changeset, including the ones from embeds and associations
* Add `EctoOne.Repo.insert_or_update/2`
* Add support for exclusion constraints
* Add support for precision on `EctoOne.Time.utc/1` and `EctoOne.DateTime.utc/1`
* Support `count(expr, :distinct)` in query expressions
* Support prefixes in `table` and `index` in migrations
* Allow multiple repos to be given to Mix tasks
* Allow optional binding on `EctoOne.Query` operations
* Allow keyword lists on `where`, for example: `from Post, where: [published: true]`

### Bug fixes

* Ensure we update embedded models state after insert/update/delete
* Ensure psql does not hang if not password is given
* Allow fragment joins with custom `on` statement

## v1.0.0

* See the CHANGELOG.md in the v1.0 branch
