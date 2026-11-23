import Protocol;

using StringTools;

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

	static public function parseCharacterGender(gender:String):CharacterGender {
		var byName = CharacterGender.createByName(gender.toUpperCase());
		if (byName != null)
			return byName;
		return null;
	}

	static public function genderToString(gender:CharacterGender):String {
		return switch (gender) {
			case MALE: "M";
			case FEMALE: "F";
		};
	}

	static public function parseCharacterRace(race:String):CharacterRace {
		var byName = CharacterRace.createByName(race.toUpperCase());
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

	static public function canBeStacked(at:ACType) {
		return switch (at) {
			case NATURAL_ARMOR_BONUS, NATURAL_ARMOR_ALTERATION_BONUS, ARMOR_BONUS, ARMOR_ALTERATION_BONUS, SHIELD_BONUS, SHIELD_ALTERATION_BONUS: false;
			case DODGE_BONUS: true;
			case DEFLECT_BONUS: false;
			case CHANCE_BONUS: false;
			case INTUITION_BONUS: false;
			case NO_TYPE: true;
		}
	}

	static public function helpsForSurprise(at:ACType) { // No dex
		return switch (at) {
			case NATURAL_ARMOR_BONUS, NATURAL_ARMOR_ALTERATION_BONUS, ARMOR_BONUS, ARMOR_ALTERATION_BONUS, SHIELD_BONUS, SHIELD_ALTERATION_BONUS: true;
			case DODGE_BONUS: false;
			case DEFLECT_BONUS: true;
			case CHANCE_BONUS: true;
			case INTUITION_BONUS: true;
			case NO_TYPE: true;
		}
	}

	static public function helpsForTouch(at:ACType) { // No armor
		return switch (at) {
			case NATURAL_ARMOR_BONUS, NATURAL_ARMOR_ALTERATION_BONUS, ARMOR_BONUS, ARMOR_ALTERATION_BONUS, SHIELD_BONUS, SHIELD_ALTERATION_BONUS: false;
			case DODGE_BONUS: true;
			case DEFLECT_BONUS: true;
			case CHANCE_BONUS: true;
			case INTUITION_BONUS: true;
			case NO_TYPE: true;
		}
	}

	static public function acTypeToString(at:ACType) {
		return switch (at) {
			case NATURAL_ARMOR_BONUS: "Bonus d'armure naturelle";
			case NATURAL_ARMOR_ALTERATION_BONUS: "Bonus d'alteration d'armure naturelle";
			case ARMOR_BONUS: "Bonus d'armure";
			case ARMOR_ALTERATION_BONUS: "Bonus d'alteration d'armure";
			case SHIELD_BONUS: "Bonus de bouclier";
			case SHIELD_ALTERATION_BONUS: "Bonus d'alteration de bouclier";
			case DODGE_BONUS: "Bonus d'esquive"; // Can be stacked
			case DEFLECT_BONUS: "Bonus de parade";
			case CHANCE_BONUS: "Bonus de chance";
			case INTUITION_BONUS: "Bonus d'intuition";
			case NO_TYPE: "Sans type (très rare)";
		}
	}

	static public function caracToString(c:Characteristic, withPrefix:Bool) {
		return switch (c) {
			case STRENGTH: if (withPrefix) "de la force" else "Force";
			case DEXTERITY: if (withPrefix) "de la dextérité" else "Dextérité";
			case WISDOM: if (withPrefix) "de la sagesse" else "Sagesse";
			case INTELLIGENCE: if (withPrefix) "de l'intelligence" else "Intelligence";
			case CHARISMA: if (withPrefix) "du charisme" else "Charisme";
			case CONSTITUTION: if (withPrefix) "de la constitution" else "Constitution";
		};
	}

	static public function classToString(cls:CharacterClass) {
		return switch (cls) {
			case ROUBLARD: "Roublard(e)";
			case BARBARE: "Barbare";
			case GUERRIER: "Guerrier(e)";
			case METAMORPHE: "Métamorphe";
			case CONJURATEUR: "Conjurateur";
			case BARDE: "Barde";
			case PALADIN: "Paladin";
			case MOINE: "Moine";
			case ENSORCELEUR: "Ensorceleur(euse)";
			case DRUIDE: "Druide";
			case CONJURATEUR_EIDOLON_BIPED: "Eidolon du Conjurateur";
			case MAGICIEN: "Magicien(ne)";
			case MELANGISTE: "Mélangiste";
			case PRETRE: "Prêtre(sse)";
			case ORACLE: "Oracle";
		}
	}

	static public function characteristicToIconPath(c:Characteristic) {
		return '/assets/icons/characs/${c.getName().toLowerCase()}.svg';
	}

	static public function classToIconPath(cls:CharacterClass) {
		var name = switch (cls) {
			case ROUBLARD: "roublard";
			case GUERRIER: "guerrier";
			case BARBARE: "barbare";
			case METAMORPHE: "metamorphe";
			case CONJURATEUR: "conjurateur";
			case ORACLE: "oracle";
			case BARDE: "barde";
			case MOINE: "moine";
			case DRUIDE: "druide";
			case PALADIN: "paladin";
			case CONJURATEUR_EIDOLON_BIPED: "eidolon_du_conjurateur";
			case MAGICIEN: "magicien";
			case MELANGISTE: "melangiste";
			case ENSORCELEUR: "ensorceleur";
			case PRETRE: "pretre";
		};
		return '/assets/icons/classes/$name.svg';
	}

	static public function sizeCategoryToString(size:SizeCategory) {
		return switch (size) {
			case SIZE_I: "I (Infime)";
			case SIZE_MIN: "M (Minuscule)";
			case SIZE_TP: "TP (Très petit)";
			case SIZE_P: "P (Petit)";
			case SIZE_M: "M (Moyen)";
			case SIZE_G: "G (Grand)";
			case SIZE_TG: "TG (Très grand)";
			case SIZE_GIG: "Gig (Giganteste)";
			case SIZE_C: "C (Colossal)";
		};
	}

	static public function damageTypeToString(dt:DamageType) {
		return switch (dt) {
			case BLUDGEONING: "Contondant";
			case PIERCING: "Perforant";
			case SLASHING: "Tranchant";
			case ACID: "Acide";
			case COLD: "Froid";
			case ELECTRICITY: "Électricité";
			case FIRE: "Feu";
			case SONIC: "Sonique";
			case FORCE: "Force";
			case POSITIVE: "Énergie positive";
			case NEGATIVE: "Énergie négative";
			case CHAOTIC: "Chaotique";
			case EVIL: "Mal";
			case GOOD: "Bien";
			case LAWFUL: "Loi";
			case UNTYPED: "Sans type";
		}
	}

	static public function raceToString(race:CharacterRace):String {
		return switch (race) {
			case HUMAN: "Humain(e)";
			case DWARF: "Nain(e)";
			case ELF: "Elfe";
			case HALF_ELF: "Demi-elfe";
			case GNOME: "Gnome";
			case HALF_ORC: "Demi-orque";
			case ANGEL: "Ange";
			case HALFELIN: "Halfelin";
		};
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

	static public function priestDomainToString(d:PriestDomain):String {
		return switch (d) {
			case AIR: "Air";
			case ANIMAL: "Animal";
			case ARTIFICE: "Artifice";
			case CHAOS: "Chaos";
			case CHARM: "Charme";
			case COMMUNITY: "Communauté";
			case DARKNESS: "Ténèbres";
			case DEATH: "Mort";
			case DESTRUCTION: "Destruction";
			case EARTH: "Terre";
			case EVIL: "Mal";
			case FIRE: "Feu";
			case GLORY: "Gloire";
			case GOOD: "Bien";
			case HEALING: "Guérison";
			case KNOWLEDGE: "Connaissance";
			case LAW: "Loi";
			case LIBERATION: "Libération";
			case LUCK: "Chance";
			case MADNESS: "Folie";
			case MAGIC: "Magie";
			case NOBILITY: "Noblesse";
			case PLANT: "Plantes";
			case PROTECTION: "Protection";
			case REPOSE: "Repos";
			case RUNE: "Rune";
			case STRENGTH: "Vigueur";
			case SUN: "Soleil";
			case TRAVEL: "Voyage";
			case TRICKERY: "Tromperie";
			case VOID: "Vide";
			case WAR: "Guerre";
			case WATER: "Eau";
			case WEATHER: "Météores";
		}
	}

	static public function spellSchoolToString(s:SpellSchool):String {
		return switch (s) {
			case ABJURATION: "Abjuration";
			case CONJURATION: "Invocation";
			case DIVINATION: "Divination";
			case ENCHANTMENT: "Enchantement";
			case EVOCATION: "Évocation";
			case ILLUSION: "Illusion";
			case NECROMANCY: "Nécromancie";
			case TRANSMUTATION: "Transmutation";
			case UNIVERSAL: "Universel";
		}
	}

	static public function spellComponentToString(c:SpellComponent):String {
		return switch (c) {
			case VERBAL: "Verbale";
			case SOMATIC: "Gestuelle";
			case MATERIAL: "Matérielle";
		}
	}

	static public function spellSaveEffectToString(e:SpellSaveEffect):String {
		return switch (e) {
			case HALF_DAMAGE: "1/2 dégâts";
			case NEGATES: "Annule";
			case REVEALS: "Dévoile";
		}
	}

	static function formulaSuffix(original:String, resolved:String):String {
		return if (resolved == original) "" else ' (${original.replace("+", " + ").replace("-", " - ").replace("*", " × ").replace("/", " / ")})';
	}

	static public function spellCastingTimeToString(ct:SpellCastingTime, ?resolveFormula:String->String):String {
		var r = resolveFormula != null ? resolveFormula : (s->s);
		return switch (ct) {
			case STANDARD_ACTION: "Action simple";
			case FULL_ACTION: "Action complexe";
			case N_ROUNDS(n): '${r(n)} round(s)${formulaSuffix(n, r(n))}';
			case N_MINUTES(n): '${r(n)} minute(s)${formulaSuffix(n, r(n))}';
		}
	}

	static public function statusToDescription(status:StatusType):String {
		return switch (status) {
			case GRAPPLED:
				"Un personnage agrippé est retenu par une créature, un piège ou un effet. Il ne peut plus bouger et subit un malus de -4 à sa Dextérité, ainsi qu'un malus de -2 à ses jets d'attaque et à ses tests de manœuvre offensive, à l'exception de ceux faits pour agripper ou se libérer d'une prise.
Il ne peut entreprendre aucune action qui nécessite ses deux mains.
S'il tente de lancer un sort ou d'utiliser un pouvoir magique, il doit réussir un test de concentration (DD 10 + BMO de l'adversaire + niveau du sort) sous peine de perdre le sort.
Il ne peut pas porter d'attaques d'opportunité ni utiliser Discrétion contre la créature qui l'agrippe.";
			case DEAFENED:
				"Un personnage sourd n'entend rien.
Il subit un malus de -4 aux tests d'initiative et de Perception opposés, et rate automatiquement les tests de Perception basés sur l'ouïe.
Il a 20 % de risques d'échec lorsqu'il lance un sort à composante verbale.
Un personnage sourd depuis longtemps s'habitue à son état et peut ignorer certains de ces inconvénients.";
			case BLINDED:
				"Un personnage aveuglé ne voit rien.
Il subit un malus de -2 à la CA et perd son bonus de Dextérité à la CA.
Il subit un malus de -4 à la plupart des tests de compétences basés sur la Force et la Dextérité, ainsi qu'aux tests de Perception opposés. Il rate automatiquement les tests et activités qui dépendent de la vue.
Tous ses adversaires bénéficient d'un camouflage total (50 % de chances de rater) contre lui.
Il doit réussir un test d'Acrobaties DD 10 pour se déplacer à plus de la moitié de sa vitesse, sous peine de tomber à terre.";
			case BLEED:
				"Une créature qui saigne perd le nombre de points de vie indiqué au début de son tour.
Un test de Premiers secours DD 15 ou tout soin magique arrête le saignement.
Les effets de saignement ne se cumulent pas entre eux, sauf s'ils infligent des types de dégâts différents. Seul le plus important s'applique.";
			case CONFUSED:
				"Une créature confuse est incapable d'agir normalement. Elle lance 1d% au début de son tour :
01-25 : elle agit normalement.
26-50 : elle ne fait rien d'autre que babiller de façon incohérente.
51-75 : elle s'inflige 1d8 + modificateur de Force avec l'objet qu'elle tient.
76-100 : elle attaque la créature la plus proche.
Une créature confuse qui est attaquée riposte contre son agresseur au tour suivant.
Elle ne peut pas porter d'attaques d'opportunité, sauf contre une créature qu'elle attaque déjà.";
			case COWERING:
				"Le personnage est paralysé par la peur et ne peut entreprendre aucune action.
Il subit un malus de -2 à la CA et perd son bonus de Dextérité à la CA.";
			case DAZED:
				"La créature hébétée ne peut pas agir normalement. Elle ne peut entreprendre aucune action, mais ne subit pas de malus à la CA.
Cet état dure généralement 1 round.";
			case DAZZLED:
				"La créature éblouie voit mal à cause d'une stimulation excessive des yeux.
Elle subit un malus de -1 aux jets d'attaque et aux tests de Perception basés sur la vue.";
			case DISABLED:
				"Le personnage est à 0 point de vie ou moins, mais il est stable et conscient.
Il ne peut accomplir qu'une action de mouvement ou une action simple par round (ni les deux, ni d'action complexe), plus des actions rapides, immédiates et libres. Il se déplace à la moitié de sa vitesse.
Toute action simple ou épuisante lui inflige 1 point de dégâts une fois terminée. Si ses points de vie deviennent alors négatifs, il est mourant.";
			case DYING:
				"Le personnage est inconscient, a des points de vie négatifs et n'est pas stabilisé. Il ne peut entreprendre aucune action.
À la fin de chacun de ses tours, il doit réussir un test de Constitution DD 10 (avec un malus égal à ses points de vie négatifs) pour se stabiliser, sinon il perd 1 point de vie.
Il meurt lorsque ses points de vie négatifs atteignent sa valeur de Constitution.";
			case ENTANGLED:
				"La créature enchevêtrée est prise au piège.
Elle se déplace à la moitié de sa vitesse, sauf si ses liens sont attachés à un objet immobile, auquel cas elle ne peut plus bouger. Elle ne peut ni courir ni charger.
Elle subit un malus de -2 aux jets d'attaque et de -4 à la Dextérité.
Pour lancer un sort, elle doit réussir un test de concentration (DD 15 + niveau du sort) sous peine de perdre le sort.";
			case EXHAUSTED:
				"Le personnage épuisé se déplace à la moitié de sa vitesse et ne peut ni courir ni charger.
Il subit un malus de -6 à la Force et à la Dextérité.
Après 1 heure de repos complet, il n'est plus que fatigué.";
			case FASCINATED:
				"La créature fascinée reste immobile, debout ou assise, et ne fait rien d'autre que prêter attention à l'effet qui la fascine.
Elle subit un malus de -4 aux tests de compétences effectués en réaction, comme la Perception.
Toute menace potentielle lui accorde un nouveau jet de sauvegarde. Une menace évidente (sort lancé, arme dégainée ou pointée vers elle) met automatiquement fin à l'effet.
Un allié peut la secouer pour la libérer par une action simple.";
			case FATIGUED:
				"Le personnage fatigué ne peut ni courir ni charger.
Il subit un malus de -2 à la Force et à la Dextérité.
Toute action qui devrait le fatiguer le rend épuisé.
Après 8 heures de repos complet, il n'est plus fatigué.";
			case FRIGHTENED:
				"La créature effrayée fuit la source de sa peur du mieux possible. Si elle ne peut pas fuir, elle peut combattre.
Elle subit un malus de -2 aux jets d'attaque, aux jets de sauvegarde, aux tests de compétences et aux tests de caractéristiques.
Elle peut utiliser ses pouvoirs spéciaux, sorts compris, pour fuir, et doit le faire si c'est le seul moyen de s'échapper.";
			case HELPLESS:
				"Le personnage sans défense (paralysé, ligoté, endormi, inconscient…) est à la merci de ses adversaires.
Sa Dextérité est considérée comme égale à 0 (-5).
Les attaques au corps à corps contre lui bénéficient d'un bonus de +4, mais les attaques à distance n'ont pas de bonus. Il est vulnérable aux attaques sournoises.
Un adversaire adjacent peut lui porter un coup de grâce par une action complexe, qui provoque des attaques d'opportunité.";
			case INVISIBLE:
				"La créature invisible est visuellement indétectable.
Elle bénéficie d'un bonus de +2 aux jets d'attaque contre les adversaires qui ne la voient pas, et ceux-ci perdent leur bonus de Dextérité à la CA contre elle.";
			case NAUSEATED:
				"La créature nauséeuse souffre de nausées.
Elle ne peut ni attaquer, ni lancer de sorts, ni se concentrer sur un sort, ni faire quoi que ce soit qui demande de l'attention.
Elle ne peut accomplir qu'une seule action de mouvement par tour.";
			case PANICKED:
				"La créature paniquée lâche tout ce qu'elle tient et fuit au maximum de sa vitesse la source de sa peur, en suivant un trajet aléatoire. Elle ne peut entreprendre aucune autre action.
Elle subit un malus de -2 aux jets de sauvegarde, aux tests de compétences et aux tests de caractéristiques.
Si elle est acculée, elle se recroqueville sur elle-même et n'attaque pas (généralement en défense totale).
Elle peut utiliser ses pouvoirs, sorts compris, pour fuir.";
			case PARALYZED:
				"La créature paralysée est figée sur place et incapable de bouger ou d'agir.
Sa Force et sa Dextérité sont considérées comme égales à 0. Elle est sans défense, mais peut entreprendre des actions purement mentales.
Une créature ailée en vol tombe. Une créature qui nage risque de se noyer.
Il est possible de traverser son espace, mais chaque case qu'elle occupe compte double.";
			case PETRIFIED:
				"Le personnage pétrifié est changé en pierre et considéré comme inconscient.
Si sa statue se brise, les morceaux recollés lui permettent de retrouver son corps de chair indemne.
S'il manque des morceaux, le corps reste incomplet et des dégâts permanents sont possibles (à l'appréciation du MJ).";
			case PINNED:
				"Le personnage immobilisé est fermement maintenu. Il ne peut pas bouger, perd son bonus de Dextérité à la CA et subit un malus supplémentaire de -4 à la CA.
Il peut tenter de se libérer par un test de manœuvre offensive ou d'Évasion.
Il peut entreprendre des actions verbales et mentales, mais ne peut pas lancer de sorts à composante gestuelle ou matérielle. Pour lancer un sort, il doit réussir un test de concentration (DD 10 + BMO de l'adversaire + niveau du sort).
Cet état remplace l'état agrippé et ne s'y cumule pas.";
			case PRONE:
				"Le personnage est allongé au sol.
Il subit un malus de -4 aux jets d'attaque au corps à corps et ne peut pas utiliser d'arme à distance, sauf une arbalète.
Il bénéficie d'un bonus de +4 à la CA contre les attaques à distance, mais subit un malus de -4 à la CA contre les attaques au corps à corps.
Se relever est une action de mouvement qui provoque des attaques d'opportunité.";
			case SHAKEN:
				"Le personnage secoué subit un malus de -2 aux jets d'attaque, aux jets de sauvegarde, aux tests de compétences et aux tests de caractéristiques.";
			case SICKENED:
				"Le personnage fiévreux subit un malus de -2 aux jets d'attaque, aux jets de dégâts des armes, aux jets de sauvegarde, aux tests de compétences et aux tests de caractéristiques.";
			case STAGGERED:
				"La créature chancelante ne peut accomplir qu'une action de mouvement ou une action simple par round (ni les deux, ni d'action complexe).
Elle peut toujours entreprendre des actions libres, rapides et immédiates.
Une créature dont les dégâts non létaux égalent exactement ses points de vie actuels est chancelante.";
			case STUNNED:
				"La créature étourdie lâche tout ce qu'elle tient et ne peut entreprendre aucune action.
Elle subit un malus de -2 à la CA et perd son bonus de Dextérité à la CA.";
		}
	}

	static public function statusToString(status:StatusType):String {
		return switch (status) {
			case GRAPPLED: "Agrippé";
			case DEAFENED: "Sourd";
			case BLINDED: "Aveuglé";
			case BLEED: "Saignement";
			case CONFUSED: "Confus";
			case COWERING: "Recroquevillé";
			case DAZED: "Hébété";
			case DAZZLED: "Ébloui";
			case DISABLED: "Hors de combat";
			case DYING: "Mourant";
			case ENTANGLED: "Enchevêtré";
			case EXHAUSTED: "Épuisé";
			case FASCINATED: "Fasciné";
			case FATIGUED: "Fatigué";
			case FRIGHTENED: "Effrayé";
			case HELPLESS: "Sans défense";
			case INVISIBLE: "Invisible";
			case NAUSEATED: "Nauséeux";
			case PANICKED: "Paniqué";
			case PARALYZED: "Paralysé";
			case PETRIFIED: "Pétrifié";
			case PINNED: "Immobilisé";
			case PRONE: "À terre";
			case SHAKEN: "Secoué";
			case SICKENED: "Fiévreux";
			case STAGGERED: "Chancelant";
			case STUNNED: "Étourdi";
		};
	}

	static public function spellDurationToString(d:SpellDuration, ?resolveFormula:String->String):String {
		var r = resolveFormula != null ? resolveFormula : (s->s);
		return switch (d) {
			case INSTANTANEOUS: "Instantanée";
			case N_ROUNDS(n): '${r(n)} round(s)${formulaSuffix(n, r(n))}';
			case N_MINUTES(n):
				var resolved = r(n);
				var mins = Std.parseInt(resolved);
				var display = if (mins != null && mins >= 120) {
					var hours = mins / 60;
					var hoursStr = hours == Std.int(hours) ? Std.string(Std.int(hours)) : Std.string(hours);
					'$hoursStr heure${if (hours > 1) "s" else ""}';
				} else {
					'$resolved minute(s)';
				};
				'$display${formulaSuffix(n, resolved)}';
			case CONCENTRATION: "Concentration";
		}
	}

	static public function spellRangeToString(range:SpellRange, ?resolveFormula:String->String, ?nls:Int):String {
		var r = resolveFormula != null ? resolveFormula : (s->s);
		return switch (range) {
			case PERSONAL: "Personnelle";
			case TOUCH: "Contact";
			case CLOSE: nls != null ? 'Courte (${5 + Std.int(nls / 2)} cases)' : "Courte";
			case MEDIUM: nls != null ? 'Moyenne (${20 + 2 * nls} cases)' : "Moyenne";
			case LONG: nls != null ? 'Longue (${80 + 8 * nls} cases)' : "Longue";
			case SPECIFIC(cases): '${r(cases)} case(s)${formulaSuffix(cases, r(cases))}';
		}
	}

	static public function spellDiceTypeToString(t:SpellDiceType):String {
		return switch (t) {
			case CARACTERISTIC(c): caracToString(c, false);
			case CONTACT_MELEE: "Contact au corps à corps";
			case CONTACT_RANGED: "Contact à distance";
			case NLS: "NLS";
			case MANUAL(formula): formula;
		}
	}
}
