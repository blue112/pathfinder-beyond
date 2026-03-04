import js.html.InputElement;
import js.html.SelectElement;
import js.html.DivElement;
import js.Browser;
using StringTools;
using ProtocolUtil;

enum abstract Step(Int) from Int to Int {
	var PLAYER_NAME = 1;
	var CHARACTER_NAME = 2;
	var CHARACTER_CLASS = 3;
	var RACE = 4;
	var ALIGNEMENT = 5;
	var GENDER = 6;
	var SIZE_CATEGORY = 7;
	var AGE = 8;
	var HEIGHT_CM = 9;
	var WEIGHT_KG = 10;
	var HAIR = 11;
	var EYES = 12;
	var DIVINITY = 13;
	var ORIGIN = 14;
	var USE_PREDILECTION_HP = 15;
}

class FicheCreator {
	var currentStep:Step;
	var currentData:BasicFicheData;
	var mainElem:DivElement;

	public function new() {
		currentStep = 0;
		currentData = cast {};

		mainElem = Browser.document.createDivElement();
		mainElem.classList.add("fiche-create");
		mainElem.innerHTML = "<h1>Créer un nouveau personnage</h1><div class='form'></div>";
		Browser.document.body.appendChild(mainElem);

		nextStep();
	}

	function validateStep() {
		var form = mainElem.querySelector(".form");
		var inp:InputElement = cast form.querySelector("input");
		var sel:SelectElement = cast form.querySelector("select");

		switch (currentStep) {
			case PLAYER_NAME:
				if (inp.value.length == 0 || inp.value.length > 50) return;
				currentData.playerName = inp.value;
			case CHARACTER_NAME:
				if (inp.value.length == 0 || inp.value.length > 50) return;
				currentData.characterName = inp.value;
			case CHARACTER_CLASS:
				currentData.characterClass = CharacterClass.createByName(sel.value);
			case RACE:
				currentData.race = CharacterRace.createByName(sel.value);
			case ALIGNEMENT:
				currentData.alignement = CharacterAlignement.createByName(sel.value);
			case GENDER:
				currentData.gender = CharacterGender.createByName(sel.value);
			case SIZE_CATEGORY:
				currentData.sizeCategory = SizeCategory.createByName(sel.value);
			case AGE:
				var age = Std.parseInt(inp.value);
				if (age == null || age <= 0) return;
				currentData.age = age;
			case HEIGHT_CM:
				var height = Std.parseInt(inp.value);
				if (height == null || height <= 0) return;
				currentData.heightCm = height;
			case WEIGHT_KG:
				var weight = Std.parseInt(inp.value);
				if (weight == null || weight <= 0) return;
				currentData.weightKg = weight;
			case HAIR:
				if (inp.value.length == 0) return;
				currentData.hair = inp.value;
			case EYES:
				if (inp.value.length == 0) return;
				currentData.eyes = inp.value;
			case DIVINITY:
				if (inp.value.length == 0) return;
				currentData.divinityName = inp.value;
			case ORIGIN:
				if (inp.value.length == 0) return;
				currentData.origin = inp.value;
			case USE_PREDILECTION_HP:
				currentData.usePredilectionHP = sel.value == "true";
		}

		if (currentStep == USE_PREDILECTION_HP)
			submit();
		else
			nextStep();
	}

	function nextStep() {
		var form = mainElem.querySelector(".form");
		currentStep++;

		var isSelect = currentStep == CHARACTER_CLASS || currentStep == RACE || currentStep == ALIGNEMENT || currentStep == GENDER || currentStep == SIZE_CATEGORY || currentStep == USE_PREDILECTION_HP;
		if (isSelect) {
			form.innerHTML = "<label></label><select></select><a class='next'>Valider</a>";
		} else {
			var inputType = if (currentStep == AGE || currentStep == HEIGHT_CM || currentStep == WEIGHT_KG) "number" else "text";
			form.innerHTML = '<label></label><input type="$inputType" /><a class="next">Valider</a>';
			(cast form.querySelector("input") : InputElement).addEventListener("keydown", (e:js.html.KeyboardEvent) -> {
				if (e.key == "Enter") validateStep();
			});
		}

		form.querySelector("a.next").addEventListener("click", () -> validateStep());

		form.querySelector("label").innerText = switch (currentStep) {
			case PLAYER_NAME: "Nom du joueur";
			case CHARACTER_NAME: "Nom du personnage";
			case CHARACTER_CLASS: "Classe";
			case RACE: "Race";
			case ALIGNEMENT: "Alignement";
			case GENDER: "Genre";
			case SIZE_CATEGORY: "Catégorie de taille";
			case AGE: "Âge";
			case HEIGHT_CM: "Taille (cm)";
			case WEIGHT_KG: "Poids (kg)";
			case HAIR: "Couleur des cheveux";
			case EYES: "Couleur des yeux";
			case DIVINITY: "Divinité";
			case ORIGIN: "Origine";
			case USE_PREDILECTION_HP: "Quel bonus de classe de prédilection appliquer ?";
			default: throw "Unknown step";
		};

		if (isSelect) {
			var sel:SelectElement = cast form.querySelector("select");
			if (currentStep == CHARACTER_CLASS) {
				for (cls in Type.allEnums(CharacterClass)) {
					var opt = Browser.document.createOptionElement();
					opt.value = cls.getName();
					opt.innerText = cls.classToString();
					sel.appendChild(opt);
				}
			} else if (currentStep == RACE) {
				for (race in Type.allEnums(CharacterRace)) {
					var opt = Browser.document.createOptionElement();
					opt.value = race.getName();
					opt.innerText = race.raceToString();
					sel.appendChild(opt);
				}
			} else if (currentStep == GENDER) {
				for (gender in Type.allEnums(CharacterGender)) {
					var opt = Browser.document.createOptionElement();
					opt.value = gender.getName();
					opt.innerText = gender.genderToString();
					sel.appendChild(opt);
				}
			} else if (currentStep == ALIGNEMENT) {
				for (align in Type.allEnums(CharacterAlignement)) {
					var opt = Browser.document.createOptionElement();
					opt.value = align.getName();
					opt.innerText = align.alignementToString();
					sel.appendChild(opt);
				}
			} else if (currentStep == SIZE_CATEGORY) {
				for (size in [SIZE_P, SIZE_M, SIZE_G]) {
					var opt = Browser.document.createOptionElement();
					opt.value = size.getName();
					opt.innerText = size.sizeCategoryToString();
					sel.appendChild(opt);
				}
				sel.value = if (currentData.race == CharacterRace.GNOME) "SIZE_P" else "SIZE_M";
			} else if (currentStep == USE_PREDILECTION_HP) {
				var optPv = Browser.document.createOptionElement();
				optPv.value = "true";
				optPv.innerText = "+1 pv par niveau";
				sel.appendChild(optPv);
				var optComp = Browser.document.createOptionElement();
				optComp.value = "false";
				optComp.innerText = "+1 rang de compétence par niveau";
				sel.appendChild(optComp);
			}
		}
	}

	function submit() {
		Api.createFiche(currentData).then((result:{ficheId:String}) -> {
			Browser.window.location.href = '/fiche/${result.ficheId}';
		});
	}
}
