package elems;

class FreeDiceDialog extends ChoicesDialog {
	static var diceTypes = [2, 3, 4, 6, 8, 10, 12, 20, 100];

	static public var contactRolls = [
		{id: "contact-cac", label: "Jet de contact au corps à corps"},
		{id: "contact-distance", label: "Jet de contact à distance"},
	];

	public function new(onChoice:Int->Void) {
		var choices = diceTypes.map(d -> 'D$d').concat(contactRolls.map(r -> r.label));
		super("Lancer un dé", choices, onChoice);
		var notice = js.Browser.document.createParagraphElement();
		notice.className = "free-dice-notice";
		notice.innerText = "Ces lancers de dés sont pour les fonctionnalités non implémentées ! Pour lancer un dé lié à une partie de la fiche, cliquez sur le modificateur (+X) ou sur l'icône du D20 !";
		getContent().appendChild(notice);
	}

	static public function diceForIndex(i:Int) {
		return diceTypes[i];
	}

	static public function isContactRoll(i:Int) {
		return i >= diceTypes.length;
	}

	static public function contactRollForIndex(i:Int) {
		return contactRolls[i - diceTypes.length];
	}
}
