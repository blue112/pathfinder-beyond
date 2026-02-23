import model.DiceRoll;
import model.FicheEvent;
import model.DatabaseHandler;
import express.Next;
import express.Response;
import express.Request;
import express.Router;
import jsasync.IJSAsync;
import js.node.Crypto;

class CampaignRouter implements IJSAsync {
	static public function getRouter() {
		var router = new Router();
		router.post("/new", onCreateCampaign);
		router.get("/:campaignId", checkCampaignExists, loadCampaign);
		router.post("/:campaignId/link", checkCampaignExists, linkFiche);
		return router;
	}

	@:jsasync static public function checkCampaignExists(req:Request, res:Response, next:Next) {
		var campaign_id = (req.params : Dynamic).campaignId;
		var campaign = DatabaseHandler.exec("SELECT * FROM campaign WHERE campaign_id = ?", [campaign_id]).jsawait();
		if (campaign.length == 0) {
			res.status(404).end("Campaign not found");
			return;
		}

		req.campaign = campaign[0];

		next.call();
	}

	@:jsasync static public function linkFiche(req:Request, res:Response, next:Next) {
		var fiche_id:String = (cast req.body).fiche_id;
		var fiche = DatabaseHandler.exec("SELECT * FROM fiche WHERE fiche_id = ?", [fiche_id]).jsawait();
		if (fiche.length == 0) {
			res.status(404).end("Fiche not found");
			return;
		}

		try {
			DatabaseHandler.execInsert("INSERT INTO campaign_fiche(campaign_id, fiche_id) VALUES(?, ?)", [req.campaign.campaign_id, fiche_id]).jsawait();
		} catch (e:Dynamic) // Probably duplicate
		{
			if (e.string().contains("Duplicate")) {
				res.status(400).json({"error": "Fiche already linked"});
				return;
			}
			trace(e);
			res.status(500).json({"error": "Internal error"});
			return;
		}
		res.json({"success": true});
	}

	@:jsasync static public function loadCampaign(req:Request, res:Response, next:Next) {
		var linkedFiche = DatabaseHandler.exec("SELECT fiche_id, characterName FROM campaign_fiche LEFT JOIN fiche USING(fiche_id) WHERE campaign_id = ?",
			[req.campaign.campaign_id])
			.jsawait();

		for (i in linkedFiche) {
			i.events = FicheEvent.getEvents(i.fiche_id).jsawait();
			var latestDiceRoll = DiceRoll.fetchLatest(i.fiche_id).jsawait();
			if (latestDiceRoll != null)
				i.latestDiceRoll = latestDiceRoll.toPublic();
		}

		res.hx({name: req.campaign.name, fiches: linkedFiche});
	}

	@:jsasync static public function onCreateCampaign(req:Request, res:Response, next:Next) {
		var body:{name:String} = cast req.body;
		var name = body.name;
		if (!Std.isOfType(name, String) || name.length == 0 || name.length > 50) {
			res.status(400).json({error: "Invalid name"});
			return;
		}

		var campaignId = untyped Crypto.randomUUID();
		DatabaseHandler.exec("INSERT INTO campaign(campaign_id, name) VALUES(?, ?)", [campaignId, name]).jsawait();

		res.json({campaignId: campaignId});
	}
}
