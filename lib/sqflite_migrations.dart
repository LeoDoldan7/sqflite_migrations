import 'package:sqflite/sqflite.dart';

import 'package:sqflite_migrations/src/models/models.dart';

final String migrationsTable = "MigrationsMeta";

bool migrationWasApplied(Migration migration, List<dynamic> ranMigrationsList) {
  return ranMigrationsList.firstWhere((ranM) => ranM['name'] == migration.name,
          orElse: () => null) !=
      null;
}

void runMigrations(
    Database db, int newVersion, List<Migration> migrations) async {
  List<RanMigration> ranMigrations =
      await db.query(migrationsTable) as List<RanMigration>;
  var ranMigrationsList = ranMigrations.toList();
  for (int i = 0; i < migrations.length; i++) {
    Migration migration = migrations[i];
    if (!migrationWasApplied(migration, ranMigrationsList)) {
      await db.transaction((txn) async {
        await txn.execute(
            "INSERT INTO $migrationsTable (name, version) VALUES ('${migration.name}', $newVersion);");
        await txn.execute(migration.up());
      });
    }
  }
}

Migration getMigrationByName(String name, List<dynamic> migrationsList) {
  return migrationsList.firstWhere((migration) => name == migration.name,
      orElse: () => null);
}

void undoMigrations(
    Database db, int newVersion, List<Migration> migrations) async {
  List<RanMigration> ranMigrations =
      await db.query('MigrationsMeta') as List<RanMigration>;
  var ranMigrationsList = ranMigrations.toList();
  for (int i = 0; i < ranMigrationsList.length; i++) {
    RanMigration ranMigration = ranMigrationsList[i];
    if (ranMigration.version > newVersion) {
      Migration migration = getMigrationByName(ranMigration.name, migrations);
      await db.transaction((txn) async {
        await txn.execute(
            "DELETE FROM $migrationsTable WHERE name = ${ranMigration.name};");
        await txn.execute(migration.down());
      });
    }
  }
}

Future<void> createMigrationsTable(Database db) async {
  return db.execute('''
          CREATE TABLE IF NOT EXISTS $migrationsTable (
            name TEXT PRIMARY KEY,
            version INTEGER NOT NULL
          )
          ''');
}
