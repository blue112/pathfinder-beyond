package model;

import js.lib.Promise;
import jsasync.IJSAsync;

class DiceRoll implements IJSAsync {
	var fiche_id:String;
	var faces:Int;

	public var result:Int;
	public var mod:Int;

	var field_name:String;

	public var ts:Float;

	public function new(fiche_id:String, field_name:String, faces:Int, mod:Int) {
		this.fiche_id = fiche_id;
		this.faces = faces;
		this.field_name = field_name;
		this.mod = mod;
	}

	public function roll() {
		this.result = Std.random(faces) + 1;
		this.ts = Date.now().getTime();
	}

	public function toPublic():Dynamic {
		return {
			field_name: field_name,
			faces: faces,
			result: result,
			ts: ts,
			mod: mod,
		};
	}

	@:jsasync static public function fetchLatest(fiche_id:String):Promise<DiceRoll> {
		var results = DatabaseHandler.exec("SELECT * FROM dice_rolls WHERE fiche_id = ? ORDER BY roll_id DESC LIMIT 1", [fiche_id]).jsawait();
		if (results.length == 0)
			return null;

		var r = new DiceRoll(results[0].fiche_id, results[0].field_name, results[0].faces_count, results[0].modifier);
		r.result = results[0].result;
		r.ts = results[0].ts_ms;
		return r;
	}

	@:jsasync static public function fetch(fiche_id:String):Promise<Array<DiceRoll>> {
		var results = DatabaseHandler.exec("SELECT * FROM dice_rolls WHERE fiche_id = ?", [fiche_id]).jsawait();

		var out = [];
		for (i in results) {
			var r = new DiceRoll(i.fiche_id, i.field_name, i.faces_count, i.modifier);
			r.result = i.result;
			r.ts = i.ts_ms;
			out.push(r);
		}

		return out;
	}

	public function insert() {
		return DatabaseHandler.execInsert("INSERT INTO dice_rolls(fiche_id, field_name, ts_ms, faces_count, result, modifier) VALUES(?, ?, ?, ?, ?, ?)",
			[fiche_id, field_name, ts, faces, result, mod]);
	}
}
