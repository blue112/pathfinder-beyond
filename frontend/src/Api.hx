import haxe.Json;
import haxe.Serializer;
import js.lib.Promise;
import haxe.Unserializer;
import jsasync.IJSAsync;
import js.Browser;

class Api implements IJSAsync {
	@:jsasync static public function load(route:String):Promise<Dynamic> {
		if (route.charAt(0) != '/')
			route = '/$route';
		var r = Browser.window.fetch('/api$route').jsawait();
		var h = r.text().jsawait();
		return Unserializer.run(h);
	}

	@:jsasync static public function getRolls(ficheId:String):Promise<Array<{
		result:Int,
		ts:Int,
		field_name:String,
		faces:Int
	}>> {
		var r = Browser.window.fetch('/api/fiche/$ficheId/rolls').jsawait();
		var j = r.json().jsawait();
		return j;
	}

	@:jsasync static public function rollDice(ficheId:String, faces:Int, field:String):Promise<{result:Int, roll_id:Int}> {
		var r = Browser.window.fetch('/api/fiche/$ficheId/roll', {
			method: "post",
			headers: {
				"Content-type": "application/json",
			},
			body: Json.stringify({faceCount: faces, fieldName: field})
		}).jsawait();
		var j = r.json().jsawait();
		return j;
	}

	@:jsasync static public function saveNote(ficheId:String, note_id:Null<Int>, content:String):Promise<Dynamic> {
		if (note_id == null) {
			var r = Browser.window.fetch('/api/fiche/$ficheId/notes', {
				method: "post",
				headers: {
					"Content-type": "application/json",
				},
				body: Json.stringify({content: content})
			}).jsawait();
			return r.json().jsawait().id;
		} else {
			var r = Browser.window.fetch('/api/fiche/$ficheId/notes/$note_id', {
				method: "put",
				headers: {
					"Content-type": "application/json",
				},
				body: Json.stringify({content: content})
			}).jsawait();
			return r.json().jsawait();
		}
		return null;
	}

	@:jsasync static public function delEvent(ficheId:String, eventId:Int):Promise<Dynamic> {
		var r = Browser.window.fetch('/api/fiche/$ficheId/$eventId', {
			method: "delete",
		}).jsawait();
		var j = r.json().jsawait();
		return j;
	}

	@:jsasync static public function pushEvent(ficheId:String, event:FicheEventType):Promise<Dynamic> {
		var r = Browser.window.fetch('/api/fiche/debug/$ficheId/push', {
			method: "put",
			body: Serializer.run(event)
		}).jsawait();
		trace(r.text().jsawait());
	}
}
