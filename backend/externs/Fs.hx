import js.node.Buffer;
import js.lib.Promise;

@:jsRequire("fs/promises")
extern class Fs {
	static function readFile(path:String):Promise<Buffer>;
}
