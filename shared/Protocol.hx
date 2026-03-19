import RulesSkills.SkillType;

// Name matters, order does not
enum FicheEventType {
    CREATE(data:BasicFicheData);
    SET_CHARACTERISTICS(data:Characteristics);
    CHANGE_CARAC(carac:Characteristic, amount:Int);
    ADD_WEAPON(weapon:Weapon);
    REMOVE_WEAPON(index:Int);
    TRAIN_SKILL(skill:SkillType);
    DECREASE_SKILL(skill:SkillType);
    CHANGE_HP(amount:Int);
    DAMAGE_HP(amount:Int, damageType:DamageType);
    ADD_DAMAGE_RESISTANCE(damageType:DamageType, amount:Int);
    REMOVE_DAMAGE_RESISTANCE(damageType:DamageType);
    CHANGE_MAX_HP(amount:Int);
    LEVEL_UP(hpDice:Int);
    ADD_CLASS_SKILL(skill:SkillType);
    SET_SKILL_MODIFIER(skill:SkillType, mod:Int);
    SET_SAVING_THROW_MODIFIER(st:SavingThrow, mod:Int);
    SET_SPEED_MODIFIER(mod:Int);
    CHANGE_ALIGNEMENT(alignement:CharacterAlignement);
    ADD_EXCEPTIONAL_MODIFIER(mod:TemporaryModifier);
    ADD_PROTECTION(armor:Protection);
    REMOVE_PROTECTION(index:Int);
    ADD_TEMPORARY_MODIFIER(mod:TemporaryModifier);
    REMOVE_TEMPORARY_MODIFIER(index:Int);
    CHANGE_MONEY(amount_po:Float);
    CHANGE_BANK_MONEY(amount_po:Float);
    ADD_INVENTORY_ITEM(item:InventoryItem);
    CHANGE_ITEM_QUANTITY(item:Int, new_quantity:Int);
    REMOVE_INVENTORY_ITEM(item:Int);
    CHANGE_ITEM_NAME(item:Int, newName:String);
    CHANGE_ITEM_PRIORITY(item:Int, priority:Int);
    ADD_SPELL(spell:Spell);
    REMOVE_SPELL(index:Int);
}

enum DamageType {
    // Physical
    BLUDGEONING;
    PIERCING;
    SLASHING;
    // Energy
    ACID;
    COLD;
    ELECTRICITY;
    FIRE;
    SONIC;
    FORCE;
    // Positive / Negative energy
    POSITIVE;
    NEGATIVE;
    // Alignment
    CHAOTIC;
    EVIL;
    GOOD;
    LAWFUL;
    // Fallback
    UNTYPED;
}

enum SpellSchool {
    ABJURATION;
    CONJURATION;
    DIVINATION;
    ENCHANTMENT;
    EVOCATION;
    ILLUSION;
    NECROMANCY;
    TRANSMUTATION;
    UNIVERSAL;
}

enum SpellComponent {
    VERBAL;
    SOMATIC;
    MATERIAL;
}

enum SpellSaveEffect {
    HALF_DAMAGE;
    NEGATES;
    REVEALS;
}

// n is a string to support NLS formulas (e.g. "NLS/2")
enum SpellCastingTime {
    STANDARD_ACTION;
    FULL_ACTION;
    N_ROUNDS(n:String);
    N_MINUTES(n:String);
}

enum SpellDuration {
    INSTANTANEOUS;
    N_ROUNDS(n:String);
    N_MINUTES(n:String);
    CONCENTRATION;
}

// cases is a string to support NLS formulas
enum SpellRange {
    PERSONAL;
    TOUCH;
    CLOSE;
    MEDIUM;
    LONG;
    SPECIFIC(cases:String);
}

typedef Spell = {
    var name:String;
    var shortDescription:Null<String>;
    var school:SpellSchool;
    var level:Int;
    var usesPerDay:Null<Int>;
    var savingThrowType:Null<SavingThrow>;
    var saveEffect:Null<SpellSaveEffect>;
    var spellResistance:Bool;
    var targets:String;
    var castingTime:SpellCastingTime;
    var duration:SpellDuration;
    var canEndVoluntarily:Bool;
    var components:Array<SpellComponent>;
    var areaOfEffect:Null<String>;
    var range:SpellRange;
    var longDescription:String;
    var ?priority:Int;
};

typedef FicheEventTs = {
    var type:FicheEventType;
    var ts:Float;
    var id:Int;
};

typedef InventoryItem = {
    var name:String;
    var quantity:Int;
    var ?priority:Int;
}

enum ProtectionType {
    ARMOR;
    SHIELD;
    NATURAL_ARMOR;
    EVADE; // Mod dex
    ARMOR_BONUS; // Will apply to every CA
}

typedef Protection = {
    var name:String;
    var type:ProtectionType;
    var armor:Int;
    var max_dex:Null<Int>;
    var armorMalus:Null<Int>;
};

typedef Weapon = {
    var name:String;
    var damage_dices:Array<Int>;
    var attack_modifier:Int;
    var weaponAttackCharacteristic:Characteristic;
    var weaponHasPlus50PercentDamage:Bool;
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

typedef TemporaryModifier = {
    var on:Field;
    var mod:Int;
    var why:String;
}

enum Field {
    SKILL(type:SkillType);
    CHARACTERISTIC(carac:Characteristic);
    AC;
    INITIATIVE;
    SAVING_THROW(st:SavingThrow);
    MAX_HP;
    WEAPON_ATTACK;
    WEAPON_DAMAGE;
    SAVING_THROW_NOTE(st:SavingThrow);
}

typedef ExceptionalSkillModifier = {
    var skill:SkillType;
    var mod:Int;
    var why:String;
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
    gender:CharacterGender,
    usePredilectionHP:Bool,
    sizeCategory:SizeCategory,
    age:Int,
    heightCm:Int,
    weightKg:Int,
    hair:String,
    eyes:String,
};

enum CharacterGender {
    MALE;
    FEMALE;
}

enum CharacterRace {
    HUMAN;
    DWARF;
    ELF;
    HALF_ELF;
    GNOME;
    HALF_ORC;
    ANGEL;
}

enum CharacterClass {
    ROUBLARD; // Unchained
    CONJURATEUR; // Unchained
    CONJURATEUR_EIDOLON_BIPED; // Unchained
    METAMORPHE;
    MAGICIEN;
    PRETRE;
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
    SUB_EVENTS(fiche_id:String, latest_event:Int, withDiceRolls:Bool);
    PING;
}

enum WSServerMessage {
    SUB_OK;
    NEW_EVENTS(fiche_id:String, events:Array<FicheEventTs>);
    NEW_DICE_ROLL(fiche_id:String, dr:PublicDiceRoll);
    PONG;
}

typedef FicheNote = {
    last_edit:Float,
    order:Null<Int>,
    id:Int,
    content:String,
};

typedef PublicDiceRoll = {
    var field_name:String;
    var faces:Int;
    var result:Int;
    var ts:Float;
    var mod:Int;
};
