import Protocol.CharacterClass;
import Protocol.Characteristic;

using Lambda;

typedef RuleSkill = {
    name:SkillType,
    label:String,
    modifier:Characteristic,
    needTraining:Bool,
    classSkillFor:Array<CharacterClass>,
};

enum SkillType {
    ACROBATIES;
    ART_DE_LA_MAGIE;
    ARTISANAT;
    BLUFF;
    CONNAISSANCE_EXPLORATION;
    CONNAISSANCE_FOLFKLORE_LOCAL;
    CONNAISSANCE_GEOGRAPHIE;
    CONNAISSANCE_HISTOIRE;
    CONNAISSANCE_INGENIERIE;
    CONNAISSANCE_MYSTERES;
    CONNAISSANCE_NATURE;
    CONNAISSANCE_NOBLESSE;
    CONNAISSANCE_PLANS;
    CONNAISSANCE_RELIGION;
    DEGUISEMENT;
    DIPLOMATIE;
    DISCRETION;
    DRESSAGE;
    EQUITATION;
    ESCALADE;
    ESCAMOTAGE;
    ESTIMATION;
    EVASION;
    INTIMIDATION;
    LINGUISTIQUE;
    NATATION;
    PERCEPTION;
    PREMIERS_SECOURS;
    PROFESSION;
    PSYCHOLOGIE;
    REPRESENTATION;
    SABOTAGE;
    SURVIE;
    UTILISATION_OBJETS_MAGIQUES;
    VOL;
}

class RulesSkills {
    static public var skills:Array<RuleSkill> = [
        {
            name: ACROBATIES,
            label: "Acrobaties",
            modifier: DEXTERITY,
            needTraining: false,
            classSkillFor: [ROUBLARD, METAMORPHE],
        },
        {
            name: ART_DE_LA_MAGIE,
            label: "Art de la magie",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN, PRETRE],
        },
        {
            name: ARTISANAT,
            label: "Artisanat",
            modifier: INTELLIGENCE,
            needTraining: false,
            classSkillFor: [ROUBLARD, CONJURATEUR, CONJURATEUR_EIDOLON_BIPED, MAGICIEN, PRETRE],
        },
        {
            name: BLUFF,
            label: "Bluff",
            modifier: CHARISMA,
            needTraining: false,
            classSkillFor: [ROUBLARD, CONJURATEUR_EIDOLON_BIPED],
        },
        {
            name: CONNAISSANCE_EXPLORATION,
            label: "Connaissance (Exploration)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [ROUBLARD, CONJURATEUR, MAGICIEN],
        },
        {
            name: CONNAISSANCE_FOLFKLORE_LOCAL,
            label: "Connaissance (Folfklore Local)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [ROUBLARD, CONJURATEUR, MAGICIEN],
        },
        {
            name: CONNAISSANCE_GEOGRAPHIE,
            label: "Connaissance (Géographie)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN],
        },
        {
            name: CONNAISSANCE_HISTOIRE,
            label: "Connaissance (Histoire)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN, PRETRE],
        },
        {
            name: CONNAISSANCE_INGENIERIE,
            label: "Connaissance (Ingénierie)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN],
        },
        {
            name: CONNAISSANCE_MYSTERES,
            label: "Connaissance (Mystères)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN, PRETRE],
        },
        {
            name: CONNAISSANCE_NATURE,
            label: "Connaissance (Nature)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, METAMORPHE, MAGICIEN],
        },
        {
            name: CONNAISSANCE_NOBLESSE,
            label: "Connaissance (Noblesse)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN, PRETRE],
        },
        {
            name: CONNAISSANCE_PLANS,
            label: "Connaissance (Plans)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, CONJURATEUR_EIDOLON_BIPED, MAGICIEN, PRETRE],
        },
        {
            name: CONNAISSANCE_RELIGION,
            label: "Connaissance (Religion)",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [CONJURATEUR, MAGICIEN, PRETRE],
        },
        {
            name: DEGUISEMENT,
            label: "Déguisement",
            modifier: CHARISMA,
            needTraining: false,
            classSkillFor: [ROUBLARD],
        },
        {
            name: DIPLOMATIE,
            label: "Diplomatie",
            modifier: CHARISMA,
            needTraining: false,
            classSkillFor: [ROUBLARD, PRETRE],
        },
        {
            name: DISCRETION,
            label: "Discrétion",
            modifier: DEXTERITY,
            needTraining: false,
            classSkillFor: [ROUBLARD, CONJURATEUR_EIDOLON_BIPED, METAMORPHE],
        },
        {
            name: DRESSAGE,
            label: "Dressage",
            modifier: CHARISMA,
            needTraining: true,
            classSkillFor: [CONJURATEUR, METAMORPHE],
        },
        {
            name: EQUITATION,
            label: "Équitation",
            modifier: DEXTERITY,
            needTraining: false,
            classSkillFor: [CONJURATEUR, METAMORPHE],
        },
        {
            name: ESCALADE,
            label: "Escalade",
            modifier: STRENGTH,
            needTraining: false,
            classSkillFor: [ROUBLARD, METAMORPHE],
        },
        {
            name: ESCAMOTAGE,
            label: "Escamotage",
            modifier: DEXTERITY,
            needTraining: true,
            classSkillFor: [ROUBLARD],
        },
        {
            name: ESTIMATION,
            label: "Estimation",
            modifier: INTELLIGENCE,
            needTraining: false,
            classSkillFor: [ROUBLARD, MAGICIEN, PRETRE],
        },
        {
            name: EVASION,
            label: "Évasion",
            modifier: DEXTERITY,
            needTraining: false,
            classSkillFor: [ROUBLARD],
        },
        {
            name: INTIMIDATION,
            label: "Intimidation",
            modifier: CHARISMA,
            needTraining: false,
            classSkillFor: [ROUBLARD],
        },
        {
            name: LINGUISTIQUE,
            label: "Linguistique",
            modifier: INTELLIGENCE,
            needTraining: true,
            classSkillFor: [ROUBLARD, CONJURATEUR, MAGICIEN, PRETRE],
        },
        {
            name: NATATION,
            label: "Natation",
            modifier: STRENGTH,
            needTraining: false,
            classSkillFor: [ROUBLARD, METAMORPHE],
        },
        {
            name: PERCEPTION,
            label: "Perception",
            modifier: WISDOM,
            needTraining: false,
            classSkillFor: [ROUBLARD, CONJURATEUR_EIDOLON_BIPED, METAMORPHE],
        },
        {
            name: PREMIERS_SECOURS,
            label: "Premiers secours",
            modifier: WISDOM,
            needTraining: false,
            classSkillFor: [PRETRE],
        },
        {
            name: PROFESSION,
            label: "Profession",
            modifier: WISDOM,
            needTraining: true,
            classSkillFor: [ROUBLARD, CONJURATEUR, MAGICIEN],
        },
        {
            name: PSYCHOLOGIE,
            label: "Psychologie",
            modifier: WISDOM,
            needTraining: false,
            classSkillFor: [ROUBLARD, CONJURATEUR_EIDOLON_BIPED, PRETRE],
        },
        {
            name: REPRESENTATION,
            label: "Représentation",
            modifier: CHARISMA,
            needTraining: false,
            classSkillFor: [ROUBLARD],
        },
        {
            name: SABOTAGE,
            label: "Sabotage",
            modifier: DEXTERITY,
            needTraining: true,
            classSkillFor: [ROUBLARD],
        },
        {
            name: SURVIE,
            label: "Survie",
            modifier: WISDOM,
            needTraining: false,
            classSkillFor: [METAMORPHE],
        },
        {
            name: UTILISATION_OBJETS_MAGIQUES,
            label: "Utilisation d'objets magiques",
            modifier: CHARISMA,
            needTraining: true,
            classSkillFor: [ROUBLARD, CONJURATEUR],
        },
        {
            name: VOL,
            label: "Vol",
            modifier: DEXTERITY,
            needTraining: false,
            classSkillFor: [CONJURATEUR, METAMORPHE, MAGICIEN],
        },
    ];

    static public function getSkill(skill:SkillType) {
        return skills.find(s -> s.name == skill);
    }

    static public function getSkillLabel(skill:SkillType) {
        return getSkill(skill).label;
    }
}
