import Protocol;
import RulesSkills;

using Rules;
using ProtocolUtil;
using Std;

class FullCharacter {
	public var basics:BasicFicheData;

	public var characteristics:Characteristics;
	public var characteristicsMod:Characteristics;
	public var skillRanks:Array<SkillType>;
	public var current_hp:Int;
	public var max_hp_modifier:Int;
	public var levelUpDices:Array<Int>;
	public var level:Int;
	public var additionalClassSkills:Array<SkillType>;
	public var skillModifiers:Map<SkillType, Int>;
	public var exceptionalSkillModifiers:Array<ExceptionalSkillModifier>;
	public var protections:Array<Protection>;
	public var weapons:Array<Weapon>;
	public var tempMods:Array<TemporaryModifier>;
	public var money_po:Float;
	public var inventory:Array<InventoryItem>;

	public function new() {
		this.skillRanks = [];
		this.current_hp = 0;
		this.levelUpDices = [];
		this.level = 1;
		this.max_hp_modifier = 0;
		this.additionalClassSkills = [];
		this.skillModifiers = new Map();
		this.exceptionalSkillModifiers = [];
		this.protections = [];
		this.tempMods = [];
		this.weapons = [];
		this.inventory = [];
		this.money_po = 0;
	}

	function updateHP() {
		current_hp = getMaxHitPoints();
	}

	public function processEvent(type:FicheEventType) {
		switch (type) {
			case CREATE(data):
				this.basics = data;
			case SET_CHARACTERISTICS(data):
				this.characteristics = data;
				updateCharacts();
				updateHP();
			case ADD_CLASS_SKILL(skill):
				if (!Rules.isClassSkill(this, skill))
					this.additionalClassSkills.push(skill);

			case CHANGE_CARAC(c, amount):
				switch (c) {
					case STRENGTH: this.characteristics.str += amount;
					case DEXTERITY: this.characteristics.dex += amount;
					case CONSTITUTION:
						var oldMod = Math.floor(this.characteristics.con / 2);
						this.characteristics.con += amount;
						var newMod = Math.floor(this.characteristics.con / 2);
						// We need to update current HP depending on mod
						var diffHP = (newMod - oldMod) * level;
						if (diffHP > 0) current_hp = Math.min(current_hp + diffHP, getMaxHitPoints()).int();
					case INTELLIGENCE: this.characteristics.int += amount;
					case WISDOM: this.characteristics.wis += amount;
					case CHARISMA: this.characteristics.cha += amount;
				}
				updateCharacts();
			case ADD_WEAPON(weapon):
				weapons.push(weapon);
			case LEVEL_UP(hp_dice):
				level += 1;
				hp_dice = Math.min(hp_dice, getHitDice()).int();
				levelUpDices.push(hp_dice);
			case TRAIN_SKILL(skill):
				skillRanks.push(skill);
			case DECREASE_SKILL(skill):
				skillRanks.remove(skill);
			case CHANGE_HP(amount):
				current_hp = Math.min(current_hp + amount, getMaxHitPoints()).int();
			case CHANGE_MAX_HP(amount):
				max_hp_modifier += amount;
			case SET_SKILL_MODIFIER(skill, mod):
				skillModifiers.set(skill, mod);
			case ADD_EXCEPTIONAL_SKILL_MODIFIER(skill, mod, why):
				exceptionalSkillModifiers.push({
					skill: skill,
					mod: mod,
					why: why
				});
			case ADD_PROTECTION(armor):
				protections.push(armor);
			case ADD_TEMPORARY_MODIFIER(mod):
				tempMods.push(mod);
				updateCharacts();
			case REMOVE_TEMPORARY_MODIFIER(index):
				tempMods.splice(index, 1);
				updateCharacts();
			case CHANGE_MONEY(amount):
				money_po += amount;
			case ADD_INVENTORY_ITEM(item):
				inventory.push(item);
			case CHANGE_ITEM_QUANTITY(item, new_quantity):
				inventory[item].quantity = new_quantity;
			case REMOVE_INVENTORY_ITEM(item):
				inventory.splice(item, 1);
		}
	}

	private function updateCharacts() {
		characteristicsMod = cast {};
		for (i in Reflect.fields(characteristics)) {
			var value:Int = Reflect.getProperty(characteristics, i);
			var mod:Int = Std.int(value / 2) - 5;

			var totalTempMod = getTempMods([CHARACTERISTIC(i.parseCarac())]).sum();
			mod += totalTempMod;

			Reflect.setProperty(characteristicsMod, i, mod);
		}
	}

	public function getTempMods(matching:Array<Field>) {
		return tempMods.filter(t -> {
			for (i in matching)
				if (Type.enumEq(t.on, i))
					return true;
			return false;
		});
	}

	public function getNumberHitDice() {
		if (basics.characterClass.match(CONJURATEUR_EIDOLON_BIPED)) {
			return [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15, 15][level];
		}

		return level;
	}

	public function getHitDice() {
		return switch (basics.characterClass) {
			case CONJURATEUR, ROUBLARD:
				8;
			case CONJURATEUR_EIDOLON_BIPED:
				10;
		}
	}

	public function getMaxHitPoints() {
		var predilectionClassBonus = if (basics.usePredilectionHP) 1 else 0;
		var hd = getHitDice();
		var total = hd + predilectionClassBonus + characteristicsMod.con;

		// Add predilection bonus and cons
		for (i in 1...getNumberHitDice()) {
			total += predilectionClassBonus + characteristicsMod.con;
		}
		for (dice in levelUpDices) {
			total += dice;
		}

		total += max_hp_modifier;

		return total;
	}
}
