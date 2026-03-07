import Protocol.DamageType;

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

enum EncounterEntityType {
	CHARACTER(ficheId:String);
	NPC(npcName:String);
}

typedef EncounterEntry = {
	var entity:EncounterEntityType;
	var initiative:Int;
	var currentHp:Null<Int>;
	var note:Null<String>;
};

enum CampaignEventType {
	ADD_NPC(npc:NPCInfo);
	ADD_TO_ENCOUNTER(entity:EncounterEntityType, initiative:Int);
	REMOVE_FROM_ENCOUNTER(index:Int);
	CLEAR_ENCOUNTER;
	DAMAGE_NPC_IN_ENCOUNTER(index:Int, amount:Int, damageType:DamageType);
	HEAL_NPC_IN_ENCOUNTER(index:Int, amount:Int);
	SET_ENCOUNTER_NOTE(index:Int, note:String);
}

typedef CampaignEventTs = {
	var type:CampaignEventType;
	var ts:Float;
	var id:Int;
};

