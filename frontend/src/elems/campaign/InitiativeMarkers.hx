package elems.campaign;

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

		actions.querySelector(".next").addEventListener("click", () -> {
			// fixme
			pushEvent(NEXT_TURN);
		});
	}

	public function update(campaignState:CampaignState, charactersByFicheId:StringMap<FullCharacter>) {
		var encounter:Array<EncounterEntry> = campaignState.encounter;

		for (k in 0...encounter.length) {
			var marker = markers.find(n -> n.entity == encounter[k].entity);
			if (marker == null) {
				marker = addMarker(encounter[k].entity, charactersByFicheId, campaignState.playerColor);
			}
			var order = k;
			marker.elem.style.order = order.string();
			marker.order = order;
			setInitiative(marker, encounter[k].initiative);
		}
		for (i in markers.copy()) {
			if (!encounter.exists(n -> n.entity == i.entity)) {
				// Remove marker
				i.elem.remove();
				markers.remove(i);
			}
		}

		markers.sort((a, b) -> a.order - b.order);

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
			order: 0
		};
		markers.push(added);

		return added;
	}

	public function setInitiative(marker:EncounterMarker, init:Int) {
		marker.elem.querySelector(".initiative").innerText = init.string();
	}

	public function newNPC(name:String) {
		var markerElem = document.createLIElement();
		markerElem.classList.add("player");

		markerElem.innerHTML = "<span class='initiative'></span><span class='name'></span>";
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

		markerElem.innerHTML = "<span class='initiative'></span><span class='name'></span>";
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
	var order:Int;
}
