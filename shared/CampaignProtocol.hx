import Protocol.DamageType;
import Protocol.WeaponDamageType;

typedef NPCWeapon = {
	var name:String;
	var attackBonus:Int;
	var damage:String;
	var damageTypes:Array<WeaponDamageType>;
	var criticalNums:Array<Int>;
	var criticalMultiplier:Int;
	var note:Null<String>;
};

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
	var weapons:Array<NPCWeapon>;
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
	ADD_NPC_WEAPON(npcName:String, weapon:NPCWeapon);
}

typedef CampaignEventTs = {
	var type:CampaignEventType;
	var ts:Float;
	var id:Int;
};

