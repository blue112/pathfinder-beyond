package elems;

import js.html.MouseEvent;
import js.html.InputElement;
import js.Browser;

class StringDialog extends Popup {
	public var reasonInput:InputElement;

	public function new(title:String, message:String, ?defaultValue:String = "", onChoice:String->Void) {
		super(title);

		mainElem.classList.add("str");
		mainElem.classList.add("alert");

		getContent().innerHTML = "<p></p>
		<div class='str'>
			<input type='text' />
		</div>
        <div class='actions'>
            <a class='validate'>Valider</a>
        </div>";

		mainElem.querySelector("p").innerText = message;
		reasonInput = cast mainElem.querySelector(".str input");
		reasonInput.value = defaultValue;
		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			onChoice(reasonInput.value);
			close();
		});

		Browser.document.body.appendChild(mainElem);
	}
}
