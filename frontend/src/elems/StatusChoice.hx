package elems;

import Protocol.DamageType;

class StatusChoice extends AmountChoice {
	public function new(onChoice:Int->StatusType->Void) {
		var selector = new StatusTypeSelector();
		super("Ajouter un status", "Combien de tours ?", null, (amount, _) -> {
			if (selector.selectedType != null)
				onChoice(amount, selector.selectedType);
		});
		mainElem.classList.add("status");
		getContent().insertBefore(selector.getElement(), getContent().querySelector(".actions"));
	}
}
