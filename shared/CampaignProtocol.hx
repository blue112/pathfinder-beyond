typedef NPCSavingThrows = {
	var reflexes:Int;
	var vigor:Int;
	var will:Int;
};

typedef NPCInfo = {
	var name:String;
	var maxHp:Int;
	var ac:Int;
	var acContact:Int;
	var acBySurprise:Int;
	var initiativeModifier:Int;
	var savingThrows:NPCSavingThrows;
	var cr:String;
	var notes:Null<String>;
};

enum CampaignEventType {
	ADD_NPC(npc:NPCInfo);
}

typedef CampaignEventTs = {
	var type:CampaignEventType;
	var ts:Float;
	var id:Int;
};

