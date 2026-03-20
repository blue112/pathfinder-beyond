package elems;

import js.Browser;
import Protocol;
import ProtocolUtil;
import Rules;

using ProtocolUtil;
using Rules;

class SpellListPopup extends Popup {
    var character:FullCharacter;
    var pushEvent:FicheEventType->Void;
    var register:(Null<SpellListPopup>)->Void;

    public function new(character:FullCharacter, pushEvent:FicheEventType->Void, register:(Null<SpellListPopup>)->Void) {
        super("Sorts");
        this.character = character;
        this.pushEvent = pushEvent;
        this.register = register;
        mainElem.classList.add("spell-list");
        register(this);
        render();
    }

    override public function close() {
        register(null);
        super.close();
    }

    public function render() {
        var needsPrep = character.basics.characterClass.needsSpellPreparation();
        var slots = Rules.getSpellSlots(character.basics.characterClass, character);
        var spells = character.spells;
        var preparedSpells = character.preparedSpells;

        var content = getContent();
        content.innerHTML = "";

        var sorted = spells.copy();
        sorted.sort((a, b) -> {
            var lvlDiff = a.level - b.level;
            if (lvlDiff != 0) return lvlDiff;
            return (if (a.priority == null) 0 else a.priority) - (if (b.priority == null) 0 else b.priority);
        });

        if (needsPrep) {
            if (!character.preparationLocked) {
                var header = Browser.document.createParagraphElement();
                header.className = "prep-phase-header";
                header.innerText = "Phase de préparation";
                content.appendChild(header);
            }

            var slotSummary = Browser.document.createDivElement();
            slotSummary.className = "spell-slot-summary";
            var allFull = true;
            for (spellLevel in 0...10) {
                if (slots[spellLevel] == 0) continue;
                var used = preparedSpells.filter(p -> p.slotLevel == spellLevel).length;
                var isFull = used >= slots[spellLevel];
                if (!isFull) allFull = false;
                var badge = Browser.document.createSpanElement();
                badge.className = 'slot-badge ${if (isFull) "full" else "incomplete"}';
                badge.innerText = 'Niv.$spellLevel : $used/${slots[spellLevel]}';
                slotSummary.appendChild(badge);
            }
            content.appendChild(slotSummary);

            if (allFull && !character.preparationLocked) {
                var endBtn = Browser.document.createAnchorElement();
                endBtn.className = "end-prep-btn";
                endBtn.innerText = "Terminer la préparation";
                endBtn.addEventListener("click", () -> {
                    new YesNoAlert("Terminer la préparation", "Confirmer la fin de la préparation des sorts ? Vous ne pourrez plus modifier vos sorts préparés jusqu'au prochain nouveau jour.", () -> {
                        pushEvent(FINISH_SPELL_PREPARATION);
                    });
                });
                content.appendChild(endBtn);
            }
        }

        var showAvailable = needsPrep && character.preparationLocked;
        var ul = Browser.document.createUListElement();
        ul.className = if (needsPrep && !character.preparationLocked) "spell-list-ul has-prep"
            else if (showAvailable) "spell-list-ul has-available"
            else "spell-list-ul";
        content.appendChild(ul);

        for (spell in sorted) {
            var originalIndex = spells.indexOf(spell);
            var li = Browser.document.createLIElement();

            if (showAvailable) {
                var count = preparedSpells.filter(p -> p.spellIndex == originalIndex).length;
                var availSpan = Browser.document.createSpanElement();
                availSpan.className = 'spell-available ${if (count > 0) "has-charges" else "empty"}';
                availSpan.innerText = '×$count';
                li.appendChild(availSpan);
            }

            var levelSpan = Browser.document.createSpanElement();
            levelSpan.className = "spell-level";
            levelSpan.innerText = 'Niv.${spell.level}';
            li.appendChild(levelSpan);

            var nameCell = Browser.document.createSpanElement();
            nameCell.className = "spell-name-cell";
            var nameA = Browser.document.createAnchorElement();
            nameA.className = "spell-name";
            nameA.innerText = spell.name;
            nameCell.appendChild(nameA);
            if (spell.shortDescription != null) {
                var descSpan = Browser.document.createSpanElement();
                descSpan.className = "spell-short-desc";
                descSpan.innerText = spell.shortDescription;
                nameCell.appendChild(descSpan);
            }
            nameCell.addEventListener("click", () -> {
                close();
                new SpellDetailPopup(spell, () -> new SpellListPopup(character, pushEvent, register));
            });
            li.appendChild(nameCell);

            if (needsPrep && !character.preparationLocked) {
                var prepCount = preparedSpells.filter(p -> p.spellIndex == originalIndex).length;
                var prepControls = Browser.document.createSpanElement();
                prepControls.className = "spell-prep-controls";

                var countSpan = Browser.document.createSpanElement();
                countSpan.className = "prep-count";
                countSpan.innerText = '×$prepCount';

                var minusBtn = Browser.document.createAnchorElement();
                minusBtn.className = "prep-btn minus";
                minusBtn.innerText = "−";
                minusBtn.addEventListener("click", () -> {
                    if (prepCount > 0) pushEvent(UNPREPARE_SPELL(originalIndex));
                });

                var plusBtn = Browser.document.createAnchorElement();
                plusBtn.className = "prep-btn plus";
                plusBtn.innerText = "+";
                plusBtn.addEventListener("click", () -> {
                    var targetSlot = -1;
                    for (sl in spell.level...10) {
                        if (preparedSpells.filter(p -> p.slotLevel == sl).length < slots[sl]) {
                            targetSlot = sl;
                            break;
                        }
                    }
                    if (targetSlot >= 0) pushEvent(PREPARE_SPELL(originalIndex, targetSlot));
                });

                prepControls.appendChild(countSpan);
                prepControls.appendChild(minusBtn);
                prepControls.appendChild(plusBtn);
                li.appendChild(prepControls);
            }

            var deleteBtn = Browser.document.createAnchorElement();
            deleteBtn.className = "delete";
            deleteBtn.title = "Supprimer";
            deleteBtn.innerText = "×";
            deleteBtn.addEventListener("click", () -> {
                new YesNoAlert("Effacer un sort", 'Supprimer le sort "${spell.name}" ?', () -> {
                    pushEvent(REMOVE_SPELL(originalIndex));
                    close();
                });
            });
            li.appendChild(deleteBtn);

            ul.appendChild(li);
        }

        var addBtn = Browser.document.createAnchorElement();
        addBtn.className = "add-new";
        addBtn.innerText = "Ajouter un sort";
        addBtn.addEventListener("click", () -> {
            new SpellDialog((spell) -> pushEvent(ADD_SPELL(spell)));
        });
        content.appendChild(addBtn);
    }
}
