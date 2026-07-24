import elems.YesNoAlert;
import Protocol.DamageType;
import js.Browser;

using ProtocolUtil;

class ProtectionsList extends Popup {
	var fiche_id:String;

	public function new(fiche_id:String, protections:Array<Protection>, char:FullCharacter) {
		super("Protections");
		this.fiche_id = fiche_id;

		protections = protections.map(n -> {
			n.isTemporary = false;
			return n;
		});

		for (i in char.tempMods.filter(n -> n.on.match(AC(_)))) {
			protections.push({
				name: i.why,
				armorMalus: null,
				max_dex: null,
				armor: i.mod,
				isTemporary: true,
				type: switch (i.on) {
					case AC(t): t;
					default: null;
				}
			});
		}

		refresh(protections, char);
	}

	function refresh(protections:Array<Protection>, char:FullCharacter) {
		getContent().innerHTML = "";
		var list = Browser.document.createTableElement();
		var headers = Browser.document.createTableRowElement();
		headers.innerHTML = "<th>Type</th><th>Nom</th><th>Type de bonus</th><th>Bonus</th><th>Mod dex maximal</th><th>Malus d'armure</th><th>Commentaire</th><th></th>";
		list.appendChild(headers);

		var activeProtections = Rules.getActiveProtections(char);

		for (i in 0...protections.length) {
			var p = protections[i];

			var line = Browser.document.createTableRowElement();
			var type = Browser.document.createTableCellElement();
			type.innerText = if (p.isTemporary) "Temporaire" else "Permanent";
			var name = Browser.document.createTableCellElement();
			name.innerText = p.name;
			var bonus_type = Browser.document.createTableCellElement();
			bonus_type.innerText = p.type.acTypeToString();
			var value = Browser.document.createTableCellElement();
			value.innerText = p.armor.asMod();
			var malus = Browser.document.createTableCellElement();
			malus.innerText = if (p.armorMalus != null) p.armorMalus.string() else "-";
			var max_dex = Browser.document.createTableCellElement();
			max_dex.innerText = if (p.max_dex != null) p.max_dex.string() else "-";
			var comment = Browser.document.createTableCellElement();
			comment.innerText = "";
			var remove = Browser.document.createTableCellElement();
			remove.innerText = "X";

			if (p.isTemporary) {
				line.classList.add("temporary");
				remove.innerText = "";
			}

			var isActive = activeProtections.get(p.type).exists(k -> k.name == p.name);
			if (!isActive) {
				line.classList.add("inactive");
				comment.classList.add("comment");
				var replacedBy = activeProtections.get(p.type)[0];
				comment.innerText = 'Annulé par ${replacedBy.name}';
			}

			line.append(type);
			line.append(name);
			line.append(bonus_type);
			line.append(value);
			line.append(malus);
			line.append(max_dex);
			line.append(comment);
			line.append(remove);

			remove.addEventListener("click", () -> {
				if (p.isTemporary)
					return;

				new YesNoAlert('Supprimer une protection', 'Supprimer la protection ${p.name} ?', () -> {
					Api.pushEvent(fiche_id, REMOVE_PROTECTION(char.protections.indexOf(p)));
					protections.splice(i, 1);
					refresh(protections, char);
				});
			});

			list.appendChild(line);
		};

		if (protections.length == 0)
			list.innerHTML = "<li>Aucune protection assignée</li>";

		getContent().classList.add("protections");
		getContent().appendChild(list);
	}
}
