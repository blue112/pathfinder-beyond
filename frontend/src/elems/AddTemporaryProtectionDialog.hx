package elems;

import js.Browser;
import js.html.SelectElement;
import js.html.InputElement;

class AddTemporaryProtectionDialog extends Popup {
	public function new(onChoice:TemporaryModifier->Void) {
		super("Ajouter une protection temporaire");
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
            </select>
        </div>
        <div class='input-field'>
            <label>Bonus de CA</label>
            <input type='number' name='armor' value='0' />
        </div>
        <div class='actions'>
            <a class='validate'>Valider</a>
        </div>";

		for (i in ACType.createAll()) {
			var a = Browser.document.createOptionElement();
			a.value = i.getName();
			a.innerText = i.acTypeToString();
			getContent().querySelector('select').append(a);
		}

		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			var type = ACType.createByName((cast mainElem.querySelector("select[name=type]") : SelectElement).value);
			var name = (cast mainElem.querySelector("input[name=name]") : InputElement).value;
			var armor = (cast mainElem.querySelector("input[name=armor]") : InputElement).value.parseInt();

			onChoice({on: AC(type), why: name, mod: armor});
			close();
		});
	}
}
