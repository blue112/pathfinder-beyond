package elems;

import js.Browser;
import Protocol;
import ProtocolUtil;

using ProtocolUtil;

class SpellDetailPopup extends Popup {
    var onBack:Void->Void;

    public function new(spell:Spell, onBack:Void->Void) {
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

        addRow("École", spell.school.spellSchoolToString());
        addRow("Niveau", Std.string(spell.level));
        if (spell.shortDescription != null) addRow("Description courte", spell.shortDescription);
        addRow("Temps d'incantation", spell.castingTime.spellCastingTimeToString());
        var durationStr = spell.duration.spellDurationToString();
        addRow("Durée", if (spell.canEndVoluntarily) '$durationStr (peut être terminé volontairement)' else durationStr);
        addRow("Portée", spell.range.spellRangeToString());
        if (spell.components.length > 0) addRow("Composantes", spell.components.map(c -> c.spellComponentToString()).join(", "));
        if (spell.targets != "") addRow("Cibles", spell.targets);
        if (spell.areaOfEffect != null) addRow("Zone d'effet", spell.areaOfEffect);
        if (spell.savingThrowType != null) {
            addRow("Jet de sauvegarde", spell.savingThrowType.savingThrowToString());
            if (spell.saveEffect != null) addRow("Résultat de sauvegarde", spell.saveEffect.spellSaveEffectToString());
        }
        addRow("Résistance à la magie", if (spell.spellResistance) "Oui" else "Non");
        if (spell.usesPerDay != null) addRow("Utilisations / jour", Std.string(spell.usesPerDay));

        if (spell.longDescription != "") {
            var descBlock:js.html.Element = cast Browser.document.createElement("div");
            descBlock.className = "spell-long-desc";
            descBlock.innerText = spell.longDescription;
            content.insertBefore(descBlock, content.querySelector(".actions"));
        }

        content.querySelector("a.cast-btn").addEventListener("click", close);
    }

    override public function close() {
        super.close();
        onBack();
    }
}
