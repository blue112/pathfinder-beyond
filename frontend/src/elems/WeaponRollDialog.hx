package elems;

import js.Browser;

class WeaponRollDialog extends Popup {
    public function new(weapon:NPCWeapon) {
        super('Attaque — ${weapon.name}');
        mainElem.classList.add("alert");

        var attackRoll = dice(20);
        var attackTotal = attackRoll + weapon.attackBonus;

        var attackEl = Browser.document.createParagraphElement();
        attackEl.className = "roll-line attack-roll";
        var toucherLabel:js.html.Element = cast Browser.document.createElement("strong");
        toucherLabel.innerText = "Toucher";
        attackEl.appendChild(toucherLabel);
        attackEl.appendChild(Browser.document.createTextNode(' : '));
        var attackDie = Browser.document.createSpanElement();
        attackDie.className = "die-result";
        attackDie.innerText = Std.string(attackRoll);
        attackEl.appendChild(attackDie);
        attackEl.appendChild(Browser.document.createTextNode(' ${weapon.attackBonus.asMod(true)} = '));
        var attackTotalEl:js.html.Element = cast Browser.document.createElement("strong");
        attackTotalEl.innerText = Std.string(attackTotal);
        attackEl.appendChild(attackTotalEl);
        getContent().appendChild(attackEl);

        var damageEl = Browser.document.createParagraphElement();
        damageEl.className = "roll-line damage-roll";
        var degatsLabel:js.html.Element = cast Browser.document.createElement("strong");
        degatsLabel.innerText = "Dégâts";
        damageEl.appendChild(degatsLabel);
        damageEl.appendChild(Browser.document.createTextNode(' : '));
        appendRollDamage(damageEl, weapon.damage);
        getContent().appendChild(damageEl);

        if (weapon.note != null) {
            var noteP = Browser.document.createParagraphElement();
            noteP.className = "weapon-roll-note";
            noteP.innerText = weapon.note;
            getContent().appendChild(noteP);
        }

        Browser.document.body.appendChild(mainElem);
    }

    static function appendRollDamage(parent:js.html.Element, s:String) {
        var diceRegex = ~/([1-9])d([1-9][0-9]*)((\+|-)[0-9]+)?/;
        var clean = s.replace(" ", "");
        if (!diceRegex.match(clean)) {
            parent.appendChild(Browser.document.createTextNode(s));
            return;
        }
        var count = diceRegex.matched(1).parseInt();
        var faces = diceRegex.matched(2).parseInt();
        var modifier = if (diceRegex.matched(3) != null) diceRegex.matched(3).parseInt() else 0;
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
                if (i > 0) parent.appendChild(Browser.document.createTextNode(', '));
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
