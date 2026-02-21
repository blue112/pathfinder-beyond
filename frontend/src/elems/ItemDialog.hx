package elems;

import js.html.TextAreaElement;
import js.Browser;

class ItemDialog extends AmountChoice {
	var textarea:TextAreaElement;

	public function new(onSave:Int->String->Void) {
		super("Ajouter un objet", "En quelle quantité ?", {defaultValue: 1, askReason: true}, onSave);

		getContent().querySelector(".reason label").innerText = "Nom de l'objet";
	}
}
