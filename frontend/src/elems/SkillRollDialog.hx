package elems;

import js.Browser;

class SkillRollDialog extends Popup {
	public function new(title:String, baseMod:Int, extraMod:Int) {
		super(title);
		mainElem.classList.add("alert");

		var roll = dice(20);
		var total = roll + baseMod + extraMod;
		var extraStr = if (extraMod != 0) ' ${extraMod.asMod(true)}' else '';

		getContent().innerHTML = "<p class='roll-line'></p>";
		mainElem.querySelector(".roll-line").innerHTML = '1d20 ${baseMod.asMod(true)}$extraStr : <span class="die-result">$roll</span> = <strong>$total</strong>';

		Browser.document.body.appendChild(mainElem);
	}
}
