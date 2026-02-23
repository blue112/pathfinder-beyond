import haxe.ds.StringMap;
import jsasync.IJSAsync;
import model.FicheEvent;
import js.node.Buffer;
import haxe.Unserializer;

class WebsocketClient implements IJSAsync {
	var ws:Dynamic;
	var disconnected:Bool = false;

	static var subs:StringMap<Array<WebsocketClient>> = new StringMap();
	static var subsDiceRolls:StringMap<Array<WebsocketClient>> = new StringMap();

	static public function notifyRoll(fiche_id:String, diceroll:PublicDiceRoll) {
		if (!subsDiceRolls.exists(fiche_id))
			return;

		for (client in subsDiceRolls.get(fiche_id)) {
			client.send(NEW_DICE_ROLL(fiche_id, diceroll));
		}
	}

	static public function notifySubs(fiche_id:String, event:FicheEventTs) {
		if (!subs.exists(fiche_id))
			return;

		for (client in subs.get(fiche_id)) {
			client.send(NEW_EVENTS(fiche_id, [event]));
		}
	}

	static function addSub(fiche_id:String, client:WebsocketClient) {
		if (!subs.exists(fiche_id))
			subs.set(fiche_id, []);

		subs.get(fiche_id).push(client);
		trace('Subscribed to events from $fiche_id, currently ${subs.get(fiche_id).length} subs to this fiche');
	}

	static function addDiceRollsSubs(fiche_id:String, client:WebsocketClient) {
		if (!subsDiceRolls.exists(fiche_id))
			subsDiceRolls.set(fiche_id, []);

		subsDiceRolls.get(fiche_id).push(client);
	}

	public function new(ws:Dynamic, ip:String) {
		this.ws = ws;
		trace("New ws connection from " + ip);
		ws.on("close", onWebsocketDisconnect);
		ws.on('message', function(msg) {
			try {
				var msg:WSClientMessage = Unserializer.run(msg);
				if (!Std.isOfType(msg, WSClientMessage))
					return;

				parseMsg(msg);
			} catch (e:Dynamic) {
				trace('Error while parsing message');
			}
		});
	}

	public function send(msg:WSServerMessage) {
		try {
			ws.send(haxe.Serializer.run(msg));
		} catch (e:Dynamic) {
			disconnected = true;
			cleanup();
		}
	}

	@:jsasync public function parseMsg(msg:WSClientMessage) {
		switch (msg) {
			case SUB_EVENTS(fiche_id, latest_event, withDiceRolls):
				addSub(fiche_id, this);
				if (withDiceRolls)
					addDiceRollsSubs(fiche_id, this);

				send(SUB_OK);
				if (latest_event != null) {
					var newest_events = FicheEvent.getEventsAfter(fiche_id, latest_event).jsawait();
					if (newest_events.length > 0) {
						send(NEW_EVENTS(fiche_id, newest_events));
					}
				}
			case PING:
				send(PONG);
		}
	}

	public function cleanup() {
		for (clients in subs) {
			for (k in clients.copy()) {
				if (k == this)
					clients.remove(k);
			}
		}
	}

	public function onWebsocketDisconnect(code:Int, reason:Buffer) {
		disconnected = true;
		cleanup();
	}
}
