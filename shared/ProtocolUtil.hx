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
            case METAMORPHE: "Métamorphe";
            case CONJURATEUR: "Conjurateur";
            case CONJURATEUR_EIDOLON_BIPED: "Eidolon du Conjurateur";
            case MAGICIEN: "Magicien(ne)";
            case PRETRE: "Prêtre(sse)";
        }
    }

    static public function characteristicToIconPath(c:Characteristic) {
        return '/assets/icons/characs/${c.getName().toLowerCase()}.svg';
    }

    static public function classToIconPath(cls:CharacterClass) {
        var name = switch (cls) {
            case ROUBLARD: "roublard";
            case METAMORPHE: "metamorphe";
            case CONJURATEUR: "conjurateur";
            case CONJURATEUR_EIDOLON_BIPED: "eidolon_du_conjurateur";
            case MAGICIEN: "magicien";
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

    static public function spellCastingTimeToString(ct:SpellCastingTime):String {
        return switch (ct) {
            case STANDARD_ACTION: "Action simple";
            case FULL_ACTION: "Action complexe";
            case N_ROUNDS(n): '${n} round(s)';
            case N_MINUTES(n): '${n} minute(s)';
        }
    }

    static public function spellDurationToString(d:SpellDuration):String {
        return switch (d) {
            case INSTANTANEOUS: "Instantanée";
            case N_ROUNDS(n): '${n} round(s)';
            case N_MINUTES(n): '${n} minute(s)';
            case CONCENTRATION: "Concentration";
        }
    }

    static public function spellRangeToString(r:SpellRange):String {
        return switch (r) {
            case PERSONAL: "Personnelle";
            case TOUCH: "Contact";
            case CLOSE: "Courte";
            case MEDIUM: "Moyenne";
            case LONG: "Longue";
            case SPECIFIC(cases): '${cases} case(s)';
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
