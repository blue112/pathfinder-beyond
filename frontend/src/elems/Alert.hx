package elems;

import js.Browser;

class Alert extends Popup {
	public function new(title:String, message:String) {
		super(title);

		mainElem.classList.add("alert");

		getContent().innerHTML = "<p></p>";

		mainElem.querySelector("p").innerText = message;

		Browser.document.body.appendChild(mainElem);
	}
}
