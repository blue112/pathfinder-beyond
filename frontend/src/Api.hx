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

	@:jsasync static public function pushEvent(ficheId:String, event:FicheEventType):Promise<Dynamic> {
		var r = Browser.window.fetch('/api/fiche/debug/$ficheId/push', {
			method: "put",
			body: Serializer.run(event)
		}).jsawait();
		trace(r.text().jsawait());
	}
}
