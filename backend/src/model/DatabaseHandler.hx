package model;

import js.lib.Promise;
import jsasync.IJSAsync;
import js.Node;

class DatabaseHandler implements IJSAsync {
	static var connection:Mysql;

	static var migrations:Array<String> = [
		'CREATE TABLE fiche_events(id INT AUTO_INCREMENT, fiche_id INT, event_type VARCHAR(50), event_params BLOB, PRIMARY KEY(id))'
	];

	@:jsasync static public function init() {
		connection = Mysql.createConnection({
			host: "mysql",
			database: "pfb",
			user: "pfb",
			password: Node.process.env.get("DB_PASSWORD"),
		}).jsawait();
		checkMigration().jsawait();
		trace('Connected to MySQL');
	}

	@:jsasync static public function exec(query:String, ?parameters:Array<Dynamic>):Promise<Dynamic> {
		var results = connection.execute(query, parameters).jsawait();
		return results[0];
	}

	@:jsasync static public function runMigration(migration:String, id:Int) {
		trace('Running migration $id: $migration');

		exec(migration);
		exec("INSERT INTO migrations VALUES(?)", [id]);
	}

	@:jsasync static public function runMigrations(start:Int) {
		trace('Running migrations starting from ${start} (${migrations.length - start} to execute)');
		var toRun = migrations.slice(start);
		for (i in 0...toRun.length) {
			runMigration(toRun[i], i).jsawait();
		}
	}

	@:jsasync static public function checkMigration() {
		try {
			var results = exec("SELECT * FROM migrations ORDER BY id DESC").jsawait();
			if (results.length == 0) {
				runMigrations(0);
			}
		} catch (e:Dynamic) {
			trace("Error");
			exec("CREATE TABLE migrations(id INT, PRIMARY KEY(id))").jsawait();
			checkMigration();
		}
	}
}
