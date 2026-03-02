/*
	{
	"playerName": "Blue",
	"characterName": "Red Daemon",
	"alignement": "NB",
	"characterClass": "Roublard",
	"divinityName": "Netys",
	"origin": "Korvosa",
	"race": "Human",
	"gender": "M",
	"sizeCategory": "M",
	"age": 22,
	"heightCm": 155,
	"weightKg": 55,
	"hair": "M/Marrons",
	"eyes": "Marrons"
	}
 */

import js.html.InputElement;
import js.html.DivElement;
import js.Browser;

class FicheCreator {
	var currentStep:Int;
	var currentData:Dynamic;
	var mainElem:DivElement;

	public function new() {
		currentStep = 0;
		currentData = {};

		mainElem = Browser.document.createDivElement();
		mainElem.classList.add("fiche-create");

		mainElem.innerHTML = "<h1>Créer un nouveau personnage</h1><div class='form'></div>";

		Browser.document.body.appendChild(mainElem);

		nextStep();
	}

	function validateStep() {
		var form = mainElem.querySelector(".form");
		var input:InputElement = cast form.querySelector("input");

		// Gather data
		switch (currentStep) {
			case 0:
			case 1:
				if (input.value.length == 0 || input.value.length > 50)
					return;
				currentData.characterName = input.value;
			case 2:
				var select = var input:InputElement = cast form.querySelector("input");
			default:
				throw "Unknown state";
		}

		nextStep();
	}

	function nextStep() {
		var form = mainElem.querySelector(".form");
		currentStep++;

		form.innerHTML = "<label></label><input type='text' /><a class='next'>Valider</a>";
		form.querySelector("a.next").addEventListener("click", () -> {
			validateStep();
		});

		var label = switch (currentStep) {
			case 1: "Nom du personnage";
			case 2: "Classe";
			default:
				throw "Unknown state";
		}

		if (currentStep == 2) // Select
		{
			var select = Browser.document.createSelectElement();
			for (i in CharacterClass.createAll()) {
				var name = i.getName();
				var opt = Browser.document.createOptionElement();
				opt.value = name;
				opt.innerText = i.classToString();
				select.appendChild(opt);
			}
			form.removeChild(form.querySelector("input"));
			form.insertBefore(select, form.querySelector("a.next"));
		}

		form.querySelector("label").innerText = label;
	}
}
