package elems;

import js.Browser;
import js.html.SelectElement;

class SelectChoicePopup extends Popup {
    public function new(title:String, options:Array<{value:String, label:String}>, count:Int, onChoice:Array<String>->Void) {
        super(title);
        mainElem.classList.add("alert");
        mainElem.classList.add("select-choice");
        var content = getContent();

        var selects:Array<SelectElement> = [];
        for (_ in 0...count) {
            var select:SelectElement = cast Browser.document.createElement("select");
            select.className = "choice-select";
            for (opt in options) {
                var o = Browser.document.createOptionElement();
                o.value = opt.value;
                o.innerText = opt.label;
                select.appendChild(o);
            }
            content.appendChild(select);
            selects.push(select);
        }

        var validateBtn = Browser.document.createAnchorElement();
        validateBtn.className = "validate";
        validateBtn.innerText = "Valider";
        validateBtn.addEventListener("click", () -> {
            var values = selects.map(s -> s.value);
            close();
            onChoice(values);
        });
        content.appendChild(validateBtn);
    }
}
