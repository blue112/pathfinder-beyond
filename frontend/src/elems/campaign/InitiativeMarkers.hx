package elems.campaign;

import js.html.MouseEvent;
import js.html.svg.MarkerElement;
import haxe.ds.StringMap;
import js.html.OListElement;
import js.html.DivElement;
import js.html.LIElement;
import js.Browser.*;

class InitiativeMarkers {
	var mainElem:DivElement;
	var list:OListElement;
	var markers:Array<EncounterMarker>;
	var currentEncounters:Array<EncounterEntry>;
	var campaignState:CampaignState;

	var pushEvent:CampaignEventType->Void;

	public function new(pushEvent:CampaignEventType->Void) {
		list = document.createOListElement();

		markers = [];

		var actions = document.createDivElement();
		actions.classList.add("actions");
		actions.innerHTML = "<a class='btn next'>Tour suivant</a>";

		mainElem = document.createDivElement();
		mainElem.classList.add("initiative");
		mainElem.append(actions);
		mainElem.append(list);
		document.body.appendChild(mainElem);

		this.pushEvent = pushEvent;

		actions.querySelector(".next").addEventListener("click", () -> {
			// fixme
			pushEvent(NEXT_TURN);
		});
	}

	public function update(campaignState:CampaignState, charactersByFicheId:StringMap<FullCharacter>) {
		var encounter:Array<EncounterEntry> = campaignState.encounter;

		this.campaignState = campaignState;

		for (k in 0...encounter.length) {
			var marker = markers.find(n -> n.entity == encounter[k].entity);
			if (marker == null) {
				marker = addMarker(encounter[k].entity, charactersByFicheId, campaignState.playerColor);
			}
			marker.elem.style.order = (5000 - encounter[k].initiative).string();
			setEffects(marker, encounter[k].turnModifiers);
			setInitiative(marker, encounter[k].initiative);
		}
		for (i in markers.copy()) {
			if (!encounter.exists(n -> n.entity == i.entity)) {
				// Remove marker
				i.elem.remove();
				markers.remove(i);
			}
		}

		markers.sort((a, b) -> b.initiative - a.initiative);

		setTurn(campaignState.currentTurn);

		this.currentEncounters = encounter.copy();
	}

	public function setTurn(turn:Int) {
		for (i in markers) {
			i.elem.classList.remove("playing");
		}

		markers[turn].elem.classList.add("playing");
	}

	public function addMarker(entity:EncounterEntityType, charactersByFicheId:StringMap<FullCharacter>, playerColor:StringMap<String>) {
		var marker = switch (entity) {
			case CHARACTER(ficheId):
				var firstName = charactersByFicheId.get(ficheId).basics.characterName.split(" ")[0];
				var color = if (playerColor.exists(ficheId)) playerColor.get(ficheId) else "#00FF00";
				newPlayer(color, firstName);
			case NPC(npcName):
				newNPC(npcName);
		}

		list.append(marker);
		var added = {
			entity: entity,
			elem: marker,
			initiative: 0
		};
		markers.push(added);
		bind(added);

		return added;
	}

	public function setInitiative(marker:EncounterMarker, init:Int) {
		marker.elem.querySelector(".initiative").innerText = Math.round(init / 100).string();
		marker.elem.querySelector(".initiative-full").innerText = init.string();
		marker.initiative = init;
	}

	public function setEffects(marker:EncounterMarker, effects:Array<TurnModifier>) {
		// Clear
		for (i in marker.elem.querySelectorAll(".state")) {
			marker.elem.removeChild(i);
		}

		for (i in effects) {
			var stateMarker = document.createDivElement();
			stateMarker.innerHTML = "<span class='name'></span><span class='turns'></span>";
			stateMarker.querySelector(".name").innerText = switch (i.effect) {
				case LABEL(label): label;
				case STATUS(type): type.statusToString();
			};
			stateMarker.querySelector(".turns").innerText = i.turnsLeft.string();
			stateMarker.classList.add("state");

			switch (i.effect) {
				case STATUS(type):
					stateMarker.classList.add("status");
					stateMarker.addEventListener('click', (e:MouseEvent) -> {
						e.stopPropagation();
						new Alert(type.statusToString(), type.statusToDescription());
					});
				case LABEL(_):
			}

			if (i.turnsLeft == 0) {
				stateMarker.classList.add("expired");
			}

			marker.elem.append(stateMarker);
		}
	}

	public function bind(marker:EncounterMarker) {
		marker.elem.addEventListener("click", () -> {
			new ContextMenu(marker.elem, ["Ajouter un effet", "Ajouter un status", "Changer l'initiative"], (choice) -> {
				if (choice == 0) {
					new AmountChoice("Quel effet ajouter", "Combien de tours ?", {
						defaultValue: 1,
						askReason: true,
						canBeNegative: false
					}, (turns:Int, name:String) -> {
						var turnInit = campaignState.encounter[campaignState.currentTurn].initiative;
						pushEvent(ADD_TURNS_MODIFIER(markers.indexOf(marker), turnInit, ADD_EFFECT(LABEL(name), turns)));
					});
				} else if (choice == 1) {
					new StatusChoice((turns:Int, status:StatusType) -> {
						var turnInit = campaignState.encounter[campaignState.currentTurn].initiative;
						pushEvent(ADD_TURNS_MODIFIER(markers.indexOf(marker), turnInit, ADD_EFFECT(STATUS(status), turns)));
					});
				} else {
					new elems.AmountChoice("Initiative", "Nouvelle valeur d'initiative :", {defaultValue: marker.initiative}, (newInitiative, _) -> {
						pushEvent(SET_INITIATIVE_IN_ENCOUNTER(markers.indexOf(marker), newInitiative));
					});
				}
				return true;
			});
		});
	}

	public function newNPC(name:String) {
		var markerElem = document.createLIElement();
		markerElem.classList.add("player");

		markerElem.innerHTML = "<span class='initiative'></span><span class='initiative-full'></span><span class='name'></span>";
		markerElem.querySelector(".name").innerText = name;
		if (name.length > 10)
			markerElem.querySelector(".name").classList.add("long");

		markerElem.style.setProperty("--marker-color", "#FF0000");
		markerElem.style.setProperty("--icon", 'url(/assets/icons/npc/${name.replace(" ", "-").toLowerCase()}.png)');

		return markerElem;
	}

	public function newPlayer(color:String, name:String) {
		var markerElem = document.createLIElement();
		markerElem.classList.add("player");

		markerElem.innerHTML = "<span class='initiative'></span><span class='initiative-full'></span><span class='name'></span>";
		markerElem.querySelector(".name").innerText = name;
		markerElem.style.setProperty("--marker-color", color);
		markerElem.style.setProperty("--icon", 'url(/assets/icons/players/${name.toLowerCase()}.png)');

		if (name == "Tess") {
			var stateMarker = document.createDivElement();
			stateMarker.innerHTML = "<span class='name'>Fatiguée</span><span class='turns'>15</span>";
			stateMarker.classList.add("state");
			markerElem.append(stateMarker);
			var stateMarker = document.createDivElement();
			stateMarker.innerHTML = "<span class='name'>Arme Protectrice</span><span class='turns'>0</span>";
			stateMarker.classList.add("expired");
			stateMarker.classList.add("state");
			markerElem.append(stateMarker);
		}

		return markerElem;
	}
}

typedef EncounterMarker = {
	var elem:LIElement;
	var entity:EncounterEntityType;
	var initiative:Int;
}
