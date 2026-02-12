import model.DatabaseHandler;
import haxe.Template;
import express.Next;
import express.Response;
import express.Request;
import express.Express;
import jsasync.IJSAsync;

class Server implements IJSAsync {
	static function main() {
		DatabaseHandler.init();
		var app = new express.Express();
		app.use(Express.json({inflate: false}));
		app.use(Express.serveStatic("static"));
		app.use("/api/fiche", FicheRouter.getRouter());
		app.use("/", serveIndex);
		app.listen(8000, () -> {
			trace('Started, listing on :8000');
		});
	}

	@:jsasync static function serveIndex(req:Request, res:Response, next:Next) {
		var tplFile = Fs.readFile("templates/index.html").jsawait().toString();
		var tpl = new Template(tplFile);
		var context = {
			time: Date.now().getTime()
		};
		res.end(tpl.execute(context));
	}
}
