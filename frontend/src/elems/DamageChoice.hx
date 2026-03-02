package elems;

import Protocol.DamageType;

class DamageChoice extends AmountChoice {
	public function new(onChoice:Int->DamageType->Void) {
		var selector = new DamageTypeSelector();
		super("Retirer des PV (dégats)", "Combien de PV retirer ?", null, (amount, _) -> {
			onChoice(amount, selector.selectedType);
		});
		mainElem.classList.add("damage");
		getContent().insertBefore(selector.getElement(), getContent().querySelector(".actions"));
	}
}
