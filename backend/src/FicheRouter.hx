import model.DiceRoll;
import express.Express;
import haxe.Unserializer;
import jsasync.IJSAsync;
import model.FicheEvent;
import model.DatabaseHandler;
import js.node.Crypto;
import macros.GetAllFields;
import express.Next;
import express.Response;
import express.Request;
import express.Router;

class FicheRouter implements IJSAsync {
	static public function getRouter() {
		var router = new Router();
		router.post("/createFiche", onCreateFiche);
		router.get("/:ficheId", checkFicheExists, getFiche);
		router.delete("/:ficheId/:eventId", checkFicheExists, onDelEvent);
		router.post("/:ficheId/roll", checkFicheExists, onDiceRoll);
		router.get("/:ficheId/rolls", checkFicheExists, fetchDiceRolls);
		router.put("/debug/:ficheId/push", Express.raw({type: "*/*"}), onPushEvent);
		return router;
	}

	@:jsasync static public function fetchDiceRolls(req:Request, res:Response, next:Next) {
		var fiche_id = req.fiche.fiche_id;
		var rolls = DiceRoll.fetch(fiche_id).jsawait();

		return res.json(rolls.map(r -> r.toPublic()));
	}

	@:jsasync static public function onDiceRoll(req:Request, res:Response, next:Next) {
		var body:{faceCount:Int, fieldName:String} = cast req.body;
		if (!Std.isOfType(body.faceCount, Int) || body.faceCount > 100 || body.faceCount < 2) {
			res.status(400).json({error: "Invalid dice"});
			return;
		}
		if (!Std.isOfType(body.fieldName, String) || body.fieldName.length > 50 || body.fieldName.length < 2) {
			res.status(400).json({error: "Invalid field"});
			return;
		}

		var fiche_id = req.fiche.fiche_id;

		var roll = new DiceRoll(fiche_id, body.fieldName, body.faceCount);
		roll.roll();
		var inserted = roll.insert().jsawait();
		res.json({result: roll.result, roll_id: inserted});
	}

	@:jsasync static public function checkFicheExists(req:Request, res:Response, next:Next) {
		var ficheId = (req.params : Dynamic).ficheId;
		var fiche = DatabaseHandler.exec("SELECT * FROM fiche WHERE fiche_id = ?", [ficheId]).jsawait();
		if (fiche.length == 0) {
			res.status(404).end("Not found");
			return;
		}

		req.fiche = fiche[0];

		next.call();
	}

	@:jsasync static public function getFiche(req:Request, res:Response, next:Next) {
		var ficheId = req.fiche.fiche_id;

		var events:Array<FicheEventTs> = DatabaseHandler.exec("SELECT id, event_type, event_params, ts_ms FROM fiche_events WHERE fiche_id = ?", [ficheId])
			.jsawait()
			.map(e -> {
				var ev = FicheEventType.createByName(e.event_type, Unserializer.run(e.event_params.toString()));
				return {type: ev, ts: e.ts_ms, id: e.id};
			});

		res.hx(events);
	}

	@:jsasync static public function onDelEvent(req:Request, res:Response, next:Next) {
		var ficheId = (req.params : Dynamic).ficheId;
		var eventId = (req.params : Dynamic).eventId;
		DatabaseHandler.exec("DELETE FROM fiche_events WHERE fiche_id = ? AND id = ?", [ficheId, eventId]).jsawait();
		res.json({success: true});
	}

	@:jsasync static public function onPushEvent(req:Request, res:Response, next:Next) {
		var ficheId = (req.params : Dynamic).ficheId;
		var fiche = DatabaseHandler.exec("SELECT * FROM fiche WHERE fiche_id = ?", [ficheId]).jsawait();
		if (fiche.length == 0) {
			res.status(404).end("Not found");
			return;
		}

		var event = Unserializer.run((cast req.body).toString());
		if (!Std.isOfType(event, FicheEventType)) {
			res.end("Invalid event");
			return;
		}

		var fe = new FicheEvent(ficheId, event);
		fe.insert().jsawait();
		res.json({"success": true});
	}

	@:jsasync static public function onCreateFiche(req:Request, res:Response, next:Next) {
		var body:Dynamic<String> = req.body;
		var fiche:BasicFicheData = cast body;
		try {
			fiche.alignement = body.alignement.parseCharacterAlignement();
			fiche.characterClass = body.characterClass.parseCharacterClass();
			fiche.sizeCategory = body.sizeCategory.parseSizeCategory();
			fiche.level = body.level.parseInt();
			fiche.age = body.age.parseInt();
			fiche.heightCm = body.heightCm.parseInt();
			fiche.weightKg = body.weightKg.parseInt();

			// Let's check that we have everything
			for (i in GetAllFields.getNames(BasicFicheData)) {
				if (!Reflect.hasField(fiche, i)) {
					res.status(400).end('Missing field $i');
					return;
				}
				var value = Reflect.getProperty(fiche, i);
				if (value == null || value == "") {
					res.status(400).end('Invalid value for $i');
					return;
				}
			}
		} catch (e:Dynamic) {
			trace('Error when creating fiche with body $body: $e');
			res.status(500).end();
			return;
		}

		var ficheId = untyped Crypto.randomUUID();
		DatabaseHandler.exec("INSERT INTO fiche(fiche_id, characterName) VALUES(?, ?)", [ficheId, fiche.characterName]).jsawait();
		var fe = new FicheEvent(ficheId, CREATE(fiche));
		fe.insert().jsawait();

		res.json({ficheId: ficheId});
	}
}
