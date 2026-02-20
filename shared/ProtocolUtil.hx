import Protocol;

class ProtocolUtil {
	static public function parseCharacterAlignement(align:String):CharacterAlignement {
		var byName = CharacterAlignement.createByName("ALIGNEMENT_" + align.toUpperCase());
		if (byName != null)
			return byName;
		return null;
	}

	static public function parseCharacterClass(charClass:String):CharacterClass {
		var byName = CharacterClass.createByName(charClass.toUpperCase());
		if (byName != null)
			return byName;
		return null;
	}

	static public function parseSizeCategory(size:String):SizeCategory {
		var byName = SizeCategory.createByName("SIZE_" + size.toUpperCase());
		if (byName != null)
			return byName;
		return null;
	}

	static public function parseCarac(c:String):Characteristic {
		return if (c == "str") STRENGTH else if (c == "dex") DEXTERITY else if (c == "wis") WISDOM else if (c == "int") INTELLIGENCE else if (c == "cha")
			CHARISMA else if (c == "con") CONSTITUTION else null;
	}

	static public function savingThrowToString(st:SavingThrow) {
		return switch (st) {
			case REFLEXES: "Réflexes";
			case WILL: "Volonté";
			case VIGOR: "Vigueur";
		}
	}

	static public function caracToString(c:Characteristic, withPrefix:Bool) {
		return switch (c) {
			case STRENGTH: if (withPrefix) "de la force" else "force";
			case DEXTERITY: if (withPrefix) "de la dextérité" else "dextérité";
			case WISDOM: if (withPrefix) "de la sagesse" else "sagesse";
			case INTELLIGENCE: if (withPrefix) "de l'intelligence" else "intelligence";
			case CHARISMA: if (withPrefix) "du charisme" else "charisme";
			case CONSTITUTION: if (withPrefix) "de la constitution" else "constitution";
		};
	}

	static public function classToString(cls:CharacterClass) {
		return switch (cls) {
			case ROUBLARD:
				"Roublard(e)";
			case CONJURATEUR:
				"Conjurateur";
		}
	}

	static public function sizeCategoryToString(size:SizeCategory) {
		return size.getName().split("_")[1];
	}

	static public function alignementToString(alignement:CharacterAlignement) {
		return switch (alignement) {
			case ALIGNEMENT_LB: "Loyal/Bon";
			case ALIGNEMENT_NB: "Neutre/Bon";
			case ALIGNEMENT_CB: "Chaotique/Bon";
			case ALIGNEMENT_LN: "Loyal/Neutre";
			case ALIGNEMENT_N: "Neutre";
			case ALIGNEMENT_LM: "Loyal/Mauvais";
			case ALIGNEMENT_NM: "Neutre/Mauvais";
			case ALIGNEMENT_CM: "Chaotique/Mauvais";
		}
	}
}
