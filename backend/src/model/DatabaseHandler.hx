package model;

import js.lib.Promise;
import jsasync.IJSAsync;
import js.Node;

class DatabaseHandler implements IJSAsync {
	static var connection:Mysql;

	// Append only, no modification
	static var migrations:Array<String> = [
		'CREATE TABLE fiche_events(id INT AUTO_INCREMENT, fiche_id INT, event_type VARCHAR(50), event_params BLOB, PRIMARY KEY(id))',
		'ALTER TABLE fiche_events MODIFY fiche_id VARCHAR(36)',
		'CREATE TABLE fiche(fiche_id VARCHAR(36), characterName VARCHAR(50), PRIMARY KEY(fiche_id))',
		'CREATE TABLE dice_rolls(roll_id INT AUTO_INCREMENT, fiche_id VARCHAR(36), field_name VARCHAR(50), faces_count INT, result INT, ts_ms BIGINT, PRIMARY KEY(roll_id))',
	];

	@:jsasync static public function init() {
		connection = Mysql.createPool({
			connectionLimit: 2,
			host: "mysql",
			database: "pfb",
			user: "pfb",
			password: Node.process.env.get("DB_PASSWORD"),
		});
		checkMigration().jsawait();
		trace('Connected to MySQL');
	}

	@:jsasync static public function execInsert(query:String, ?parameters:Array<Dynamic>):Promise<Dynamic> {
		var results = connection.execute(query, parameters).jsawait();
		return results[0].insertId;
	}

	@:jsasync static public function exec(query:String, ?parameters:Array<Dynamic>):Promise<Array<Dynamic>> {
		var results = connection.execute(query, parameters).jsawait();
		return results[0];
	}

	@:jsasync static function runMigration(migration:String, id:Int) {
		trace('Running migration $id: $migration');

		exec(migration);
		exec("INSERT INTO migrations VALUES(?)", [id]);
	}

	@:jsasync static function runMigrations(start:Int) {
		trace('Running migrations starting from ${start} (${migrations.length - start} to execute)');
		var toRun = migrations.slice(start);
		for (i in 0...toRun.length) {
			runMigration(toRun[i], start + i).jsawait();
		}
	}

	@:jsasync static function checkMigration() {
		try {
			var results = exec("SELECT id FROM migrations ORDER BY id DESC").jsawait();
			if (results.length == 0) {
				runMigrations(0);
				return;
			}
			var lastRun = results[0].id + 1;
			if (lastRun < migrations.length) {
				runMigrations(lastRun);
			}
		} catch (e:Dynamic) {
			trace("Error");
			exec("CREATE TABLE migrations(id INT, PRIMARY KEY(id))").jsawait();
			checkMigration();
		}
	}
}
