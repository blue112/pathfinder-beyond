import elems.YesNoAlert;
import Protocol.DamageType;
import js.html.UListElement;
import js.Browser;

using ProtocolUtil;

class ResistancesList extends Popup {
    public function new(fiche_id:String, resistances:Map<DamageType, Int>) {
        super("Résistances actives");

        var list = Browser.document.createUListElement();
        var hasAny = false;
        for (damageType in resistances.keys()) {
            hasAny = true;
            var elem = Browser.document.createLIElement();
            var delBtn = Browser.document.createAnchorElement();
            delBtn.className = "del";
            delBtn.innerText = "[Supprimer]";
            var nameEl:js.html.Element = cast Browser.document.createElement("strong");
            nameEl.innerText = damageType.damageTypeToString();
            elem.appendChild(delBtn);
            elem.appendChild(Browser.document.createTextNode(' '));
            elem.appendChild(nameEl);
            elem.appendChild(Browser.document.createTextNode(': ${resistances.get(damageType)}'));
            list.appendChild(elem);
            delBtn.addEventListener("click", () -> {
                new YesNoAlert("Retirer une résistance", 'Supprimer la résistance ${damageType.damageTypeToString()} ?', () -> {
                    Api.pushEvent(fiche_id, REMOVE_DAMAGE_RESISTANCE(damageType));
                    resistances.remove(damageType);
                    close();
                });
            });
        }
        if (!hasAny)
            list.innerHTML = "<li>Aucune résistance active</li>";
        getContent().appendChild(list);
    }
}
