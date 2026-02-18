import RulesSkills.SkillType;

enum FicheEventType {
	CREATE(data:BasicFicheData);
	SET_CHARACTERISTICS(data:Characteristics);
	CHANGE_CARAC(carac:Characteristic, amount:Int);
	ADD_WEAPON(weapon:Weapon);
	TRAIN_SKILL(skill:SkillType);
	DECREASE_SKILL(skill:SkillType);
	CHANGE_HP(amount:Int);
	CHANGE_MAX_HP(amount:Int);
	LEVEL_UP(hpDice:Int);
	ADD_CLASS_SKILL(skill:SkillType);
}

typedef FicheEventTs = {
	var type:FicheEventType;
	var ts:Float;
	var id:Int;
};

typedef Weapon = {
	var name:String;
	var damage_dices:Array<Int>;
	var attack_modifier:Int;
	var weaponAttackCharacteristic:Characteristic;
	var weaponDamageCharacteristic:Characteristic;
	var damage_modifier:Int;
	var critical_text:WeaponCriticalStat;
	var damage_types:Array<WeaponDamageType>;
	var range:Null<Int>;
	var munitions:String;
};

enum WeaponDamageType {
	PERFORANT;
	TRANCHANT;
	CONTONDANT;
}

enum Characteristic {
	STRENGTH;
	DEXTERITY;
	CONSTITUTION;
	INTELLIGENCE;
	WISDOM;
	CHARISMA;
}

typedef WeaponCriticalStat = {
	var nums:Array<Int>;
	var damageMultiplier:Int;
};

typedef FullCharacter = {
	@:optional var basics:BasicFicheData;
	@:optional var characteristics:Characteristics;
	@:optional var characteristicsMod:Characteristics;
	var skillRanks:Array<SkillType>;
	var current_hp:Int;
	var max_hp_modifier:Int;
	var levelUpDices:Array<Int>;
	var level:Int;
	var additionalClassSkills:Array<SkillType>;
}

typedef Characteristics = {
	var str:Int;
	var dex:Int;
	var con:Int;
	var int:Int;
	var wis:Int;
	var cha:Int;
};

enum SavingThrow {
	REFLEXES;
	VIGOR;
	WILL;
}

typedef BasicFicheData = {
	playerName:String,
	characterName:String,
	alignement:CharacterAlignement,
	characterClass:CharacterClass,
	divinityName:String,
	origin:String,
	race:CharacterRace,
	gender:String,
	sizeCategory:SizeCategory,
	age:Int,
	heightCm:Int,
	weightKg:Int,
	hair:String,
	eyes:String,
};

enum CharacterRace {
	HUMAN;
	DWARF;
	ELF;
	HALF_ELF;
	GNOME;
	HALF_ORC;
}

enum CharacterClass {
	ROUBLARD;
}

enum CharacterAlignement {
	ALIGNEMENT_LB;
	ALIGNEMENT_NB;
	ALIGNEMENT_CB;
	ALIGNEMENT_LN;
	ALIGNEMENT_N;
	ALIGNEMENT_LM;
	ALIGNEMENT_NM;
	ALIGNEMENT_CM;
}

enum SizeCategory {
	SIZE_I;
	SIZE_MIN;
	SIZE_TP;
	SIZE_P;
	SIZE_M;
	SIZE_G;
	SIZE_TG;
	SIZE_GIG;
	SIZE_C;
}

enum WSClientMessage {
	SUB_EVENTS(fiche_id:String, latest_event:Int);
	PING;
}

enum WSServerMessage {
	SUB_OK;
	NEW_EVENTS(fiche_id:String, events:Array<FicheEventTs>);
	PONG;
}
