package elems;

import js.html.InputElement;
import js.Browser;

class ItemDialog extends AmountChoice {
	public function new(onSave:Int->String->Int->Void) {
		var priorityInput:InputElement = null;
		super("Ajouter un objet", "En quelle quantité ?", {defaultValue: 1, askReason: true},
			(qty, name) -> onSave(qty, name, if (priorityInput == null) 0 else priorityInput.value.parseInt()));

		getContent().querySelector(".reason label").innerText = "Nom de l'objet";

		var priorityDiv = Browser.document.createDivElement();
		priorityDiv.className = "reason";
		priorityDiv.innerHTML = "<label>Priorité</label><input type='number' min='-1000' max='1000' value='0' />";
		priorityInput = cast priorityDiv.querySelector("input");
		getContent().insertBefore(priorityDiv, getContent().querySelector(".actions"));
	}
}
