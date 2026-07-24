import model.DatabaseHandler;
import haxe.Serializer;
import haxe.Unserializer;
import jsasync.IJSAsync;

class DataMigrations implements IJSAsync {
	@:jsasync static public function run() {
		fixLegacyRaceGender().jsawait();
		removeLegacyProtections().jsawait();
	}

	static function parseOldRace(s:String):CharacterRace {
		// Try exact enum constructor name (upper-cased)
		try {
			var r = CharacterRace.createByName(s.toUpperCase());
			if (r != null)
				return r;
		} catch (_:Dynamic) {}
		// Fall back to old display-name option values from raceToString()
		return switch (s) {
			case "Humain" | "Humain(e)": HUMAN;
			case "Nain(e)": DWARF;
			case "Elfe": ELF;
			case "Demi-elfe": HALF_ELF;
			case "Gnome": GNOME;
			case "Demi-orque": HALF_ORC;
			case "Ange": ANGEL;
			case _: null;
		};
	}

	static function parseOldGender(s:String):CharacterGender {
		return switch (s) {
			case "M": MALE;
			case "F": FEMALE;
			case _:
				try CharacterGender.createByName(s.toUpperCase()) catch (_:Dynamic) null;
		};
	}

	@:jsasync static function removeLegacyProtections() {
		var rows = DatabaseHandler.exec("DELETE FROM fiche_events WHERE event_type IN ('ADD_PROTECTION', 'REMOVE_PROTECTION') AND id < 4184").jsawait();
		var affected:Int = (cast rows).affectedRows;
		if (affected > 0)
			trace(affected + ' protection rows deleted');

		var rows = DatabaseHandler.exec("SELECT id, event_type, event_params FROM fiche_events WHERE event_type IN('ADD_EXCEPTIONAL_MODIFIER', 'ADD_TEMPORARY_MODIFIER')")
			.jsawait();
		for (row in rows) {
			try {
				Unserializer.run(row.event_params.toString()); // OK if no crash
			} catch (e:Dynamic) {
				// Corrupted entry, remove it
				if (StringTools.contains(row.event_params, ":AC:")
					|| StringTools.contains(row.event_params, ":AC_DEFLECTION:")
					|| StringTools.contains(row.event_params, ":AC_DODGE:")) {
					var newData = [{on: Field.INITIATIVE, mod: 0, why: ""}];
					trace('Fixing entry ${row.event_params}');
					DatabaseHandler.exec("UPDATE fiche_events SET event_params = ? WHERE id=?", [Serializer.run(newData), row.id]).jsawait();
				}
			}
		}
	}

	@:jsasync static function fixLegacyRaceGender() {
		var rows = DatabaseHandler.exec("SELECT id, event_params FROM fiche_events WHERE event_type = 'CREATE'").jsawait();

		var fixCount = 0;
		for (row in rows) {
			var params:Array<Dynamic> = Unserializer.run(row.event_params.toString());
			var data:BasicFicheData = params[0];
			var changed = false;

			var rawRace:Dynamic = data.race;
			var rawGender:Dynamic = data.gender;
			if (rawRace == null || Std.isOfType(rawRace, String)) {
				var mapped = parseOldRace(rawRace);
				if (mapped == null) {
					trace('DataMigrations: unrecognized race "$rawRace" in event ${row.id}, skipping');
					continue;
				}
				data.race = mapped;
				changed = true;
			}
			if (rawGender == null || Std.isOfType(rawGender, String)) {
				var mapped = parseOldGender(rawGender);
				if (mapped == null) {
					trace('DataMigrations: unrecognized gender "$rawGender" in event ${row.id}, skipping');
					continue;
				}
				data.gender = mapped;
				changed = true;
			}

			if (changed) {
				Serializer.USE_ENUM_INDEX = false;
				DatabaseHandler.exec("UPDATE fiche_events SET event_params = ? WHERE id = ?", [Serializer.run(params), row.id]).jsawait();
				fixCount++;
			}
		}

		if (fixCount > 0)
			trace('DataMigrations: fixed race/gender in $fixCount CREATE event(s)');
	}
}
