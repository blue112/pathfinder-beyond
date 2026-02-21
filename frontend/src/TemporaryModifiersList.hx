import js.html.UListElement;
import elems.YesNoAlert;
import RulesSkills;
import js.Browser;
import jsasync.IJSAsync;

using DateTools;

class TemporaryModifiersList extends Popup implements IJSAsync {
	var fiche_id:String;
	var mods:Array<TemporaryModifier>;
	var list:UListElement;

	public function new(fiche_id:String, mods:Array<TemporaryModifier>) {
		super("Modificateurs temporaires actifs");

		getContent().classList.add("temp-modifiers");

		this.fiche_id = fiche_id;
		this.mods = mods.copy();

		list = Browser.document.createUListElement();

		refresh();

		getContent().appendChild(list);
	}

	function refresh() {
		list.innerHTML = "";

		if (mods.length == 0) {
			list.innerHTML = "<h2>Aucun modificateur temporaire actif</h2>";
			list.classList.add("empty");
		}

		for (n in 0...mods.length) {
			var mod = mods[n];
			var elem = Browser.document.createLIElement();
			var fieldName = switch (mod.on) {
				case CHARACTERISTIC(c): c.caracToString(false);
				case SKILL(type): RulesSkills.getSkillLabel(type);
				case AC: "CA";
				case INITIATIVE: "Initiative";
				case SAVING_THROW(st): 'Jet de sauvegarde (${st.savingThrowToString()})';
				case WEAPON_ATTACK: 'Jet d\'attaque';
				case WEAPON_DAMAGE: 'Jet de dommage';
				case MAX_HP: "PV maximums";
			}
			fieldName = fieldName.charAt(0).toUpperCase() + fieldName.substr(1);
			elem.innerHTML = '<a class="del">[Supprimer]</a> <strong>$fieldName</strong> - ${mod.mod.asMod()} (${mod.why.htmlEscape()})';
			list.appendChild(elem);
			elem.querySelector(".del").addEventListener("click", () -> {
				new YesNoAlert("Retirer un modificateur temporaire", 'Supprimer le modificateur temporaire sur ${fieldName} ?', () -> {
					Api.pushEvent(fiche_id, REMOVE_TEMPORARY_MODIFIER(n));
					mods.splice(n, 1);
					refresh();
				});
			});
		}
	}
}
