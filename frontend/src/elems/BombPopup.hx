package elems;

import Protocol;

using ProtocolUtil;
using Rules;
using Math;

class BombPopup extends Popup {
	var character:FullCharacter;
	var fiche_id:String;
	var pushEvent:FicheEventType->Void;
	var register:Popup->Void;

	public function new(character:FullCharacter, fiche_id:String, pushEvent:FicheEventType->Void, register:Popup->Void) {
		super('Bombes');
		this.character = character;
		this.fiche_id = fiche_id;
		this.pushEvent = pushEvent;
		this.register = register;
		mainElem.classList.add("bombs");
		register(this);
		render();
	}

	override public function close() {
		register(null);
		super.close();
	}

	override public function render() {
		var content = getContent();
		content.innerHTML = "<h1>Bombes restantes : <span></span></h1>
		<div class='bomb'>
			<h2>Bombes normales</h2>
			<h3>Dégats (si touché) : <span></span></h3>
			<h4>Aspersion : <span class='dmg'></span> (DD <span class='dd'></span>)</h4>
			<a class='btn attack'>Lancer (provoque une attaque d'opportunité)</a>
			<div class='result'>
				<h2>Pour toucher : <span class='attack'></span></h2>
				<a class='btn damage'>(si touché) Lancer les dégats</a>
				<h3 class='direct'>Dégats directs : <span class='damage'></span></h3>
				<h3>Dégats d'aspersion : <span class='aspersion'></span> (DD <span class='dd'></span>)</h3>
			</div>
		</div>";

		var casting_class = if (character.basics.characterClass.canThrowBombs()) character.basics.characterClass else character.secondary_class;
		var casting_level = if (character.basics.characterClass.canThrowBombs()) character.level
			- character.secondary_class_levels else character.secondary_class_levels;

		var bomb = content.querySelector(".bomb");
		var result = bomb.querySelector(".result");
		bomb.querySelector("h3 span").innerText = "1d6 " + casting_class.getCastingModifier(character).asMod(true);
		bomb.querySelector("h4 span.dmg").innerText = "1 " + casting_class.getCastingModifier(character).asMod(true);
		bomb.querySelector("h4 span.dd").innerText = (10 + (casting_level / 2).floor() + casting_class.getCastingModifier(character)).string();
		result.querySelector("h3 .aspersion").innerText = '${1 + casting_class.getCastingModifier(character)}';
		result.querySelector("h3 .dd").innerText = '${(10 + (casting_level / 2).floor() + casting_class.getCastingModifier(character))}';

		bomb.querySelector(".btn.damage").addEventListener("click", () -> {
			var mods = [(casting_level / 2).floor(), casting_class.getCastingModifier(character)];
			var totalMod = mods.fold((m, acc) -> m + acc, 0);
			Api.rollDice(fiche_id, 6, totalMod, "bombs-damage").then(res -> {
				Dice.roll(mods, res.result, 6);
				haxe.Timer.delay(() -> {
					result.classList.add("damage-rolled");
					result.querySelector("h3 .damage").innerText = '${res.result + totalMod}';
				}, 1500);
			});
		});
		var attackBtn = bomb.querySelector(".btn.attack");
		if (character.bombs_available == 0)
			attackBtn.classList.add("disabled");

		attackBtn.addEventListener("click", () -> {
			if (attackBtn.classList.contains("disabled"))
				return;

			var bba = Rules.getBBA(character);
			var statMod = character.characteristicsMod.dex;
			var improvisedWeaponMod = 1;
			var size = Rules.getSizeMod(character, false);
			var negLvl = character.getTempMods([NEGATIVE_LEVEL]).sum(); // negative value
			var mods = if (size != 0 && negLvl != 0) [bba, statMod, size, negLvl, ] else if (size != 0) [bba, statMod, size] else if (negLvl != 0)
				[bba, statMod, negLvl] else [bba, statMod];
			mods.push(improvisedWeaponMod);

			var totalMod = mods.fold((m, acc) -> m + acc, 0);
			Api.rollDice(fiche_id, 20, totalMod, "contact-distance").then(res -> {
				Dice.roll(mods, res.result, 20);
				haxe.Timer.delay(() -> {
					result.classList.add("show");
					result.querySelector("h2 .attack").innerText = '${res.result + totalMod}';
				}, 1500);
			});

			pushEvent(USE_BOMB);
		});

		content.querySelector("h1 span").innerText = character.bombs_available.string();
	}
}
