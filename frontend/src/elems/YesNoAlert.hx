package elems;

import js.html.DivElement;
import js.Browser;

class YesNoAlert extends Popup {
	var onNo:Void->Void;

	public function new(title:String, message:String, onYes:Void->Void, ?onNo:Void->Void) {
		super(title);

		this.onNo = onNo;

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

		Browser.document.body.appendChild(mainElem);
	}

	override public function close() {
		if (onNo != null)
			onNo();

		super.close();
	}

	function closeAnswer(thenCall:Null<Void->Void>) {
		super.close();

		if (thenCall != null)
			thenCall();
	}
}
