package elems;

import js.Browser;

class SkillRollDialog extends Popup {
    public function new(title:String, baseMod:Int, extraMod:Int) {
        super(title);
        mainElem.classList.add("alert");

        var roll = dice(20);
        var total = roll + baseMod + extraMod;
        var extraStr = if (extraMod != 0) ' ${extraMod.asMod(true)}' else '';

        var rollLine = Browser.document.createParagraphElement();
        rollLine.className = "roll-line";
        rollLine.appendChild(Browser.document.createTextNode('1d20 ${baseMod.asMod(true)}$extraStr : '));
        var dieSpan = Browser.document.createSpanElement();
        dieSpan.className = "die-result";
        dieSpan.innerText = Std.string(roll);
        rollLine.appendChild(dieSpan);
        rollLine.appendChild(Browser.document.createTextNode(' = '));
        var totalEl:js.html.Element = cast Browser.document.createElement("strong");
        totalEl.innerText = Std.string(total);
        rollLine.appendChild(totalEl);
        getContent().appendChild(rollLine);

        Browser.document.body.appendChild(mainElem);
    }
}
