package elems;

import js.Browser;

class WeaponRollDialog extends Popup {
	public function new(weapon:NPCWeapon) {
		super('Attaque — ${weapon.name}');
		mainElem.classList.add("alert");

		var attackRoll = dice(20);
		attackRoll = 1; // Hack
		var isCriticalSuccess = weapon.criticalNums.contains(attackRoll);
		var isCriticalFailure = attackRoll == 1;
		var attackTotal = attackRoll + weapon.attackBonus;

		var attackEl = Browser.document.createParagraphElement();
		attackEl.classList.add("roll-line");
		attackEl.classList.add("attack-roll");
		attackEl.classList.addIf("critical-success", isCriticalSuccess);
		attackEl.classList.addIf("critical-failure", isCriticalFailure);
		attackEl.innerHTML = "<strong>Toucher</strong> : <span class='die-result'></span>
        <span class='modifier'></span>
        <strong class='total'></strong>
        <span class='critical-text'></span>";

		attackEl.querySelector(".critical-text").innerText = if (isCriticalSuccess) "Succès critique !" else if (isCriticalFailure) "Échec critique !" else "";

		var attackDie = attackEl.querySelector(".die-result");
		attackDie.innerText = Std.string(attackRoll);
		attackEl.querySelector(".modifier").innerText = ' ${weapon.attackBonus.asMod(true)} = ';
		var attackTotalEl:js.html.Element = attackEl.querySelector(".total");
		attackTotalEl.innerText = Std.string(attackTotal);
		getContent().appendChild(attackEl);

		if (isCriticalSuccess) {
			var secondDice = dice(20);
			var attackTotal = secondDice + weapon.attackBonus;

			var attackEl2 = Browser.document.createParagraphElement();
			attackEl2.classList.add("roll-line");
			attackEl2.classList.add("attack-roll");
			attackEl2.innerHTML = "<strong>Toucher (confirmer le critique)</strong> : <span class='die-result'></span>
        <span class='modifier'></span>
        <strong class='total'></strong>
        <span class='critical-text'></span>";

			var attackDie = attackEl2.querySelector(".die-result");
			attackDie.innerText = Std.string(secondDice);
			attackEl2.querySelector(".modifier").innerText = ' ${weapon.attackBonus.asMod(true)} = ';
			var attackTotalEl:js.html.Element = attackEl2.querySelector(".total");
			attackTotalEl.innerText = Std.string(attackTotal);
			getContent().appendChild(attackEl2);
		}

		var damageEl = Browser.document.createParagraphElement();
		damageEl.className = "roll-line damage-roll";
		var degatsLabel:js.html.Element = cast Browser.document.createElement("strong");
		degatsLabel.innerText = "Dégâts";
		damageEl.appendChild(degatsLabel);
		damageEl.appendChild(Browser.document.createTextNode(' : '));
		appendRollDamage(damageEl, weapon.damage);
		getContent().appendChild(damageEl);

		if (isCriticalSuccess) {
			degatsLabel.innerText = "Dégâts (si non critique)";

			var damageEl2 = Browser.document.createParagraphElement();
			damageEl2.className = "roll-line damage-roll";
			var degatsLabel:js.html.Element = cast Browser.document.createElement("strong");
			degatsLabel.innerText = "Dégâts (si critique)";
			damageEl2.appendChild(degatsLabel);
			damageEl2.appendChild(Browser.document.createTextNode(' : '));
			appendRollDamage(damageEl2, weapon.damage, true);
			getContent().appendChild(damageEl2);
		}

		if (weapon.note != null) {
			var noteP = Browser.document.createParagraphElement();
			noteP.className = "weapon-roll-note";
			noteP.innerText = weapon.note;
			getContent().appendChild(noteP);
		}

		Browser.document.body.appendChild(mainElem);
	}

	static function appendRollDamage(parent:js.html.Element, s:String, ?isCritical:Bool) {
		var diceRegex = ~/([1-9])d([1-9][0-9]*)((\+|-)[0-9]+)?/;
		var clean = s.replace(" ", "");
		if (!diceRegex.match(clean)) {
			parent.appendChild(Browser.document.createTextNode(s));
			return;
		}

		var count = diceRegex.matched(1).parseInt();
		if (isCritical)
			count *= 2;

		var faces = diceRegex.matched(2).parseInt();
		var modifier = if (diceRegex.matched(3) != null) diceRegex.matched(3).parseInt() else 0;
		if (isCritical)
			modifier *= 2;

		var rolls = [for (_ in 0...count) dice(faces)];
		var rollsSum = rolls.fold((v, acc) -> acc + v, 0);
		var total = rollsSum + modifier;

		if (rolls.length == 1) {
			var dieSpan = Browser.document.createSpanElement();
			dieSpan.className = "die-result";
			dieSpan.innerText = Std.string(rolls[0]);
			parent.appendChild(dieSpan);
		} else {
			parent.appendChild(Browser.document.createTextNode('['));
			for (i in 0...rolls.length) {
				if (i > 0)
					parent.appendChild(Browser.document.createTextNode(', '));
				var dieSpan = Browser.document.createSpanElement();
				dieSpan.className = "die-result";
				dieSpan.innerText = Std.string(rolls[i]);
				parent.appendChild(dieSpan);
			}
			parent.appendChild(Browser.document.createTextNode(']'));
		}

		if (modifier != 0)
			parent.appendChild(Browser.document.createTextNode(' ${modifier.asMod(true)} = '));
		else
			parent.appendChild(Browser.document.createTextNode(' = '));

		var totalEl:js.html.Element = cast Browser.document.createElement("strong");
		totalEl.innerText = Std.string(total);
		parent.appendChild(totalEl);
	}
}
