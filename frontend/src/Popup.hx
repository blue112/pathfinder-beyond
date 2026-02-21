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
	}

	public function getContent() {
		return mainElem.querySelector("div.content");
	}

	public function close() {
		Browser.document.body.removeChild(mainElem);
	}
}
