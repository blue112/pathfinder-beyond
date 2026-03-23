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
    var ficheId:String;
    var editingPriorities:Bool = false;

    public function new(character:FullCharacter, pushEvent:FicheEventType->Void, register:(Null<SpellListPopup>)->Void, ficheId:String) {
        super("Sorts");
        this.character = character;
        this.pushEvent = pushEvent;
        this.register = register;
        this.ficheId = ficheId;
        mainElem.classList.add("spell-list");

        var editBtn = Browser.document.createAnchorElement();
        editBtn.className = "edit-priorities-btn";
        editBtn.innerText = "Priorités";
        editBtn.addEventListener("click", () -> {
            editingPriorities = !editingPriorities;
            editBtn.classList.toggle("active", editingPriorities);
            render();
        });
        mainElem.querySelector(".main").appendChild(editBtn);

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
            var aPower = a.usesPerDay != null && a.usesPerDay > 0;
            var bPower = b.usesPerDay != null && b.usesPerDay > 0;
            if (aPower != bPower) return if (aPower) -1 else 1;
            if (!aPower) {
                var lvlDiff = a.level - b.level;
                if (lvlDiff != 0) return lvlDiff;
            }
            return (if (a.priority == null) 0 else a.priority) - (if (b.priority == null) 0 else b.priority);
        });

        var isSpontaneous = character.basics.characterClass.canCastSpells() && !needsPrep;

        if (needsPrep && !character.preparationLocked) {
            var header = Browser.document.createParagraphElement();
            header.className = "prep-phase-header";
            header.innerText = "Phase de préparation";
            content.appendChild(header);

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

            if (allFull) {
                var endBtn = Browser.document.createAnchorElement();
                endBtn.className = "end-prep-btn";
                endBtn.innerText = "Terminer la préparation";
                endBtn.addEventListener("click", () -> {
                    new YesNoAlert("Terminer la préparation", "Confirmer la fin de la préparation des sorts ? Vous ne pourrez plus modifier vos sorts préparés jusqu'au prochain nouveau jour.", () -> {
                        pushEvent(SPELL_EVENT(FINISH_SPELL_PREPARATION));
                    });
                });
                content.appendChild(endBtn);
            }
        }

        if (isSpontaneous) {
            var slotSummary = Browser.document.createDivElement();
            slotSummary.className = "spell-slot-summary";
            for (spellLevel in 1...10) {
                if (slots[spellLevel] == 0) continue;
                var used = character.usedSlots.exists(spellLevel) ? character.usedSlots.get(spellLevel) : 0;
                var remaining = slots[spellLevel] - used;
                var badge = Browser.document.createSpanElement();
                badge.className = 'slot-badge ${if (remaining > 0) "full" else "incomplete"}';
                badge.innerText = 'Niv.$spellLevel : $remaining/${slots[spellLevel]}';
                slotSummary.appendChild(badge);
            }
            content.appendChild(slotSummary);
        }

        var hasPowers = spells.filter(s -> s.usesPerDay != null && s.usesPerDay > 0).length > 0;
        var showAvailable = (needsPrep && character.preparationLocked) || hasPowers;
        var inPrep = needsPrep && !character.preparationLocked;
        var ulClass = if (inPrep && hasPowers) "spell-list-ul has-prep has-available"
            else if (inPrep) "spell-list-ul has-prep"
            else if (showAvailable) "spell-list-ul has-available"
            else "spell-list-ul";
        var ul = Browser.document.createUListElement();
        ul.className = if (editingPriorities) '$ulClass has-priority' else ulClass;
        content.appendChild(ul);

        for (spell in sorted) {
            var originalIndex = spells.indexOf(spell);
            var isPower = spell.usesPerDay != null && spell.usesPerDay > 0;
            var li = Browser.document.createLIElement();

            if (showAvailable) {
                var availSpan = Browser.document.createSpanElement();
                if (isPower) {
                    var usedCount = character.usedPowers.exists(originalIndex) ? character.usedPowers.get(originalIndex) : 0;
                    var remaining = spell.usesPerDay - usedCount;
                    availSpan.className = 'spell-available ${if (remaining > 0) "has-charges" else "empty"}';
                    availSpan.innerText = '×$remaining';
                } else if (isSpontaneous) {
                    if (spell.level == 0) {
                        availSpan.className = "spell-available has-charges";
                        availSpan.innerText = "∞";
                    } else {
                        availSpan.className = "spell-available";
                    }
                } else {
                    var count = preparedSpells.filter(p -> p.spellIndex == originalIndex).length;
                    if (spell.level == 0 && count > 0) {
                        availSpan.className = "spell-available has-charges";
                        availSpan.innerText = "∞";
                    } else {
                        availSpan.className = 'spell-available ${if (count > 0) "has-charges" else "empty"}';
                        availSpan.innerText = '×$count';
                    }
                }
                li.appendChild(availSpan);
            }

            var levelSpan = Browser.document.createSpanElement();
            levelSpan.className = "spell-level";
            levelSpan.innerText = if (isPower) "Pouvoir" else 'Niv.${spell.level}';
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
                new SpellDetailPopup(spell, originalIndex, character, pushEvent, ficheId, () -> new SpellListPopup(character, pushEvent, register, ficheId));
            });
            li.appendChild(nameCell);

            if (inPrep && !isPower) {
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
                    if (prepCount > 0) pushEvent(SPELL_EVENT(UNPREPARE_SPELL(originalIndex)));
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
                    if (targetSlot >= 0) pushEvent(SPELL_EVENT(PREPARE_SPELL(originalIndex, targetSlot)));
                });

                prepControls.appendChild(countSpan);
                prepControls.appendChild(minusBtn);
                prepControls.appendChild(plusBtn);
                li.appendChild(prepControls);
            }

            if (editingPriorities) {
                var priorityCell = Browser.document.createSpanElement();
                priorityCell.className = "spell-priority-edit";
                var input = Browser.document.createInputElement();
                input.type = "number";
                input.value = Std.string(if (spell.priority == null) 0 else spell.priority);
                var validateBtn = Browser.document.createAnchorElement();
                validateBtn.className = "priority-validate-btn";
                validateBtn.innerText = "✓";
                validateBtn.addEventListener("click", () -> {
                    var val = Std.parseInt(input.value);
                    pushEvent(SPELL_EVENT(SET_SPELL_PRIORITY(originalIndex, val)));
                });
                priorityCell.appendChild(input);
                priorityCell.appendChild(validateBtn);
                li.appendChild(priorityCell);
            }

            var deleteBtn = Browser.document.createAnchorElement();
            deleteBtn.className = "delete";
            deleteBtn.title = "Supprimer";
            deleteBtn.innerText = "×";
            deleteBtn.addEventListener("click", () -> {
                new YesNoAlert("Effacer un sort", 'Supprimer le sort "${spell.name}" ?', () -> {
                    pushEvent(SPELL_EVENT(REMOVE_SPELL(originalIndex)));
                    close();
                });
            });
            li.appendChild(deleteBtn);

            ul.appendChild(li);
        }

        var addBtn = Browser.document.createAnchorElement();
        addBtn.className = "add-new";
        addBtn.innerText = "Ajouter un sort";
        var maxSpellLevel = Rules.getMaxSpellLevel(character.basics.characterClass, character);
        addBtn.addEventListener("click", () -> {
            new SpellDialog(character.basics.characterClass, maxSpellLevel, (spell) -> pushEvent(SPELL_EVENT(ADD_SPELL(spell))));
        });
        content.appendChild(addBtn);
    }
}
