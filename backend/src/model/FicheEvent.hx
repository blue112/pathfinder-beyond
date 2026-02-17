package model;

import haxe.Unserializer;
import js.lib.Promise;
import jsasync.IJSAsync;
import haxe.Serializer;

class FicheEvent implements IJSAsync {
	var event:FicheEventType;
	var fiche_id:String;
	var ts_ms:Float;
	var id:Int;

	public function new(fiche_id:String, ?event:FicheEventType) {
		this.event = event;
		this.fiche_id = fiche_id;
		this.ts_ms = Date.now().getTime();
	}

	public function toPublic() {
		return {
			id: id,
			ts: ts_ms,
			type: event
		};
	}

	@:jsasync public function insert() {
		var event_name = event.getName();
		var event_params = event.getParameters();
		Serializer.USE_ENUM_INDEX = false;
		var r:Int = DatabaseHandler.execInsert("INSERT INTO fiche_events(fiche_id, event_type, event_params, ts_ms) VALUES(?, ?, ?, ?)",
			[fiche_id, event_name, Serializer.run(event_params), ts_ms])
			.jsawait();
		id = r;
		trace('Event inserted on fiche $fiche_id as event #$r');
	}

	@:jsasync static public function getEventsAfter(ficheId:String, latest_id:Int):Promise<Array<FicheEventTs>> {
		return DatabaseHandler.exec("SELECT id, event_type, event_params, ts_ms FROM fiche_events WHERE fiche_id = ? AND id > ?", [ficheId, latest_id])
			.jsawait()
			.map(e -> {
				var ev = FicheEventType.createByName(e.event_type, Unserializer.run(e.event_params.toString()));
				return {type: ev, ts: e.ts_ms, id: e.id};
			});
	}

	static public function getEvents(ficheId:String):Promise<Array<FicheEventTs>> {
		return getEventsAfter(ficheId, 0);
	}
}
