package model;

import jsasync.IJSAsync;
import haxe.Serializer;

class FicheEvent implements IJSAsync {
	var event:FicheEventType;
	var fiche_id:String;

	public function new(fiche_id:String, ?event:FicheEventType) {
		this.event = event;
		this.fiche_id = fiche_id;
	}

	@:jsasync public function insert() {
		var event_name = event.getName();
		var event_params = event.getParameters();
		Serializer.USE_ENUM_INDEX = false;
		var r = DatabaseHandler.exec("INSERT INTO fiche_events(fiche_id, event_type, event_params) VALUES(?, ?, ?)",
			[fiche_id, event_name, Serializer.run(event_params)])
			.jsawait();
		trace(r);
	}
}
