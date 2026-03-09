package elems;

import js.html.OptionElement;
import js.html.SelectElement;
import js.Browser;

class NPCWeaponDialog extends Popup {
	public function new(onChoice:NPCWeapon->Void) {
		super("Ajouter une arme");
		mainElem.classList.add("weapon");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
		<div class='input-field'>
			<label>Nom</label>
			<input type='text' name='name' />
		</div>
		<div class='input-field'>
			<label>Bonus pour toucher</label>
			<input type='number' name='attack-bonus' value='0' />
		</div>
		<div class='input-field'>
			<label>Dégâts (ex: 2d8 + 3)</label>
			<input type='text' name='damage' />
		</div>
		<div class='input-field'>
			<label>Type de dégâts</label>
			<select multiple='multiple' name='damage-types'>
				<option value='PERFORANT'>Perforant</option>
				<option value='TRANCHANT'>Tranchant</option>
				<option value='CONTONDANT'>Contondant</option>
			</select>
		</div>
		<div class='input-field'>
			<label>Nombres critiques (ex: 19,20)</label>
			<input type='text' name='critical-nums' value='20' />
		</div>
		<div class='input-field'>
			<label>Multiplicateur critique (ex: 2)</label>
			<input type='number' name='critical-mult' value='2' />
		</div>
		<div class='input-field'>
			<label>Note</label>
			<input type='text' name='note' />
		</div>
		<div class='actions'>
			<a class='validate'>Valider</a>
		</div>";

		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			var noteStr = inputValue("note");
			var weapon:NPCWeapon = {
				name: inputValue("name"),
				attackBonus: inputValue("attack-bonus").parseInt(),
				damage: inputValue("damage"),
				damageTypes: [
					for (i in (cast getContent().querySelector("select[name=damage-types]") : SelectElement).selectedOptions) i
				].map(n -> WeaponDamageType.createByName((cast n : OptionElement).value)),
				criticalNums: inputValue("critical-nums").split(",").map(s -> s.trim().parseInt()),
				criticalMultiplier: inputValue("critical-mult").parseInt(),
				note: if (noteStr == "") null else noteStr,
			};
			onChoice(weapon);
			close();
		});

		Browser.document.body.appendChild(mainElem);
	}
}
