package elems;

import js.Browser;
import Protocol;

using ProtocolUtil;

class SpellListPopup extends Popup {
    public function new(spells:Array<Spell>, onAdd:Spell->Void, onRemove:Int->Void) {
        super("Sorts");
        mainElem.classList.add("spell-list");
        render(spells, onAdd, onRemove);
    }

    function render(spells:Array<Spell>, onAdd:Spell->Void, onRemove:Int->Void) {
        var content = getContent();
        content.innerHTML = "<ul class='spell-list-ul'></ul><a class='add-new'>Ajouter un sort</a>";

        var sorted = spells.copy();
        sorted.sort((a, b) -> (if (a.priority == null) 0 else a.priority) - (if (b.priority == null) 0 else b.priority));

        var ul = content.querySelector("ul.spell-list-ul");

        for (spell in sorted) {
            var li = Browser.document.createLIElement();
            li.innerHTML = "<span class='spell-level'></span><span class='spell-school'></span><span class='spell-name'></span><a class='delete' title='Supprimer'>×</a>";
            li.querySelector(".spell-level").innerText = 'Niv.${spell.level}';
            li.querySelector(".spell-school").innerText = spell.school.spellSchoolToString();
            li.querySelector(".spell-name").innerText = spell.name;
            li.querySelector(".delete").addEventListener("click", () -> {
                new YesNoAlert("Effacer un sort", 'Supprimer le sort "${spell.name}" ?', () -> {
                    onRemove(spells.indexOf(spell));
                    close();
                });
            });
            ul.appendChild(li);
        }

        content.querySelector("a.add-new").addEventListener("click", () -> {
            new SpellDialog((spell) -> {
                onAdd(spell);
                close();
            });
        });
    }
}
