package elems;

import js.Browser;
import js.html.SelectElement;
import Protocol;
import ProtocolUtil;

using ProtocolUtil;

class SpellDiceDialog extends Popup {
    public function new(spellName:String, onAdd:SpellDice->Void) {
        super('Dé — $spellName');
        mainElem.classList.add("spell-dice-dialog");

        getContent().innerHTML = '
        <div class="spell-form">
            <div class="spell-row">
                <label>Raison</label>
                <input type="text" name="dice-reason" placeholder="ex: Dégâts, Soins" />
            </div>
            <div class="spell-row">
                <label>Type</label>
                <select name="dice-type">
                    <option value="MANUAL">Manuel</option>
                    <option value="NLS">NLS</option>
                    <option value="CONTACT_MELEE">Contact au corps à corps</option>
                    <option value="CONTACT_RANGED">Contact à distance</option>
                    <option value="CARACTERISTIC">Caractéristique</option>
                </select>
            </div>
            <div class="spell-row" id="manual-row">
                <label>Formule</label>
                <input type="text" name="dice-formula" placeholder="ex: 1d8+NLS, (NLS/3)d6" />
            </div>
            <div class="spell-row hidden" id="carac-row">
                <label>Caractéristique</label>
                <select name="dice-carac">
                    <option value="STRENGTH">Force</option>
                    <option value="DEXTERITY">Dextérité</option>
                    <option value="CONSTITUTION">Constitution</option>
                    <option value="INTELLIGENCE">Intelligence</option>
                    <option value="WISDOM">Sagesse</option>
                    <option value="CHARISMA">Charisme</option>
                </select>
            </div>
            <div class="actions">
                <a class="validate">Ajouter</a>
            </div>
        </div>';

        var typeSelect:SelectElement = cast getContent().querySelector('[name=dice-type]');
        var manualRow = getContent().querySelector("#manual-row");
        var caracRow = getContent().querySelector("#carac-row");

        typeSelect.addEventListener("change", () -> {
            if (typeSelect.value == "MANUAL") {
                manualRow.classList.remove("hidden");
                caracRow.classList.add("hidden");
            } else if (typeSelect.value == "CARACTERISTIC") {
                manualRow.classList.add("hidden");
                caracRow.classList.remove("hidden");
            } else {
                manualRow.classList.add("hidden");
                caracRow.classList.add("hidden");
            }
        });

        getContent().querySelector("a.validate").addEventListener("click", () -> {
            var typeStr = typeSelect.value;
            var diceType = if (typeStr == "CARACTERISTIC") {
                CARACTERISTIC(Characteristic.createByName(inputValue("dice-carac")));
            } else if (typeStr == "CONTACT_MELEE") {
                CONTACT_MELEE;
            } else if (typeStr == "CONTACT_RANGED") {
                CONTACT_RANGED;
            } else if (typeStr == "NLS") {
                NLS;
            } else if (typeStr == "MANUAL") {
                MANUAL(inputValue("dice-formula"));
            } else {
                throw 'Unknown dice type: $typeStr';
            };
            var reason = inputValue("dice-reason");
            if (reason == "") return;
            onAdd({diceType: diceType, reason: reason});
            close();
        });
    }
}
