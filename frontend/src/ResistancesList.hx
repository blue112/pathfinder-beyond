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
			elem.innerHTML = '<a class="del">[Supprimer]</a> <strong>${damageType.damageTypeToString()}</strong>: ${resistances.get(damageType)}';
			list.appendChild(elem);
			elem.querySelector(".del").addEventListener("click", () -> {
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
