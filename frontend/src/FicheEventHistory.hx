import js.html.MouseEvent;
import RulesSkills;
import js.Browser;
import jsasync.IJSAsync;

using DateTools;

class FicheEventHistory extends Popup implements IJSAsync {
	var fiche_id:String;

	public function new(fiche_id:String, events:Array<FicheEventTs>) {
		super("Historique de la fiche");

		getContent().classList.add("event-history");

		var currentMods = [];
		var currentItems = [];
		this.fiche_id = fiche_id;

		var list = Browser.document.createUListElement();

		for (i in events) {
			var elem = Browser.document.createLIElement();
			var event = switch (i.type) {
				case CREATE(_): "Création du personnage";
				case SET_CHARACTERISTICS(_): "Lancer de caractéristiques initial";
				case ADD_TEMPORARY_MODIFIER(mod):
					currentMods.push(mod);
					'Ajout d\'un modificateur temporaire (${mod.mod.asMod()}, ${mod.why})';
				case REMOVE_TEMPORARY_MODIFIER(n):
					var mod = currentMods.splice(n, 1)[0];
					'Retrait d\'un modificateur temporaire (${mod.why})';
				case ADD_CLASS_SKILL(skill): 'Ajout d\'une compétence de classe (${RulesSkills.getSkillLabel(skill)})';
				case SET_SKILL_MODIFIER(skill, mod): 'Ajout d\'un modificateur de compétence (${RulesSkills.getSkillLabel(skill)}): ${mod.asMod()}';
				case CHANGE_CARAC(c, amount): 'Modification ${c.caracToString(true)} : ${amount.asMod()}';
				case ADD_WEAPON(weapon): 'Ajout d\'une arme (${weapon.name.htmlEscape()})';
				case TRAIN_SKILL(skill): 'Ajout d\'un rang dans une capacité (${RulesSkills.getSkillLabel(skill)})';
				case DECREASE_SKILL(skill): 'Retrait d\'un rang dans une capacité (${RulesSkills.getSkillLabel(skill)})';
				case CHANGE_HP(amount) if (amount > 0): 'Récupération de points de vie (${amount} pv)';
				case CHANGE_HP(amount): 'Dégats subis (${- amount} pv)';
				case CHANGE_MONEY(amount) if (amount > 0): 'Gain d\'argent (${amount} PO)';
				case CHANGE_MONEY(amount): 'Perte d\'argent (${- amount} po)';
				case CHANGE_MAX_HP(amount): 'Changement des PV max (${amount.asMod()} pv)';
				case LEVEL_UP(dice): 'Montée d\'un niveau ! Dé de vie = + $dice pv';
				case ADD_PROTECTION(armor): 'Ajout ${switch (armor.type) {
					case ARMOR: "d'une armure";
					case SHIELD: "d'un bouclier";
					case NATURAL_ARMOR: "d'une armure naturelle";
				}}: ${armor.name} (+${armor.armor} CA)';
				case ADD_INVENTORY_ITEM(item):
					currentItems.push(item);
					'Ajout d\'un objet à l\'inventaire: ${item.name} (x${item.quantity})';
				case CHANGE_ITEM_QUANTITY(item_n, new_quantity):
					var item = currentItems[item_n];
					'Ajout changement de quantité d\'un objet: ${item.name} (x${new_quantity})';
				case REMOVE_INVENTORY_ITEM(item_n):
					var item = currentItems.splice(item_n, 1)[0];
					'Suppression d\'un objet de l\'inventaire: ${item.name}';
				case ADD_EXCEPTIONAL_SKILL_MODIFIER(skill, mod,
					why): 'Ajout d\'un modificateur exceptionnel sur ${RulesSkills.getSkillLabel(skill)}: ${mod.asMod()} (${why.htmlEscape()})';
			}
			elem.innerHTML = '<a class="del">x</a> <small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%M:%S")}]</small> $event';
			list.appendChild(elem);
			elem.querySelector(".del").addEventListener("click", (e:MouseEvent) -> {
				if (e.shiftKey) {
					trace(Api.delEvent(fiche_id, i.id).then((_) -> {
						list.removeChild(elem);
					}));
				} else {
					trace('Ignored, must press shift');
				}
			});
		}

		getContent().appendChild(list);
	}
}
