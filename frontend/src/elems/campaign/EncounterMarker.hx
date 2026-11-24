package elems.campaign;

import haxe.ds.StringMap;
import js.html.LIElement;
import js.Browser.*;

class EncounterMarker {
	public var elem:LIElement;
	public var entity:EncounterEntityType;
	public var initiative:Int;
	public var hidden:Bool;

	var charactersByFicheId:StringMap<FullCharacter>;

	public function new(entity:EncounterEntityType, charactersByFicheId:StringMap<FullCharacter>, playerColor:StringMap<String>, hidden:Bool) {
		this.charactersByFicheId = charactersByFicheId;
		elem = document.createLIElement();
		elem.innerHTML = "<span class='initiative'></span><span class='initiative-full'></span><span class='name'></span><span class='note'></span>";
		this.hidden = hidden;
		this.entity = entity;

		switch (entity) {
			case CHARACTER(ficheId):
				var color = if (playerColor.exists(ficheId)) playerColor.get(ficheId) else "#00FF00";
				elem.classList.add("player");
				elem.style.setProperty("--marker-color", color);
			case NPC(npcName):
				elem.style.setProperty("--marker-color", "#FF0000");
		}

		setName();
	}

	public function update(enc:EncounterEntry) {
		setInitiative(enc.initiative);
		setHidden(enc.hidden);
		setNote(enc.note);
	}

	public function setNote(note:String) {
		if (note != null && note.length > 3) {
			trace('Note is too long to display: $note');
			note = null;
		}

		elem.classList.addIf("has-note", note != null);
		if (note != null) {
			elem.querySelector(".note").innerText = note;
		}
	}

	public function setName() {
		var name = switch (entity) {
			case CHARACTER(ficheId):
				charactersByFicheId.get(ficheId).basics.characterName.split(" ")[0];
			case NPC(npcName):
				if (hidden) "?" else npcName;
		}
		var iconFolder = switch (entity) {
			case CHARACTER(ficheId): "players";
			case NPC(npcName): "npc";
		}

		if (name.length > 10)
			elem.querySelector(".name").classList.add("long");

		elem.querySelector(".name").innerText = name;
		var iconRegex = ~/[^a-z]/gi;
		elem.style.setProperty("--icon", 'url(/assets/icons/$iconFolder/${iconRegex.replace(name, "-").toLowerCase()}.png)');
	}

	public function setHidden(hidden:Bool) {
		if (this.hidden != hidden) {
			this.hidden = hidden;
			setName();
		}
	}

	public function setInitiative(init:Int) {
		elem.querySelector(".initiative").innerText = Math.round(init / 100).string();
		elem.querySelector(".initiative-full").innerText = init.string();
		initiative = init;
	}
}
