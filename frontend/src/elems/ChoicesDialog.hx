package elems;

import js.Browser;

class ChoicesDialog extends Popup {
	public function new(title:String, choices:Array<String>, onChoice:Int->Void) {
		super(title);

		mainElem.classList.add("choices");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
        <div class='actions'>

        </div>
        ";

		for (i in 0...choices.length) {
			var choice = Browser.document.createAnchorElement();
			choice.innerText = choices[i];
			choice.addEventListener("click", () -> {
				close();
				onChoice(i);
			});
			mainElem.querySelector(".actions").appendChild(choice);
		}

		Browser.document.body.appendChild(mainElem);
	}
}
