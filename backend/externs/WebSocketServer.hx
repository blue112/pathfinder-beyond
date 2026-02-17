@:jsRequire("ws", "Server")
extern class WebSocketServer {
	public function new(params:Dynamic);
	public function on(event:String, cb:Dynamic):Void;
}
