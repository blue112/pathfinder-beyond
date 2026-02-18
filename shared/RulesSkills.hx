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
			classSkillFor: [ROUBLARD],
		},
		{
			name: ART_DE_LA_MAGIE,
			label: "Art de la magie",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: ARTISANAT,
			label: "Artisanat",
			modifier: INTELLIGENCE,
			needTraining: false,
			classSkillFor: [ROUBLARD],
		},
		{
			name: BLUFF,
			label: "Bluff",
			modifier: CHARISMA,
			needTraining: false,
			classSkillFor: [ROUBLARD],
		},
		{
			name: CONNAISSANCE_EXPLORATION,
			label: "Connaissance (Exploration)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [ROUBLARD],
		},
		{
			name: CONNAISSANCE_FOLFKLORE_LOCAL,
			label: "Connaissance (Folfklore Local)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [ROUBLARD],
		},
		{
			name: CONNAISSANCE_GEOGRAPHIE,
			label: "Connaissance (Géographie)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_HISTOIRE,
			label: "Connaissance (Histoire)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_INGENIERIE,
			label: "Connaissance (Ingénierie)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_MYSTERES,
			label: "Connaissance (Mystères)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_NATURE,
			label: "Connaissance (Nature)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_NOBLESSE,
			label: "Connaissance (Noblesse)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_PLANS,
			label: "Connaissance (Plans)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: CONNAISSANCE_RELIGION,
			label: "Connaissance (Religion)",
			modifier: INTELLIGENCE,
			needTraining: true,
			classSkillFor: [],
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
			classSkillFor: [ROUBLARD],
		},
		{
			name: DISCRETION,
			label: "Discrétion",
			modifier: DEXTERITY,
			needTraining: false,
			classSkillFor: [ROUBLARD],
		},
		{
			name: DRESSAGE,
			label: "Dressage",
			modifier: CHARISMA,
			needTraining: true,
			classSkillFor: [],
		},
		{
			name: EQUITATION,
			label: "Équitation",
			modifier: DEXTERITY,
			needTraining: false,
			classSkillFor: [],
		},
		{
			name: ESCALADE,
			label: "Escalade",
			modifier: STRENGTH,
			needTraining: false,
			classSkillFor: [ROUBLARD],
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
			classSkillFor: [ROUBLARD],
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
			classSkillFor: [ROUBLARD],
		},
		{
			name: NATATION,
			label: "Natation",
			modifier: STRENGTH,
			needTraining: false,
			classSkillFor: [ROUBLARD],
		},
		{
			name: PERCEPTION,
			label: "Perception",
			modifier: WISDOM,
			needTraining: false,
			classSkillFor: [ROUBLARD],
		},
		{
			name: PREMIERS_SECOURS,
			label: "Premiers secours",
			modifier: WISDOM,
			needTraining: false,
			classSkillFor: [],
		},
		{
			name: PROFESSION,
			label: "Profession",
			modifier: WISDOM,
			needTraining: true,
			classSkillFor: [ROUBLARD],
		},
		{
			name: PSYCHOLOGIE,
			label: "Psychologie",
			modifier: WISDOM,
			needTraining: false,
			classSkillFor: [ROUBLARD],
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
			classSkillFor: [],
		},
		{
			name: UTILISATION_OBJETS_MAGIQUES,
			label: "Utilisation d'objets magiques",
			modifier: CHARISMA,
			needTraining: true,
			classSkillFor: [ROUBLARD],
		},
		{
			name: VOL,
			label: "Vol",
			modifier: DEXTERITY,
			needTraining: false,
			classSkillFor: [],
		},
	];

	static public function getSkill(skill:SkillType) {
		return skills.find(s -> s.name == skill);
	}

	static public function getSkillLabel(skill:SkillType) {
		return getSkill(skill).label;
	}
}
