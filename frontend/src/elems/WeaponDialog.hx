package elems;

import js.html.OptionElement;
import js.html.SelectElement;
import js.html.InputElement;
import js.Browser;

class WeaponDialog extends Popup {
	public var reasonInput:InputElement;

	public function new(title:String, onChoice:Weapon->Void) {
		super(title);

		mainElem.classList.add("weapon");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
		<div class='input-field'>
			<label>Nom de l'arme</label>
			<input type='text' name='name' />
		</div>
		<div class='input-field'>
			<label>Type de jet pour toucher</label>
			<select name='attack-type'>
				<option value='DEXTERITY'>Dextérité (arme à distance)</option>
				<option value='STRENGTH'>Force (arme au corps à corps)</option>
			</select>
		</div>
		<div class='input-field'>
			<label>Bonus pour toucher (lié à l'arme)</label>
			<input type='number' name='attack-bonus' />
		</div>
		<div class='input-field'>
			<label>Dé de dégats (nombre de faces)</label>
			<input type='number' name='damage-dice' />
		</div>
		<div class='input-field'>
			<label>Type de jet de dégats</label>
			<select name='damage-type'>
				<option value='DEXTERITY'>Dextérité (arme à distance)</option>
				<option value='STRENGTH'>Force (arme au corps à corps)</option>
			</select>
		</div>
		<div class='input-field'>
			<label>Bonus de dégats (lié à l'arme)</label>
			<input type='number' name='damage-bonus' />
		</div>
		<div class='input-field'>
			<label>Nombres critiques (séparés par des virgules, généralement 20)</label>
			<input type='text' name='critical-nums' />
		</div>
		<div class='input-field'>
			<label>Multiplicateur critique (généralement 2)</label>
			<input type='number' name='critical-mult' />
		</div>
		<div class='input-field'>
			<label>Type de dégats</label>
			<select multiple='multiple' name='type'>
				<option value='PERFORANT'>Perforant</option>
				<option value='TRANCHANT'>Tranchant</option>
				<option value='CONTONDANT'>Contondant</option>
			</select>
		</div>
		<div class='input-field'>
			<label>(si applicable) Portée en cases</label>
			<input type='number' name='range' />
		</div>
		<div class='input-field'>
			<label>(si applicable) Munitions</label>
			<input type='string' name='ammo' />
		</div>
        <div class='actions'>
            <a class='validate'>Valider</a>
        </div>";

		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			var w:Weapon = {
				name: (cast mainElem.querySelector("input[name=name]")).value,
				munitions: (cast mainElem.querySelector("input[name=ammo]")).value,
				range: (cast mainElem.querySelector("input[name=range]") : InputElement).value.parseInt(),
				damage_types: [
					for (i in (cast mainElem.querySelector("select[name=type]") : SelectElement).selectedOptions)
						i
				].map((n) -> {
					return WeaponDamageType.createByName((cast n : OptionElement).value);
				}),
				critical_text: {
					nums: (cast mainElem.querySelector("input[name=critical-nums]") : InputElement).value.split(",").map(s -> s.parseInt()),
					damageMultiplier: (cast mainElem.querySelector("input[name=critical-mult]") : InputElement).value.parseInt()
				},
				damage_modifier: (cast mainElem.querySelector("input[name=damage-bonus]") : InputElement).value.parseInt(),
				weaponDamageCharacteristic: Characteristic.createByName((cast mainElem.querySelector("select[name=damage-type]") : SelectElement).value),
				weaponAttackCharacteristic: Characteristic.createByName((cast mainElem.querySelector("select[name=attack-type]") : SelectElement).value),
				weaponHasPlus50PercentDamage: false,
				attack_modifier: (cast mainElem.querySelector("input[name=attack-bonus]") : InputElement).value.parseInt(),
				damage_dices: [
					(cast mainElem.querySelector("input[name=damage-dice]") : InputElement)
					.value.parseInt()
				],
			};

			onChoice(w);
			close();
		});

		Browser.document.body.appendChild(mainElem);
	}
}
