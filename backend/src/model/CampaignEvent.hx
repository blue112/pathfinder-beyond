package model;

import CampaignProtocol;
import haxe.Unserializer;
import js.lib.Promise;
import jsasync.IJSAsync;
import haxe.Serializer;

class CampaignEvent implements IJSAsync {
	var event:CampaignEventType;
	var campaign_id:String;
	var ts_ms:Float;
	var id:Int;

	public function new(campaign_id:String, ?event:CampaignEventType) {
		this.event = event;
		this.campaign_id = campaign_id;
		this.ts_ms = Date.now().getTime();
	}

	public function getId():Int { return id; }
	public function getTs():Float { return ts_ms; }

	public function toPublic():CampaignEventTs {
		return {
			id: id,
			ts: ts_ms,
			type: event
		};
	}

	@:jsasync public function insert() {
		var event_name = event.getName();
		var event_params = event.getParameters();
		Serializer.USE_ENUM_INDEX = false;
		var r:Int = DatabaseHandler.execInsert(
			"INSERT INTO campaign_events(campaign_id, event_type, event_params, ts_ms) VALUES(?, ?, ?, ?)",
			[campaign_id, event_name, Serializer.run(event_params), ts_ms])
			.jsawait();
		id = r;
		trace('Campaign event inserted on campaign $campaign_id as event #$r');
	}

	@:jsasync static public function getEvents(campaignId:String):Promise<Array<CampaignEventTs>> {
		return DatabaseHandler.exec(
			"SELECT id, event_type, event_params, ts_ms FROM campaign_events WHERE campaign_id = ? ORDER BY id ASC",
			[campaignId])
			.jsawait()
			.map(e -> {
				var ev = CampaignEventType.createByName(e.event_type, Unserializer.run(e.event_params.toString()));
				return {type: ev, ts: e.ts_ms, id: e.id};
			});
	}
}
