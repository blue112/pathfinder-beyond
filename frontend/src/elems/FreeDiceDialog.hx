package elems;

import js.Browser;
import Rules;

using Rules;

class FreeDiceDialog extends ChoicesDialog {
    static var diceTypes = [2, 3, 4, 6, 8, 10, 12, 20, 100];

    static public var contactRolls = [
        {id: "contact-cac", label: "Jet de contact au corps à corps"},
        {id: "contact-distance", label: "Jet de contact à distance"},
    ];

    public function new(onChoice:Int->Void) {
        var choices = diceTypes.map(d -> 'D$d').concat(contactRolls.map(r -> r.label));
        super("Lancer un dé", choices, onChoice);
        var notice = js.Browser.document.createParagraphElement();
        notice.className = "free-dice-notice";
        notice.innerText = "Ces lancers de dés sont pour les fonctionnalités non implémentées ! Pour lancer un dé lié à une partie de la fiche, cliquez sur le modificateur (+X) ou sur l'icône du D20 !";
        getContent().appendChild(notice);
    }

    static public function diceForIndex(i:Int) {
        return diceTypes[i];
    }

    static public function isContactRoll(i:Int) {
        return i >= diceTypes.length;
    }

    static public function contactRollForIndex(i:Int) {
        return contactRolls[i - diceTypes.length];
    }

    static public function appendFreeDiceSection(container:js.html.Element, ficheId:String, character:FullCharacter) {
        var section = Browser.document.createDivElement();
        section.className = "cast-dices cast-free-dices";

        var label:js.html.Element = cast Browser.document.createElement("h3");
        label.innerText = "Dés libres";
        section.appendChild(label);

        for (d in diceTypes) {
            var item = Browser.document.createDivElement();
            item.className = "cast-dice-item free-dice-item";

            var labelSpan = Browser.document.createSpanElement();
            labelSpan.className = "cast-dice-label";
            labelSpan.innerText = 'D$d';
            item.appendChild(labelSpan);

            var resultSpan = Browser.document.createSpanElement();
            resultSpan.className = "cast-dice-result";
            item.appendChild(resultSpan);

            item.addEventListener("click", () -> {
                Api.rollDice(ficheId, d, 0, "libre").then(res -> {
                    Dice.roll([], res.result, d);
                    resultSpan.innerText = Std.string(res.result);
                    item.classList.add("rolled");
                });
            });

            section.appendChild(item);
        }

        for (r in contactRolls) {
            var item = Browser.document.createDivElement();
            item.className = "cast-dice-item free-dice-item";

            var labelSpan = Browser.document.createSpanElement();
            labelSpan.className = "cast-dice-label";
            labelSpan.innerText = r.label;
            item.appendChild(labelSpan);

            var resultSpan = Browser.document.createSpanElement();
            resultSpan.className = "cast-dice-result";
            item.appendChild(resultSpan);

            var bba = Rules.getBBA(character);
            var caracMod = if (r.id == "contact-cac") character.characteristicsMod.str else character.characteristicsMod.dex;
            var sizeMod = Rules.getSizeMod(character, false);
            var mods = if (sizeMod != 0) [bba, caracMod, sizeMod] else [bba, caracMod];
            var totalMod = mods.fold((m, acc) -> m + acc, 0);

            item.addEventListener("click", () -> {
                Api.rollDice(ficheId, 20, totalMod, r.id).then(res -> {
                    Dice.roll(mods, res.result, 20);
                    var sign = if (totalMod >= 0) "+" else "";
                    resultSpan.innerText = '1d20 (${res.result}) $sign$totalMod = ${res.result + totalMod}';
                    item.classList.add("rolled");
                });
            });

            section.appendChild(item);
        }

        container.appendChild(section);
    }
}
