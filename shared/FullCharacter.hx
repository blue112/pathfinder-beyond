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
    public var savingThrowModifiers:Map<SavingThrow, Int>;
    public var exceptionalModifiers:Array<TemporaryModifier>;
    public var protections:Array<Protection>;
    public var weapons:Array<Weapon>;
    public var tempMods:Array<TemporaryModifier>;
    public var money_po:Float;
    public var bank_po:Float;
    public var inventory:Array<InventoryItem>;
    public var damageResistances:Map<DamageType, Int>;
    public var speed_mod:Int;
    public var spells:Array<Spell>;
    public var preparedSpells:Array<PreparedSpell>;
    public var preparationLocked:Bool;

    public function new() {
        this.skillRanks = [];
        this.current_hp = 0;
        this.levelUpDices = [];
        this.level = 1;
        this.max_hp_modifier = 0;
        this.additionalClassSkills = [];
        this.skillModifiers = new Map();
        this.savingThrowModifiers = new Map();
        this.exceptionalModifiers = [];
        this.protections = [];
        this.tempMods = [];
        this.weapons = [];
        this.inventory = [];
        this.money_po = 0;
        this.bank_po = 0;
        this.damageResistances = new Map();
        this.speed_mod = 0;
        this.spells = [];
        this.preparedSpells = [];
        this.preparationLocked = false;
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
            case REMOVE_WEAPON(index):
                weapons.splice(index, 1);
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
                updateCharacts();
            case REMOVE_TEMPORARY_MODIFIER(index):
                tempMods.splice(index, 1);
                updateCharacts();
            case CHANGE_MONEY(amount):
                money_po += amount;
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
            case ADD_SPELL(spell):
                spells.push(Reflect.copy(spell));
            case REMOVE_SPELL(index):
                spells.splice(index, 1);
            case PREPARE_SPELL(spellIndex, slotLevel):
                if (!preparationLocked) preparedSpells.push({spellIndex: spellIndex, slotLevel: slotLevel});
            case UNPREPARE_SPELL(spellIndex):
                if (!preparationLocked) {
                    var idx = -1;
                    for (i in 0...preparedSpells.length) {
                        if (preparedSpells[i].spellIndex == spellIndex) idx = i;
                    }
                    if (idx >= 0) preparedSpells.splice(idx, 1);
                }
            case FINISH_SPELL_PREPARATION:
                preparationLocked = true;
            case NEW_DAY:
                preparedSpells = [];
                preparationLocked = false;
                current_hp = Math.min(current_hp + level, getMaxHitPoints()).int();
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
            case MAGICIEN:
                6;
            case CONJURATEUR, ROUBLARD, PRETRE:
                8;
            case CONJURATEUR_EIDOLON_BIPED, METAMORPHE:
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
