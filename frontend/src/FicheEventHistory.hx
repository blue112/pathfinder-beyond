import RulesSkills;
import js.Browser;
import jsasync.IJSAsync;

using DateTools;

class FicheEventHistory extends Popup implements IJSAsync {
	var fiche_id:String;

	public function new(fiche_id:String, events:Array<FicheEventTs>) {
		super("Historique de la fiche");

		this.fiche_id = fiche_id;

		var list = Browser.document.createUListElement();

		events = events.copy(); // So we can reverse
		events.reverse();
		for (i in events) {
			var elem = Browser.document.createLIElement();
			var event = switch (i.type) {
				case CREATE(_): "Création du personnage";
				case SET_CHARACTERISTICS(_): "Lancer de caractéristiques initial";
				case ADD_CLASS_SKILL(skill): 'Ajout d\'une compétence de classe (${RulesSkills.getSkillLabel(skill)})';
				case SET_SKILL_MODIFIER(skill, mod): 'Ajout d\'un modificateur de compétence (${RulesSkills.getSkillLabel(skill)}): ${mod.asMod()}';
				case CHANGE_CARAC(c, amount): 'Modification ${c.caracToString(true)} : ${amount.asMod()}';
				case ADD_WEAPON(weapon): 'Ajout d\'une arme (${weapon.name.htmlEscape()})';
				case TRAIN_SKILL(skill): 'Ajout d\'un rang dans une capacité (${RulesSkills.getSkillLabel(skill)})';
				case DECREASE_SKILL(skill): 'Retrait d\'un rang dans une capacité (${RulesSkills.getSkillLabel(skill)})';
				case CHANGE_HP(amount) if (amount > 0): 'Soins (${amount} pv)';
				case CHANGE_HP(amount): 'Dégats subis (${- amount} pv)';
				case CHANGE_MAX_HP(amount): 'Changement des PV max (${amount.asMod()} pv)';
				case LEVEL_UP(dice): 'Montée d\'un niveau ! Dé de vie = + $dice pv';
			}
			elem.innerHTML = '<a class="del">x</a> <small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%I:%S")}]</small> $event';
			list.appendChild(elem);
			elem.querySelector(".del").addEventListener("click", () -> {
				trace(Api.delEvent(fiche_id, i.id).then((_) -> {
					list.removeChild(elem);
				}));
			});
		}

		getContent().appendChild(list);
	}
}
