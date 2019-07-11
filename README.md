## sqflite_migrations
Migrations manager for sqflite.
-   Create migrations
-   Run migrations
-   Rollback migrations

## Getting Started
In your flutter project add the dependency:
```
dependencies:
  ...
  sqflite_migrations: ^0.1.0 
```

## Usage example
Import `sqflite_migrations.dart`
```
import 'package:sqflite_migrations/sqflite_migrations.dart';
```

## Creating a migration

Create a new instance of the `Migration` class you imported fromt he package. 

Its attributes are:
- The migration's `name`, which should be unique.
- An `up` method that must return the query you want to run when the migration is ran.
- A `down` method that returns the query you want to run when the migration is rolledback.

Example:
```
Migration createUsersTable = new Migration(
  'create-users-table',
  () => '''
    CREATE TABLE users( 
      id INT PRIMARY KEY,
      name TEXT NOT NULL
    );
  ''',
  () => 'DROP TABLE users;',
);
```

## Running migrations

You will run every migration in your list that was not ran already. 

Assuming you want to run migrations only when your database is updated, you should run the `runMigrations` method on the `onUpgrade` method of `sqflite`.

It accepts as parameters:
- Your current db of type `Database`.
- An `int` with the new version.
- Your migrations list of type `List<Migration>`.

Example:
```
  onUpgrade(Database db, int previousVersion, int newVersion) {
    runMigrations(db, newVersion, migrations);
  }
```

And then you pass this method when you create the database:
```
 Database db = await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: onUpgrade);
```

## Undoing migrations

This functionality will undo every migrations that was implemented in a version above the current one.

Undoing migrations works the other way around of running migrations: you call the `undoMigrations` method in the method passed to the `onDowngrade` attribute.

It's parameters are:
- The current db of type `Database`.
- An `int` with the new version.
- Your migrations list of type `List<Migration>`.

Example:
```
  onDowngrade(Database db, int previousVersion, int newVersion) {
    undoMigrations(db, newVersion, migrations);
  }
```
