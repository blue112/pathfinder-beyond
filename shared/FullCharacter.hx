import haxe.ds.IntMap;
import Protocol;
import RulesSkills;

using Rules;
using ProtocolUtil;
using Std;

typedef SpellRegister = {
	public var spells:Array<Spell>;
	public var preparedSpells:Array<PreparedSpell>;
	public var preparationLocked:Bool;
	public var lockedPreparedIndices:Array<Int>;
	public var usedSlots:Map<Int, Int>;
};

class FullCharacter {
	public var basics:BasicFicheData;

	public var characteristics:Characteristics;
	public var characteristicsMod:Characteristics;
	public var skillRanks:Array<SkillType>;
	public var current_hp:Int;
	public var max_hp_modifier:Int;
	public var levelUpDices:Array<Int>;
	public var level:Int;

	public var secondary_class:CharacterClass;
	public var secondary_class_levels:Int;

	public var additionalClassSkills:Array<SkillType>;
	public var skillModifiers:Map<SkillType, Int>;
	public var savingThrowModifiers:Map<SavingThrow, Int>;
	public var exceptionalModifiers:Array<TemporaryModifier>;
	public var protections:Array<Protection>;
	public var weaponsByForm:IntMap<Array<Weapon>>;
	public var tempMods:Array<TemporaryModifier>;
	public var money_po:Float;
	public var money_pa:Float;
	public var money_pc:Float;
	public var bank_po:Float;
	public var inventory:Array<InventoryItem>;
	public var damageResistances:Map<DamageType, Int>;
	public var speed_mod:Int;

	public var spell_register:SpellRegister;
	public var secondary_spell_register:SpellRegister;
	public var usedPowers:Map<Int, Int>;
	public var firedWeapons:Map<Int, Bool>;
	public var favoriteMagicSchool:Null<SpellSchool>;
	public var priestDomains:Null<Array<PriestDomain>>;
	public var currentAnimalForm:Int;
	public var feats:Array<Feats>;

	var primalSizeCategory:Null<SizeCategory>;

	public function new() {
		this.skillRanks = [];
		this.current_hp = 0;
		this.levelUpDices = [];
		this.level = 1;
		this.secondary_class = null;
		this.secondary_class_levels = 0;
		this.max_hp_modifier = 0;
		this.additionalClassSkills = [];
		this.skillModifiers = new Map();
		this.savingThrowModifiers = new Map();
		this.exceptionalModifiers = [];
		this.protections = [];
		this.tempMods = [];
		this.weaponsByForm = new IntMap();
		this.inventory = [];
		this.money_po = 0;
		this.money_pa = 0;
		this.money_pc = 0;
		this.bank_po = 0;
		this.damageResistances = new Map();
		this.speed_mod = 0;
		this.spell_register = {
			spells: [],
			usedSlots: new Map(),
			lockedPreparedIndices: [],
			preparationLocked: false,
			preparedSpells: []
		};
		this.secondary_spell_register = {
			spells: [],
			usedSlots: new Map(),
			lockedPreparedIndices: [],
			preparationLocked: false,
			preparedSpells: []
		};
		this.usedPowers = new Map();
		this.firedWeapons = new Map();
		this.feats = [];
		this.currentAnimalForm = 0;
	}

	function updateHP() {
		current_hp = getMaxHitPoints();
	}

	public function processEvent(type:FicheEventType) {
		switch (type) {
			case CREATE(data):
				this.basics = data;
			case CHANGE_ALIGNEMENT(alignement):
				this.basics.alignement = alignement;
			case CHANGE_AGE(age):
				this.basics.age = age;
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
				if (weapon.shouldBeReloaded == null)
					weapon.shouldBeReloaded = weapon.name.indexOf("Arbalète") >= 0;

				if (!weaponsByForm.exists(currentAnimalForm))
					weaponsByForm.set(currentAnimalForm, []);

				weaponsByForm.get(currentAnimalForm).push(weapon);
			case REMOVE_WEAPON(index):
				weaponsByForm.get(currentAnimalForm).splice(index, 1);
				var shifted = new Map<Int, Bool>();
				for (k in firedWeapons.keys()) {
					if (k < index)
						shifted.set(k, true);
					if (k > index)
						shifted.set(k - 1, true);
				}
				firedWeapons = shifted;
			case FIRE_WEAPON(index):
				firedWeapons.set(index, true);
			case RELOAD_WEAPON(index):
				firedWeapons.remove(index);
			case LEVEL_UP(hp_dice):
				level += 1;
				hp_dice = Math.min(hp_dice, getHitDice(true)).int();
				levelUpDices.push(hp_dice);
			case ADD_NEW_CLASS(cls):
				this.secondary_class = cls;
			case LEVEL_UP_SECONDARY_CLASS(hp_dice):
				level += 1;
				secondary_class_levels += 1;
				hp_dice = Math.min(hp_dice, getHitDice(false)).int();
				levelUpDices.push(hp_dice);
			case TRAIN_SKILL(skill):
				skillRanks.push(skill);
			case DECREASE_SKILL(skill):
				skillRanks.remove(skill);
			case CHANGE_HP(amount):
				current_hp = Math.min(current_hp + amount, getMaxHitPoints()).int();
			case DAMAGE_HP(amount, damageType):
				var resistance = damageResistances.exists(damageType) ? damageResistances.get(damageType) : 0;
				current_hp -= Math.max(amount - resistance, 0).int();
			case REMOVE_DAMAGE_RESISTANCE(damageType):
				damageResistances.remove(damageType);
			case ADD_DAMAGE_RESISTANCE(damageType, amount):
				var current = damageResistances.exists(damageType) ? damageResistances.get(damageType) : 0;
				var newAmount = current + amount;
				if (newAmount <= 0)
					damageResistances.remove(damageType);
				else
					damageResistances.set(damageType, newAmount);
			case CHANGE_MAX_HP(amount):
				max_hp_modifier += amount;
			case SET_SKILL_MODIFIER(skill, mod):
				skillModifiers.set(skill, mod);
			case SET_SAVING_THROW_MODIFIER(st, mod):
				savingThrowModifiers.set(st, mod);
			case SET_SPEED_MODIFIER(mod):
				speed_mod += mod;
			case ADD_EXCEPTIONAL_MODIFIER(mod):
				exceptionalModifiers.push(mod);
			case ADD_PROTECTION(armor):
				protections.push(armor);
			case REMOVE_PROTECTION(index):
				protections.splice(index, 1);
			case ADD_TEMPORARY_MODIFIER(mod):
				tempMods.push(mod);
				if (mod.on.match(NEGATIVE_LEVEL))
					current_hp += mod.mod * 5; // mod is −1 per level, so −5 HP per level
				updateCharacts();
			case REMOVE_TEMPORARY_MODIFIER(index):
				tempMods.splice(index, 1);
				updateCharacts();
			case CHANGE_MONEY(amount):
				money_po += amount;
			case CHANGE_MONEY_PA(amount):
				money_pa += amount;
			case CHANGE_MONEY_PC(amount):
				money_pc += amount;
			case CHANGE_BANK_MONEY(amount):
				bank_po += amount;
			case ADD_INVENTORY_ITEM(item):
				inventory.push(Reflect.copy(item));
			case CHANGE_ITEM_QUANTITY(item, new_quantity):
				inventory[item].quantity = new_quantity;
			case CHANGE_ITEM_NAME(item, new_name):
				inventory[item].name = new_name;
			case CHANGE_ITEM_PRIORITY(item, priority):
				inventory[item].priority = priority;
			case REMOVE_INVENTORY_ITEM(item):
				inventory.splice(item, 1);
			case SPELL_EVENT(ADD_SPELL(spell), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;
				spellRegister.spells.push(Reflect.copy(spell));
			case SPELL_EVENT(REMOVE_SPELL(index), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;
				spellRegister.spells.splice(index, 1);
			case SPELL_EVENT(PREPARE_SPELL(spellIndex, slotLevel), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;
				if (!spellRegister.preparationLocked)
					spellRegister.preparedSpells.push({spellIndex: spellIndex, slotLevel: slotLevel});
			case SPELL_EVENT(UNPREPARE_SPELL(spellIndex), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;
				if (!spellRegister.preparationLocked) {
					var idx = -1;
					for (i in 0...spellRegister.preparedSpells.length) {
						if (spellRegister.preparedSpells[i].spellIndex == spellIndex)
							idx = i;
					}
					if (idx >= 0)
						spellRegister.preparedSpells.splice(idx, 1);
				}
			case SPELL_EVENT(ADD_SPELL_DICE(spellIndex, dice), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;
				if (spellRegister.spells[spellIndex].dices == null)
					spellRegister.spells[spellIndex].dices = [];
				spellRegister.spells[spellIndex].dices.push(dice);
			case SPELL_EVENT(REMOVE_SPELL_DICE(spellIndex, diceIndex), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;

				spellRegister.spells[spellIndex].dices.splice(diceIndex, 1);
			case SPELL_EVENT(CAST_SPELL(spellIndex), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;

				var spell = spellRegister.spells[spellIndex];
				if (spell.usesPerDay != null) {
					usedPowers.set(spellIndex, (usedPowers.exists(spellIndex) ? usedPowers.get(spellIndex) : 0) + 1);
				} else if (spell.level == 0) {
					// Cantrips are unlimited — no slot consumed
				} else if (needsSpellPreparation()) {
					var idx = -1;
					for (i in 0...spellRegister.preparedSpells.length) {
						if (spellRegister.preparedSpells[i].spellIndex == spellIndex)
							idx = i;
					}
					if (idx >= 0)
						spellRegister.preparedSpells.splice(idx, 1);
				} else {
					// Use the lowest available slot ≥ spell level
					var slots = Rules.getSpellSlots(if (mainClass) basics.characterClass else secondary_class, this);
					var slotLevel = spell.level;
					for (lvl in spell.level...10) {
						var rem = slots[lvl] - (spellRegister.usedSlots.exists(lvl) ? spellRegister.usedSlots.get(lvl) : 0);
						if (rem > 0) {
							slotLevel = lvl;
							break;
						}
					}
					spellRegister.usedSlots.set(slotLevel, (spellRegister.usedSlots.exists(slotLevel) ? spellRegister.usedSlots.get(slotLevel) : 0) + 1);
				}
			case SPELL_EVENT(EDIT_SPELL(index, spell), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;

				var edited = Reflect.copy(spell);
				edited.dices = spellRegister.spells[index].dices;
				spellRegister.spells[index] = edited;
			case SPELL_EVENT(SET_SPELL_PRIORITY(spellIndex, priority), mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;

				spellRegister.spells[spellIndex].priority = priority;
			case SPELL_EVENT(FINISH_SPELL_PREPARATION, mainClass):
				var spellRegister = if (mainClass) spell_register else secondary_spell_register;

				spellRegister.preparationLocked = true;
				spellRegister.lockedPreparedIndices = spellRegister.preparedSpells.map(p -> p.spellIndex);
			case NEW_DAY:
				for (spellRegister in [spell_register, secondary_spell_register]) {
					spellRegister.preparedSpells = [];
					spellRegister.preparationLocked = false;
					spellRegister.lockedPreparedIndices = [];
					spellRegister.usedSlots = new Map();
				}
				usedPowers = new Map();
				current_hp = Math.min(current_hp + level, getMaxHitPoints()).int();
			case SET_FAVORITE_MAGIC_SCHOOL(school):
				favoriteMagicSchool = school;
			case SET_PRIEST_DOMAIN(domain1, domain2):
				priestDomains = [domain1, domain2];
			case ENTER_ANIMAL_FORM(n):
				characteristics.str += 4;
				primalSizeCategory = basics.sizeCategory;
				basics.sizeCategory = SIZE_G;
				speed_mod += 4;
				currentAnimalForm = n;
				updateCharacts();
			case EXIT_ANIMAL_FORM:
				characteristics.str -= 4;
				basics.sizeCategory = primalSizeCategory;
				speed_mod -= 4;
				currentAnimalForm = 0;
				updateCharacts();
			case ADD_FEAT(feat):
				feats.push(feat);
		}
	}

	public function needsSpellPreparation() {
		if (secondary_class != null && Rules.needsSpellPreparation(secondary_class))
			return true;

		return Rules.needsSpellPreparation(basics.characterClass);
	}

	public function canCastSpells() {
		if (secondary_class != null && Rules.canCastSpells(secondary_class))
			return true;

		return Rules.canCastSpells(basics.characterClass);
	}

	public function getNLS() {
		// Only consider classes that can throw spells
		var levels = 0;
		if (Rules.canCastSpells(basics.characterClass))
			levels += level - secondary_class_levels;
		if (Rules.canCastSpells(secondary_class))
			levels += secondary_class_levels;

		return Std.int(Math.max(0, levels + getTempMods([NEGATIVE_LEVEL]).sum()));
	}

	private function updateCharacts() {
		characteristicsMod = cast {};
		for (i in Reflect.fields(characteristics)) {
			var value:Int = Reflect.getProperty(characteristics, i);
			var totalTempMod = getTempMods([CHARACTERISTIC(i.parseCarac())]).sum();
			var mod:Int = Std.int((value + totalTempMod) / 2) - 5;
			Reflect.setProperty(characteristicsMod, i, mod);
		}

		if (current_hp > getMaxHitPoints()) {
			current_hp = getMaxHitPoints();
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

	public function getHitDice(mainClass:Bool) {
		return switch (if (mainClass) basics.characterClass else secondary_class) {
			case MAGICIEN, ENSORCELEUR:
				6;
			case CONJURATEUR, ROUBLARD, PRETRE, ORACLE, BARDE, DRUIDE:
				8;
			case CONJURATEUR_EIDOLON_BIPED, METAMORPHE, GUERRIER, MOINE, PALADIN:
				10;
			case BARBARE:
				12;
		}
	}

	public function getMaxHitPoints() {
		var predilectionClassBonus = if (basics.usePredilectionHP) 1 else 0;
		var hd = getHitDice(true); // First level
		var total = hd + predilectionClassBonus + characteristicsMod.con;

		// Add predilection bonus and cons
		for (i in 1...getNumberHitDice()) {
			if (i >= secondary_class_levels) { // Only for primary class
				total += predilectionClassBonus;
			}
			total += characteristicsMod.con;
		}
		for (dice in levelUpDices) {
			total += dice;
		}

		total += max_hp_modifier;
		total += getTempMods([NEGATIVE_LEVEL]).sum() * 5; // each level is mod −1, so −5 HP per level

		return total;
	}
}
