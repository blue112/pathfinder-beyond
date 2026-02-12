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

	static public function classToString(cls:CharacterClass) {
		return switch (cls) {
			case ROUBLARD:
				"Roublard(e)";
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
