package elems;

import js.Browser;

class WeaponRollDialog extends Popup {
	public function new(weapon:NPCWeapon) {
		super('Attaque — ${weapon.name}');
		mainElem.classList.add("alert");

		var attackRoll = dice(20);
		var attackTotal = attackRoll + weapon.attackBonus;

		getContent().innerHTML = "
		<p class='roll-line attack-roll'></p>
		<p class='roll-line damage-roll'></p>";

		mainElem.querySelector(".attack-roll").innerHTML = '<strong>Toucher</strong> : <span class="die-result">$attackRoll</span> ${weapon.attackBonus.asMod(true)} = <strong>$attackTotal</strong>';
		mainElem.querySelector(".damage-roll").innerHTML = '<strong>Dégâts</strong> : ${rollDamage(weapon.damage)}';

		if (weapon.note != null) {
			var noteP = Browser.document.createParagraphElement();
			noteP.className = "weapon-roll-note";
			noteP.innerText = weapon.note;
			getContent().appendChild(noteP);
		}

		Browser.document.body.appendChild(mainElem);
	}

	static function rollDamage(s:String):String {
		var diceRegex = ~/([1-9])d([1-9][0-9]*)((\+|-)[0-9]+)?/;
		var clean = s.replace(" ", "");
		if (!diceRegex.match(clean))
			return s;
		var count = diceRegex.matched(1).parseInt();
		var faces = diceRegex.matched(2).parseInt();
		var modifier = if (diceRegex.matched(3) != null) diceRegex.matched(3).parseInt() else 0;
		var rolls = [for (_ in 0...count) dice(faces)];
		var rollsSum = rolls.fold((v, acc) -> acc + v, 0);
		var total = rollsSum + modifier;
		var rollsStr = if (rolls.length == 1)
			'<span class="die-result">${rolls[0]}</span>'
		else
			'[${rolls.map(r -> '<span class="die-result">$r</span>').join(", ")}]';
		return if (modifier != 0) '$rollsStr ${modifier.asMod(true)} = <strong>$total</strong>' else '$rollsStr = <strong>$total</strong>';
	}
}
