package elems;

import Protocol.DamageType;

class ResistanceChoice extends AmountChoice {
	public function new(onChoice:Int->DamageType->Void) {
		var selector = new DamageTypeSelector();
		super("Ajouter une résistance", "Nombre de points de résistance ?", null, (amount, _) -> {
			onChoice(amount, selector.selectedType);
		});
		mainElem.classList.add("damage");
		getContent().insertBefore(selector.getElement(), getContent().querySelector(".actions"));
	}
}
