import haxe.Unserializer;
import haxe.Timer;
import haxe.Serializer;
import js.html.WebSocket;

class WsTalker {
	var ws:WebSocket;
	var onConnect:Void->Void;
	var onDisconnect:Void->Void;

	public var onNewEvent:String->FicheEventTs->Void;

	var backoff:Int;
	var isConnected:Bool = false;

	public function new(onConnect:Void->Void, onDisconnect:Void->Void) {
		this.onConnect = onConnect;
		this.onDisconnect = onDisconnect;
		connect();

		var pingTimer = new Timer(30000); // 30s
		pingTimer.run = send.bind(PING);
	}

	public function connect() {
		ws = new WebSocket("/api/ws");
		ws.onopen = function() {
			trace("Websocket connected");
			backoff = 0;
			isConnected = true;
			onConnect();
		};
		ws.onclose = function() {
			onDisconnect();
			isConnected = false;
			trace('Websocket disconnected, reconnecting...');
			haxe.Timer.delay(connect, backoff * 2000);
			backoff++;
		}
		ws.onmessage = function(msg) {
			var msg:WSServerMessage = Unserializer.run(msg.data);
			switch (msg) {
				case SUB_OK, PONG: // don't care
				case NEW_EVENTS(fiche_id, events):
					if (onNewEvent == null)
						return;

					for (ev in events) {
						onNewEvent(fiche_id, ev);
					}
			}
		}
	}

	public function send(msg:WSClientMessage) {
		if (isConnected)
			ws.send(Serializer.run(msg));
	}

	public function subscribe(fiche_id:String, latest_event:Int) {
		send(SUB_EVENTS(fiche_id, latest_event));
	}
}
