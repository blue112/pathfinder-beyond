package elems;

import js.Browser;
import Protocol;
import ProtocolUtil;
import Rules;
import Protocol;

using ProtocolUtil;
using Rules;

class SpellDetailPopup extends Popup {
    var onBack:Void->Void;

    public function new(spell:Spell, spellIndex:Int, character:FullCharacter, pushEvent:FicheEventType->Void, onBack:Void->Void) {
        super(spell.name);
        this.onBack = onBack;
        mainElem.classList.add("spell-detail");

        var backBtn = Browser.document.createAnchorElement();
        backBtn.className = "back";
        backBtn.innerText = "Retour";
        backBtn.addEventListener("click", close);
        var main = mainElem.querySelector(".main");
        main.insertBefore(backBtn, main.querySelector("h2"));

        var content = getContent();
        content.innerHTML = "<dl class='spell-detail-dl'></dl><div class='actions'><a class='cast-btn'>Lancer le sort</a></div>";

        var dl = content.querySelector("dl.spell-detail-dl");

        function addRow(label:String, value:String) {
            var dt:js.html.Element = cast Browser.document.createElement("dt");
            var dd:js.html.Element = cast Browser.document.createElement("dd");
            dt.innerText = label;
            dd.innerText = value;
            dl.appendChild(dt);
            dl.appendChild(dd);
        }

        var isPower = spell.usesPerDay != null && spell.usesPerDay > 0;
        addRow("École", spell.school.spellSchoolToString());
        if (!isPower) addRow("Niveau", Std.string(spell.level));
        if (spell.shortDescription != null) addRow("Description courte", spell.shortDescription);
        addRow("Temps d'incantation", spell.castingTime.spellCastingTimeToString());
        var durationStr = spell.duration.spellDurationToString();
        addRow("Durée", if (spell.canEndVoluntarily) '$durationStr (peut être terminé volontairement)' else durationStr);
        addRow("Portée", spell.range.spellRangeToString());
        if (spell.components.length > 0) addRow("Composantes", spell.components.map(c -> c.spellComponentToString()).join(", "));
        if (spell.targets != "") addRow("Cibles", spell.targets);
        if (spell.areaOfEffect != null) addRow("Zone d'effet", spell.areaOfEffect);
        if (spell.savingThrowType != null) {
            var dcStr = if (isPower) {
                if (spell.savingThrowDC != null) 'DD ${spell.savingThrowDC}' else null;
            } else {
                var mod = Rules.getCastingModifier(character.basics.characterClass, character);
                'DD ${10 + spell.level + mod}';
            };
            var stLabel = spell.savingThrowType.savingThrowToString();
            addRow("Jet de sauvegarde", if (dcStr != null) '$stLabel ($dcStr)' else stLabel);
            if (spell.saveEffect != null) addRow("Résultat de sauvegarde", spell.saveEffect.spellSaveEffectToString());
        }
        addRow("Résistance à la magie", if (spell.spellResistance) "Oui" else "Non");
        if (spell.usesPerDay != null) addRow("Utilisations / jour", Std.string(spell.usesPerDay));

        if (spell.longDescription != "") {
            var descBlock = Browser.document.createDivElement();
            descBlock.className = "spell-long-desc";
            descBlock.innerText = spell.longDescription;
            content.insertBefore(descBlock, content.querySelector(".actions"));
        }

        var dicesSection = Browser.document.createDivElement();
        dicesSection.className = "spell-dices";
        var dicesLabel:js.html.Element = cast Browser.document.createElement("h3");
        dicesLabel.innerText = "Dés associés au sort";
        dicesSection.appendChild(dicesLabel);
        var spellDices = if (spell.dices != null) spell.dices else [];
        for (di in 0...spellDices.length) {
            var d = spellDices[di];
            var row = Browser.document.createDivElement();
            row.className = "spell-dice-item";
            var label = Browser.document.createSpanElement();
            label.innerText = '${d.reason} : ${d.diceType.spellDiceTypeToString()}';
            var del = Browser.document.createAnchorElement();
            del.className = "spell-dice-del";
            del.innerText = "×";
            del.addEventListener("click", () -> {
                pushEvent(SPELL_EVENT(REMOVE_SPELL_DICE(spellIndex, di)));
                dicesSection.removeChild(row);
            });
            row.appendChild(label);
            row.appendChild(del);
            dicesSection.appendChild(row);
        }
        var addDiceBtn = Browser.document.createAnchorElement();
        addDiceBtn.className = "add-dice-btn";
        addDiceBtn.innerText = "+ Ajouter un dé";
        addDiceBtn.addEventListener("click", () -> {
            new elems.SpellDiceDialog(spell.name, (dice) -> {
                pushEvent(SPELL_EVENT(ADD_SPELL_DICE(spellIndex, dice)));
                close();
            });
        });
        dicesSection.appendChild(addDiceBtn);
        content.insertBefore(dicesSection, content.querySelector(".actions"));

        var isSpontaneous = character.basics.characterClass.canCastSpells() && !character.basics.characterClass.needsSpellPreparation();
        var castBtn:js.html.AnchorElement = cast content.querySelector("a.cast-btn");
        if (isPower) {
            castBtn.innerText = "Utiliser le pouvoir";
            var usedCount = character.usedPowers.exists(spellIndex) ? character.usedPowers.get(spellIndex) : 0;
            var remaining = spell.usesPerDay - usedCount;
            if (remaining == 0) {
                castBtn.classList.add("disabled");
            } else {
                var usageSpan = Browser.document.createSpanElement();
                usageSpan.className = "cast-usage";
                usageSpan.innerText = '($remaining utilisation${if (remaining > 1) "s" else ""} restante${if (remaining > 1) "s" else ""})';
                castBtn.appendChild(usageSpan);
                castBtn.addEventListener("click", () -> {
                    new YesNoAlert("Utiliser le pouvoir", 'Confirmer l\'utilisation de "${spell.name}" ?', () -> {
                        pushEvent(SPELL_EVENT(CAST_SPELL(spellIndex)));
                        close();
                    });
                });
            }
        } else if (spell.level == 0) {
            var preparedCount = character.preparedSpells.filter(p -> p.spellIndex == spellIndex).length;
            var canCast = isSpontaneous || preparedCount > 0;
            if (!canCast) {
                castBtn.classList.add("disabled");
            } else {
                var usageSpan = Browser.document.createSpanElement();
                usageSpan.className = "cast-usage";
                usageSpan.innerText = "(illimité)";
                castBtn.appendChild(usageSpan);
                castBtn.addEventListener("click", () -> {
                    new YesNoAlert("Lancer le sort", 'Confirmer le lancement de "${spell.name}" ?', () -> {
                        pushEvent(SPELL_EVENT(CAST_SPELL(spellIndex)));
                        close();
                    });
                });
            }
        } else if (isSpontaneous) {
            var slots = Rules.getSpellSlots(character.basics.characterClass, character);
            var remaining = slots[spell.level] - (character.usedSlots.exists(spell.level) ? character.usedSlots.get(spell.level) : 0);
            if (remaining == 0) {
                castBtn.classList.add("disabled");
            } else {
                var usageSpan = Browser.document.createSpanElement();
                usageSpan.className = "cast-usage";
                usageSpan.innerText = '($remaining emplacement${if (remaining > 1) "s" else ""} restant${if (remaining > 1) "s" else ""})';
                castBtn.appendChild(usageSpan);
                castBtn.addEventListener("click", () -> {
                    new YesNoAlert("Lancer le sort", 'Confirmer le lancement de "${spell.name}" ? Un emplacement de niveau ${spell.level} sera consommé.', () -> {
                        pushEvent(SPELL_EVENT(CAST_SPELL(spellIndex)));
                        close();
                    });
                });
            }
        } else {
            var preparedCount = character.preparedSpells.filter(p -> p.spellIndex == spellIndex).length;
            if (preparedCount == 0) {
                castBtn.classList.add("disabled");
            } else {
                var usageSpan = Browser.document.createSpanElement();
                usageSpan.className = "cast-usage";
                usageSpan.innerText = '($preparedCount usage${if (preparedCount > 1) "s" else ""} restant${if (preparedCount > 1) "s" else ""})';
                castBtn.appendChild(usageSpan);
                castBtn.addEventListener("click", () -> {
                    new YesNoAlert("Lancer le sort", 'Confirmer le lancement de "${spell.name}" ? L\'emplacement de sort sera consommé.', () -> {
                        pushEvent(SPELL_EVENT(CAST_SPELL(spellIndex)));
                        close();
                    });
                });
            }
        }
    }

    override public function close() {
        super.close();
        onBack();
    }
}
