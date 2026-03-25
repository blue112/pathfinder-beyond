package elems;

import haxe.ds.StringMap;
import js.Browser;
import Protocol;
import ProtocolUtil;
import Rules;

using ProtocolUtil;
using Rules;

class SpellCastPopup extends Popup {
    public static function registerFieldNames(spells:Array<Spell>, fieldsNames:StringMap<String>) {
        fieldsNames.set("sort-rm", "Résistance à la magie");
        for (spell in spells) {
            var dices = if (spell.dices != null) spell.dices else [];
            for (d in dices) {
                switch (d.diceType) {
                    case NLS:
                        fieldsNames.set('sort-nls-${spell.name}', '${spell.name} — NLS');
                    case CARACTERISTIC(c):
                        fieldsNames.set('sort-carac-${spell.name}-${c.caracToString(false)}', '${spell.name} — ${c.caracToString(false)}');
                    case MANUAL(_):
                        fieldsNames.set('sort-${spell.name}', '${spell.name} — ${d.reason}');
                    case CONTACT_MELEE:
                    case CONTACT_RANGED:
                }
            }
        }
    }

    static function parseFormula(formula:String, nls:Int):{count:Int, faces:Int, flatMod:Int, unparseable:Bool} {
        var expr = StringTools.replace(formula, "NLS", Std.string(nls));
        var diceRe = ~/(\d+)d(\d+)/;
        if (!diceRe.match(expr))
            return {count: 0, faces: 0, flatMod: MathExpr.eval(expr), unparseable: false};
        var count = Std.parseInt(diceRe.matched(1));
        var faces = Std.parseInt(diceRe.matched(2));
        var flatMod = MathExpr.eval(diceRe.matchedLeft() + "0" + diceRe.matchedRight());
        return {count: count, faces: faces, flatMod: flatMod, unparseable: false};
    }

    public function new(spell:Spell, character:FullCharacter, ficheId:String) {
        super(spell.name);
        mainElem.classList.add("spell-cast");

        var content = getContent();
        var diceItems:Array<js.html.Element> = [];
        var srActive = spell.spellResistance;

        function enableDices() {
            for (item in diceItems) item.classList.remove("disabled");
        }

        if (spell.longDescription != "") {
            var desc = Browser.document.createDivElement();
            desc.className = "cast-long-desc";
            desc.innerText = spell.longDescription;
            content.appendChild(desc);
        }

        if (spell.spellResistance) {
            var srWarning = Browser.document.createDivElement();
            srWarning.className = "cast-sr-warning";

            var question = Browser.document.createParagraphElement();
            question.className = "cast-sr-question";
            question.innerText = "Est-ce que la cible est résistante à la magie ?";
            srWarning.appendChild(question);

            var btns = Browser.document.createDivElement();
            btns.className = "cast-sr-btns";

            var yesBtn = Browser.document.createAnchorElement();
            yesBtn.className = "cast-sr-yes";
            yesBtn.innerText = "Oui";
            yesBtn.addEventListener("click", () -> {
                btns.remove();
                question.innerText = "Résistance à la magie :";
                var nls = character.level;
                Api.rollDice(ficheId, 20, nls, "sort-rm").then(res -> {
                    Dice.roll([nls], res.result, 20);
                    var result = Browser.document.createParagraphElement();
                    result.className = "cast-sr-result";
                    result.innerText = '1d20 (${res.result}) + NLS ($nls) = ${res.result + nls}';
                    srWarning.appendChild(result);
                    enableDices();
                });
            });

            var noBtn = Browser.document.createAnchorElement();
            noBtn.className = "cast-sr-no";
            noBtn.innerText = "Non";
            noBtn.addEventListener("click", () -> {
                srWarning.remove();
                enableDices();
            });

            btns.appendChild(yesBtn);
            btns.appendChild(noBtn);
            srWarning.appendChild(btns);
            content.appendChild(srWarning);
        }

        if (spell.savingThrowType != null) {
            var stSection = Browser.document.createDivElement();
            stSection.className = "cast-saving-throw";

            var isPower = spell.usesPerDay != null && spell.usesPerDay > 0;
            var dcStr = if (isPower) {
                if (spell.savingThrowDC != null) 'DD ${spell.savingThrowDC}' else "";
            } else {
                var mod = Rules.getCastingModifier(character.basics.characterClass, character);
                var racialBonus = Rules.getRacialSpellDCBonus(character.basics.race, spell.school);
                'DD ${10 + spell.level + mod + racialBonus}';
            };

            var stLabel = Browser.document.createSpanElement();
            stLabel.className = "cast-st-label";
            stLabel.innerText = spell.savingThrowType.savingThrowToString();
            stSection.appendChild(stLabel);

            var stDc = Browser.document.createSpanElement();
            stDc.className = "cast-st-dc";
            stDc.innerText = dcStr;
            stSection.appendChild(stDc);

            if (spell.saveEffect != null) {
                var stEffect = Browser.document.createSpanElement();
                stEffect.className = "cast-st-effect";
                stEffect.innerText = spell.saveEffect.spellSaveEffectToString();
                stSection.appendChild(stEffect);
            }

            content.appendChild(stSection);
        }

        var spellDices = if (spell.dices != null) spell.dices else [];
        if (spellDices.length > 0) {
            var dicesSection = Browser.document.createDivElement();
            dicesSection.className = "cast-dices";

            var dicesLabel:js.html.Element = cast Browser.document.createElement("h3");
            dicesLabel.innerText = "Dés";
            dicesSection.appendChild(dicesLabel);

            for (d in spellDices) {
                var item = Browser.document.createDivElement();
                item.className = if (srActive) "cast-dice-item disabled" else "cast-dice-item";

                var labelSpan = Browser.document.createSpanElement();
                labelSpan.className = "cast-dice-label";
                labelSpan.innerText = '${d.reason} : ${d.diceType.spellDiceTypeToString()}';
                item.appendChild(labelSpan);

                var resultSpan = Browser.document.createSpanElement();
                resultSpan.className = "cast-dice-result";
                item.appendChild(resultSpan);

                item.addEventListener("click", () -> {
                    if (item.classList.contains("disabled")) return;
                    switch (d.diceType) {
                        case NLS:
                            var nls = character.level;
                            var fieldId = 'sort-nls-${spell.name}';
                            Api.rollDice(ficheId, 20, nls, fieldId).then(res -> {
                                Dice.roll([nls], res.result, 20);
                                resultSpan.innerText = '1d20 (${res.result}) + NLS ($nls) = ${res.result + nls}';
                                item.classList.add("rolled");
                            });
                        case CARACTERISTIC(c):
                            var mod = Rules.getCaracMod(character, c);
                            var fieldId = 'sort-carac-${spell.name}-${c.caracToString(false)}';
                            Api.rollDice(ficheId, 20, mod, fieldId).then(res -> {
                                Dice.roll([mod], res.result, 20);
                                var sign = if (mod >= 0) "+" else "";
                                resultSpan.innerText = '1d20 (${res.result}) $sign$mod = ${res.result + mod}';
                                item.classList.add("rolled");
                            });
                        case CONTACT_MELEE | CONTACT_RANGED:
                            var bba = Rules.getBBA(character);
                            var statMod = if (d.diceType.match(CONTACT_MELEE)) character.characteristicsMod.str else character.characteristicsMod.dex;
                            var size = Rules.getSizeMod(character, false);
                            var mods = if (size != 0) [bba, statMod, size] else [bba, statMod];
                            var totalMod = mods.fold((m, acc) -> m + acc, 0);
                            var fieldId = if (d.diceType.match(CONTACT_MELEE)) "contact-cac" else "contact-distance";
                            Api.rollDice(ficheId, 20, totalMod, fieldId).then(res -> {
                                Dice.roll(mods, res.result, 20);
                                resultSpan.innerText = '${res.result + totalMod}';
                                item.classList.add("rolled");
                            });
                        case MANUAL(formula):
                            var parsed = parseFormula(formula, character.level);
                            if (parsed.unparseable) {
                                new Alert("Formule invalide", 'La formule "$formula" n\'a pas pu être évaluée.');
                                return;
                            }
                            if (parsed.count == 0) {
                                resultSpan.innerText = Std.string(parsed.flatMod);
                                item.classList.add("rolled");
                                return;
                            }
                            var fieldId = 'sort-${spell.name}';
                            Api.rollDice(ficheId, parsed.faces, parsed.flatMod, fieldId, parsed.count).then(res -> {
                                var diceStr = '${parsed.count}d${parsed.faces}';
                                var total = res.result + parsed.flatMod;
                                resultSpan.innerText = if (parsed.flatMod != 0) {
                                    '$diceStr (${res.result}) + ${parsed.flatMod} = $total';
                                } else {
                                    '$diceStr = ${res.result}';
                                };
                                item.classList.add("rolled");
                            });
                    }
                });

                diceItems.push(item);
                dicesSection.appendChild(item);
            }

            content.appendChild(dicesSection);
        }

        FreeDiceDialog.appendFreeDiceSection(content, ficheId, character);

        var doneBtn = Browser.document.createAnchorElement();
        doneBtn.className = "cast-done-btn";
        doneBtn.innerText = "Terminé";
        doneBtn.addEventListener("click", close);
        content.appendChild(doneBtn);
    }
}
