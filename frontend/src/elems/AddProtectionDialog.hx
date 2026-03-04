package elems;

import js.html.SelectElement;
import js.html.InputElement;

class AddProtectionDialog extends Popup {
	public function new(onChoice:Protection->Void) {
		super("Ajouter une protection");
		mainElem.classList.add("weapon");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
		<div class='input-field'>
			<label>Nom</label>
			<input type='text' name='name' />
		</div>
		<div class='input-field'>
			<label>Type</label>
			<select name='type'>
				<option value='ARMOR'>Armure</option>
				<option value='SHIELD'>Bouclier</option>
				<option value='NATURAL_ARMOR'>Armure naturelle</option>
				<option value='EVADE'>Esquive</option>
			</select>
		</div>
		<div class='input-field'>
			<label>Bonus de CA</label>
			<input type='number' name='armor' value='0' />
		</div>
		<div class='input-field'>
			<label>DEX max (vide = illimité)</label>
			<input type='number' name='max-dex' />
		</div>
		<div class='input-field'>
			<label>Malus armure (compétences FOR/DEX)</label>
			<input type='number' name='armor-malus' value='0' />
		</div>
		<div class='actions'>
			<a class='validate'>Valider</a>
		</div>";

		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			var maxDexStr = (cast mainElem.querySelector("input[name=max-dex]") : InputElement).value;
			var armorMalusVal = (cast mainElem.querySelector("input[name=armor-malus]") : InputElement).value.parseInt();
			if (armorMalusVal > 0) {
				new Alert("Valeur invalide", "Le malus armure doit être négatif ou nul.");
				return;
			}
			var protection:Protection = {
				name: (cast mainElem.querySelector("input[name=name]") : InputElement).value,
				type: ProtectionType.createByName((cast mainElem.querySelector("select[name=type]") : SelectElement).value),
				armor: (cast mainElem.querySelector("input[name=armor]") : InputElement).value.parseInt(),
				max_dex: if (maxDexStr == "") null else maxDexStr.parseInt(),
				armorMalus: if (armorMalusVal == 0) null else armorMalusVal,
			};
			onChoice(protection);
			close();
		});
	}
}
