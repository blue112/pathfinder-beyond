import js.html.DivElement;
import js.Browser;

class Popup {
    var mainElem:DivElement;

    public function new(title:String) {
        var popup = Browser.document.createDivElement();
        popup.classList.add("popup");
        popup.innerHTML = '<div class="backdrop"></div>
        <div class="main">
            <h2>${title.htmlEscape()}</h2>
            <a class="close">X</a>
            <div class="content"></div>
        </div>';
        this.mainElem = popup;

        Browser.document.body.appendChild(popup);

        popup.querySelector(".close").addEventListener("click", close);
        popup.querySelector(".backdrop").addEventListener("click", close);
        popup.querySelector(".main").addEventListener("keydown", (e:js.html.KeyboardEvent) -> {
            if (e.key != "Enter") return;
            var target:js.html.Element = cast e.target;
            if (target.tagName.toLowerCase() == "textarea") return;
            var validateBtn = mainElem.querySelector("a.validate");
            if (validateBtn != null) validateBtn.click();
        });
    }

    public function getContent() {
        return mainElem.querySelector("div.content");
    }

    public function inputValue(name:String):String {
        return ((cast getContent().querySelector('[name=$name]') : Dynamic).value : String).trim();
    }

    public function setValue(name:String, value:String) {
        (cast getContent().querySelector('[name=$name]') : Dynamic).value = value;
    }

    public function close() {
        Browser.document.body.removeChild(mainElem);
    }
}
