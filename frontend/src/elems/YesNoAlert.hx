package elems;

import js.Browser;

class YesNoAlert extends Popup {
	var onNo:Void->Void;

	static var currentlyOpen:YesNoAlert;

	public function new(title:String, message:String, onYes:Void->Void, ?onNo:Void->Void) {
		if (currentlyOpen != null)
			return;

		super(title);

		this.onNo = onNo;
		currentlyOpen = this;

		mainElem.classList.add("yesno");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
        <p></p>
        <div class='actions'>
            <a class='yes'>Oui</a><a class='no'>Non</a>
        </div>
        ";

		mainElem.querySelector("p").innerText = message;
		mainElem.querySelector(".actions a.yes").addEventListener("click", closeAnswer.bind(onYes));
		mainElem.querySelector(".actions a.no").addEventListener("click", closeAnswer.bind(onNo));
	}

	override public function close() {
		if (onNo != null)
			onNo();

		currentlyOpen = null;

		super.close();
	}

	function closeAnswer(thenCall:Null<Void->Void>) {
		super.close();
		currentlyOpen = null;

		if (thenCall != null)
			thenCall();
	}
}
