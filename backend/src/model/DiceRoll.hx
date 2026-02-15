package model;

import js.lib.Promise;
import jsasync.IJSAsync;

class DiceRoll implements IJSAsync {
	var fiche_id:String;
	var faces:Int;

	public var result:Int;

	var field_name:String;

	public var ts:Float;

	public function new(fiche_id:String, field_name:String, faces:Int) {
		this.fiche_id = fiche_id;
		this.faces = faces;
		this.field_name = field_name;
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
		};
	}

	@:jsasync static public function fetch(fiche_id:String):Promise<Array<DiceRoll>> {
		var results = DatabaseHandler.exec("SELECT * FROM dice_rolls WHERE fiche_id = ?", [fiche_id]).jsawait();

		var out = [];
		for (i in results) {
			var r = new DiceRoll(i.fiche, i.field_name, i.faces_count);
			r.result = i.result;
			r.ts = i.ts_ms;
			out.push(r);
		}

		return out;
	}

	public function insert() {
		return DatabaseHandler.execInsert("INSERT INTO dice_rolls(fiche_id, field_name, ts_ms, faces_count, result) VALUES(?, ?, ?, ?, ?)",
			[fiche_id, field_name, ts, faces, result]);
	}
}
