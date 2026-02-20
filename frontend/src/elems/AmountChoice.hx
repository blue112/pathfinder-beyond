package elems;

import js.html.MouseEvent;
import js.html.InputElement;
import js.Browser;

typedef AmountChoiceOptions = {
	?defaultValue:Int,
	?canBeNegative:Bool,
	?askReason:Bool,
}

class AmountChoice extends Popup {
	var input:InputElement;
	var options:AmountChoiceOptions;

	public var reasonInput:InputElement;

	public function new(title:String, message:String, ?options:AmountChoiceOptions, onChoice:Int->String->Void) {
		super(title);
		if (options == null)
			options = {};
		if (options.defaultValue == null)
			options.defaultValue = 0;
		if (options.canBeNegative == null)
			options.canBeNegative = false;
		if (options.askReason == null)
			options.askReason = false;

		this.options = options;

		mainElem.classList.add("amount");
		mainElem.classList.add("alert");
		if (options.askReason)
			mainElem.classList.add("ask-reason");

		getContent().innerHTML = "<p></p>
        <div class='input'>
            <a class='decrease'>&ndash;</a>
            <input type='text' inputmode='numeric' pattern='\\d*' value='0' min='0' />
            <a class='increase'>+</a>
        </div>
		<div class='reason'>
			<label>Raison</label>
			<input type='text' />
		</div>
        <div class='actions'>
            <a class='validate'>Valider</a>
        </div>";

		mainElem.querySelector("p").innerText = message;
		input = cast mainElem.querySelector(".input input");
		input.value = options.defaultValue.string();
		reasonInput = cast mainElem.querySelector(".reason input");
		mainElem.querySelector("a.decrease").addEventListener("click", changeAmount.bind(false));
		mainElem.querySelector("a.increase").addEventListener("click", changeAmount.bind(true));
		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			onChoice(input.value.parseInt(), reasonInput.value);
			close();
		});

		Browser.document.body.appendChild(mainElem);
	}

	function changeAmount(up:Bool, e:MouseEvent) {
		var amount = if (e.shiftKey) 5 else 1;
		if (!up)
			amount *= -1;

		var current = input.value.parseInt();
		current += amount;

		if (!options.canBeNegative)
			current = Math.max(current, 0).int();

		input.value = current.string();
	}
}
