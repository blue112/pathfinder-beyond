import js.html.Element;
import RulesSkills.SkillType;
import Protocol;

using Rules;
using Lambda;

class Rules {
    static public function canCastSpells(cls:CharacterClass):Bool {
        return switch (cls) {
            case CONJURATEUR | MAGICIEN | PRETRE: true;
            case CONJURATEUR_EIDOLON_BIPED | ROUBLARD | METAMORPHE: false;
        };
    }

    static public function needsSpellPreparation(cls:CharacterClass):Bool {
        return switch (cls) {
            case MAGICIEN | PRETRE: true;
            case CONJURATEUR | CONJURATEUR_EIDOLON_BIPED | ROUBLARD | METAMORPHE: false;
        };
    }

    // Returns the primary casting ability modifier for a preparation caster.
    static public function getCastingModifier(cls:CharacterClass, char:FullCharacter):Int {
        return switch (cls) {
            case MAGICIEN: char.characteristicsMod.int;
            case PRETRE: char.characteristicsMod.wis;
            case CONJURATEUR: char.characteristicsMod.cha;
            case CONJURATEUR_EIDOLON_BIPED | ROUBLARD | METAMORPHE: 0;
        };
    }

    static public function getRacialSpellDCBonus(race:CharacterRace, school:SpellSchool):Int {
        if (race == GNOME && school == ILLUSION) return 1;
        return 0;
    }

    // Returns bonus spell slots from a high casting ability.
    // Pattern per spell level (1-9): floor((mod - level) / 4) + 1 when mod >= level, else 0.
    // Level 0 (cantrips) never gets a bonus.
    static public function getBonusSpellSlots(mod:Int):Array<Int> {
        return [for (level in 0...10) if (level == 0 || mod < level) 0 else Std.int((mod - level) / 4) + 1];
    }

    // Base spell slots for preparation casters (Magicien/Pretre): spell level (0–9) × char level (1–20).
    static var spellSlotBase = [
        [3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], // L0
        [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], // L1
        [0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], // L2
        [0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], // L3
        [0, 0, 0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4], // L4
        [0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4], // L5
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4], // L6
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4], // L7
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 3, 3, 4], // L8
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4], // L9
    ];

    // Base spell slots for the Conjurateur (6-level spontaneous caster, PF1e Summoner table).
    static var spellSlotBaseConjurateur = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // L0
        [1, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5], // L1
        [0, 0, 0, 1, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5], // L2
        [0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5], // L3
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5], // L4
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 4, 4, 5, 5], // L5
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5], // L6
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // L7
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // L8
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // L9
    ];

    static function getBaseSlots(cls:CharacterClass, charIdx:Int):Array<Int> {
        return switch (cls) {
            case MAGICIEN | PRETRE: [for (L in 0...10) spellSlotBase[L][charIdx]];
            case CONJURATEUR: [for (L in 0...10) spellSlotBaseConjurateur[L][charIdx]];
            case CONJURATEUR_EIDOLON_BIPED | ROUBLARD | METAMORPHE: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        };
    }

    // Returns the highest spell level the character has base slots for (ignoring ability bonuses).
    static public function getMaxSpellLevel(cls:CharacterClass, char:FullCharacter):Int {
        var base = getBaseSlots(cls, char.level - 1);
        var max = 0;
        for (L in 0...10) if (base[L] > 0) max = L;
        return max;
    }

    // Returns total spell slots per spell level (indices 0–9), including ability bonus.
    // Bonus slots for levels not yet unlocked are folded into the highest unlocked level.
    static public function getSpellSlots(cls:CharacterClass, char:FullCharacter):Array<Int> {
        if (!canCastSpells(cls)) return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        var bonus = getBonusSpellSlots(getCastingModifier(cls, char));
        var slots = getBaseSlots(cls, char.level - 1);
        var maxLevel = getMaxSpellLevel(cls, char);
        for (L in 0...10) {
            if (slots[L] > 0) {
                slots[L] += bonus[L];
            } else if (bonus[L] > 0) {
                slots[maxLevel] += bonus[L];
            }
        }
        if (cls == MAGICIEN && char.favoriteMagicSchool != null) {
            for (L in 1...10) {
                if (slots[L] > 0) slots[L]++;
            }
        }
        return slots;
    }

    static var bbaTables = [
        ROUBLARD => [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15],
        CONJURATEUR => [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15],
        METAMORPHE => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        CONJURATEUR_EIDOLON_BIPED => [1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15, 15],
        MAGICIEN => [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10],
        PRETRE => [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15],
    ];
    static var savingThrowTables = [
        ROUBLARD => [
            WILL => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            VIGOR => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            REFLEXES => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
        ],
        MAGICIEN => [
            REFLEXES => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            VIGOR => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            WILL => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
        ],
        PRETRE => [
            REFLEXES => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            VIGOR => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
            WILL => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
        ],
        METAMORPHE => [
            WILL => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            REFLEXES => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
            VIGOR => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
        ],
        CONJURATEUR => [
            WILL => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12],
            REFLEXES => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
            VIGOR => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
        ],
        CONJURATEUR_EIDOLON_BIPED => [
            WILL => [2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9],
            REFLEXES => [0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5],
            VIGOR => [2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9],
        ]
    ];

    static public function getSkillRank(char:FullCharacter, skill:SkillType) {
        return char.skillRanks.count(n -> n == skill);
    }

    static public function getCaracMod(char:FullCharacter, carac:Characteristic) {
        return switch (carac) {
            case STRENGTH: char.characteristicsMod.str;
            case INTELLIGENCE: char.characteristicsMod.int;
            case DEXTERITY: char.characteristicsMod.dex;
            case WISDOM: char.characteristicsMod.wis;
            case CHARISMA: char.characteristicsMod.cha;
            case CONSTITUTION: char.characteristicsMod.con;
        }
    }

    static public function isClassSkill(char:FullCharacter, skill:SkillType) {
        return RulesSkills.getSkill(skill).classSkillFor.contains(char.basics.characterClass);
    }

    static public function getSkillsMods(char:FullCharacter) {
        var armorPenalty = char.protections.filter(p -> (p.type == ARMOR || p.type == SHIELD)
            && p.armorMalus != null).fold((p, acc) -> acc + p.armorMalus, 0);

        return RulesSkills.skills.map(n -> {
            var ranks = char.getSkillRank(n.name);
            var classSkill = isClassSkill(char, n.name) || char.additionalClassSkills.contains(n.name);
            var specialMod = 0;
            if (n.name.match(DISCRETION) && char.basics.sizeCategory.match(SIZE_P)) {
                specialMod = 4;
            }
            var canUse = !n.needTraining || ranks > 0;
            var charMod = char.skillModifiers.get(n.name);
            if (charMod == null)
                charMod = 0;
            var armorMod = if (n.modifier == DEXTERITY || n.modifier == STRENGTH) armorPenalty else 0;

            return {
                id: n.name.getName().toLowerCase(),
                name: n.name,
                label: n.label,
                classSkill: classSkill,
                characteristic: n.modifier,
                ranks: ranks,
                canUse: canUse,
                mod: if (!canUse) 0 else char.getCaracMod(n.modifier) + ranks + (if (classSkill && ranks > 0) 3 else 0) + specialMod + charMod + armorMod
            };
        });
    }

    static public function getBMO(char:FullCharacter) {
        return getBBA(char) + char.characteristicsMod.str + getSizeMod(char, true);
    }

    static public function getDMD(char:FullCharacter) {
        return 10 + getBBA(char) + char.characteristicsMod.str + char.characteristicsMod.dex + getSizeMod(char, true);
    }

    static public function getBBA(char:FullCharacter) {
        return bbaTables.get(char.basics.characterClass)[char.level - 1];
    }

    static public function getSavingThrowCarac(st:SavingThrow) {
        return switch (st) {
            case REFLEXES: DEXTERITY;
            case VIGOR: CONSTITUTION;
            case WILL: WISDOM;
        }
    }

    static public function sum(tempMod:Array<TemporaryModifier>) {
        return tempMod.fold((t, r) -> t.mod + r, 0);
    }

    static public function applyTempModsClass(character:FullCharacter, div:Element, matching:Array<Field>) {
        var tempMod = character.getTempMods(matching).sum();
        if (tempMod != 0)
            div.classList.add("temp-mod");
        else
            div.classList.remove("temp-mod");
        if (tempMod < 0)
            div.classList.add("negative");
        else
            div.classList.remove("negative");
    }

    static public function getSavingThrowMod(char:FullCharacter, st:SavingThrow) {
        var baseBonus = savingThrowTables.get(char.basics.characterClass).get(st)[char.level - 1];
        var permanentMod = if (char.savingThrowModifiers.exists(st)) char.savingThrowModifiers.get(st) else 0;
        return getCaracMod(char, getSavingThrowCarac(st)) + baseBonus + permanentMod;
    }

    static public function getSizeMod(char:FullCharacter, forBMOOrDMD:Bool) {
        var sizeMod = switch (char.basics.sizeCategory) {
            case SIZE_I: 8;
            case SIZE_MIN: 4;
            case SIZE_TP: 2;
            case SIZE_P: 1;
            case SIZE_M: 0;
            case SIZE_G: -1;
            case SIZE_TG: -2;
            case SIZE_GIG: -4;
            case SIZE_C: -8;
        }
        if (forBMOOrDMD)
            return -sizeMod;
        return sizeMod;
    }

    static public function getAC(char:FullCharacter, includeArmor:Bool = true, includeDex:Bool = true) {
        var sizeMod = getSizeMod(char, false);

        var total = 10;
        total += sizeMod; // Always
        total += char.protections.filter(f -> f.type == ARMOR_BONUS).fold((i, r) -> r + i.armor, 0);
        if (includeDex) {
            total += char.characteristicsMod.dex;
            total += char.protections.filter(f -> f.type == EVADE).fold((i, r) -> r + i.armor, 0);
        }

        if (includeArmor) {
            total += char.protections.filter(f -> f.type == ARMOR || f.type == SHIELD || f.type == NATURAL_ARMOR).fold((i, r) -> r + i.armor, 0);
        }

        return total;
    }

    static public function getACSurprise(char:FullCharacter) {
        // Remove dex
        return getAC(char, true, false);
    }

    static public function getACContact(char:FullCharacter) {
        // Remove armor and shield
        return getAC(char, false, true);
    }

    static public function getVD(char:FullCharacter) {
        // Todo, heavy armor
        // https://www.pathfinder-fr.org/Wiki/Pathfinder-RPG.Valeurs%20de%20combat.ashx#VITESSEDEDEPLACEMENT
        var base = if (char.basics.race.match(DWARF)) 4 else switch (char.basics.sizeCategory) {
            case SIZE_M: 6;
            case SIZE_P: 4;
            default: 6;
        };
        return base + char.speed_mod;
    }

    static public function dice(faces:Int) {
        return Std.random(faces) + 1;
    }
}
