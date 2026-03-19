import haxe.Unserializer;
import js.node.Buffer;
import express.Next;
import express.Response;
import express.Request;

class HaxeBody {
    static public function middleware(req:Request, res:Response, next:Next) {
        var contentType = req.get("content-type");
        if (contentType == null || !contentType.startsWith("application/haxe-serialized")) {
            next.call();
            return;
        }
        var chunks:Array<Buffer> = [];
        (cast req).on("data", (chunk:Buffer) -> chunks.push(chunk));
        (cast req).on("end", () -> {
            try {
                (cast req).body = Unserializer.run(Buffer.concat(chunks).toString());
                next.call();
            } catch (e:Dynamic) {
                res.status(400).end();
            }
        });
    }
}
