import RulesSkills.SkillType;
import Protocol;

using Rules;
using Lambda;

class Rules {
	static var bbaTables = [ROUBLARD => [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15],];
	static var savingThrowTables = [
		ROUBLARD => [
			WILL => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6],
			VIGOR => [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6],
			REFLEXES => [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 1, 1, 12],
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
		return RulesSkills.skills.map(n -> {
			var ranks = char.getSkillRank(n.name);
			var classSkill = isClassSkill(char, n.name) || char.additionalClassSkills.contains(n.name);
			var canUse = !n.needTraining || ranks > 0;
			return {
				id: n.name.getName().toLowerCase(),
				name: n.name,
				label: n.label,
				classSkill: classSkill,
				ranks: ranks,
				canUse: canUse,
				mod: if (!canUse) 0 else char.getCaracMod(n.modifier) + ranks + (if (classSkill && ranks > 0) 3 else 0)
			}
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

	static public function getSavingThrowMod(char:FullCharacter, st:SavingThrow) {
		var baseBonus = savingThrowTables.get(char.basics.characterClass).get(st)[char.level - 1];
		return switch (st) {
			case REFLEXES: char.characteristicsMod.dex + baseBonus;
			case VIGOR: char.characteristicsMod.con + baseBonus;
			case WILL: char.characteristicsMod.wis + baseBonus;
		}
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
		if (includeDex) {
			total += char.characteristicsMod.dex;
		}

		// Fixme bonus armure, bonus bouclier
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
		return switch (char.basics.sizeCategory) {
			case SIZE_M: 6;
			case SIZE_P: 4;
			default: 6;
		}
	}

	static public function getHitDice(cls:CharacterClass) {
		return switch (cls) {
			case ROUBLARD:
				8;
		}
	}

	static public function getMaxHitPoints(char:FullCharacter) {
		var predilectionClassBonus = 1;
		var hd = getHitDice(char.basics.characterClass);
		var total = hd + predilectionClassBonus;

		// Add predilection bonus and cons
		for (i in 1...char.level) {
			total += predilectionClassBonus + char.characteristicsMod.con;
		}
		for (dice in char.levelUpDices) {
			total += dice;
		}

		total += char.max_hp_modifier;

		return total;
	}

	static public function dice(faces:Int) {
		return Std.random(faces) + 1;
	}
}
