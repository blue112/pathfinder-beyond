package elems;

import Protocol.DamageType;
import js.html.MouseEvent;
import js.html.Element;
import js.html.DivElement;
import js.Browser;

class DamageTypeSelector {
    var container:DivElement;

    public var selectedType(default, null):DamageType = UNTYPED;

    public function new() {
        container = Browser.document.createDivElement();
        container.className = "damage-types";
        container.innerHTML = "
            <p class='damage-types-label'>Quel est le type de dégats ?</p>
            <div class='category'>
                <span class='cat-label'>Physique</span>
                <a class='type-btn' data-type='BLUDGEONING'>Contondant</a>
                <a class='type-btn' data-type='PIERCING'>Perforant</a>
                <a class='type-btn' data-type='SLASHING'>Tranchant</a>
            </div>
            <div class='category'>
                <span class='cat-label'>Énergie</span>
                <a class='type-btn' data-type='ACID'>Acide</a>
                <a class='type-btn' data-type='COLD'>Froid</a>
                <a class='type-btn' data-type='ELECTRICITY'>Électricité</a>
                <a class='type-btn' data-type='FIRE'>Feu</a>
                <a class='type-btn' data-type='SONIC'>Sonique</a>
                <a class='type-btn' data-type='FORCE'>Force</a>
            </div>
            <div class='category'>
                <span class='cat-label'>Autre</span>
                <a class='type-btn' data-type='POSITIVE'>Positif</a>
                <a class='type-btn' data-type='NEGATIVE'>Négatif</a>
                <a class='type-btn' data-type='CHAOTIC'>Chaotique</a>
                <a class='type-btn' data-type='EVIL'>Mal</a>
                <a class='type-btn' data-type='GOOD'>Bien</a>
                <a class='type-btn' data-type='LAWFUL'>Loi</a>
                <a class='type-btn selected' data-type='UNTYPED'>Sans type</a>
            </div>";

        var typeButtons = container.querySelectorAll(".type-btn");
        for (i in 0...typeButtons.length) {
            var btn:Element = cast typeButtons.item(i);
            btn.addEventListener("click", (_:MouseEvent) -> {
                for (j in 0...typeButtons.length)
                    (cast typeButtons.item(j) : js.html.Element).classList.remove("selected");
                btn.classList.add("selected");
                selectedType = DamageType.createByName(btn.getAttribute("data-type"));
            });
        }
    }

    public function getElement():DivElement {
        return container;
    }
}
