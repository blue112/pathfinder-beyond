import js.html.MenuElement;
import js.html.DivElement;
import js.html.MouseEvent;
import js.Browser;
import js.html.Element;

class ContextMenu {
	var menu:MenuElement;

	public var onClose:Void->Void;

	public function new(parentElement:Element, menuElements:Array<String>, onChoice:Int->Bool) {
		parentElement.classList.add("active");
		menu = Browser.document.createMenuElement();
		menu.innerHTML = "<ul></ul>";
		for (i in 0...menuElements.length) {
			var li = Browser.document.createLIElement();
			li.innerText = menuElements[i];
			li.addEventListener('click', (e:MouseEvent) -> {
				var shouldClose = onChoice(i);
				if (shouldClose) {
					close();
				}
				e.stopPropagation();
			});
			menu.querySelector("ul").appendChild(li);
		}
		parentElement.appendChild(menu);

		haxe.Timer.delay(() -> {
			Browser.document.body.addEventListener("click", onClick);
		}, 1);
	}

	function close() {
		menu.parentElement.classList.remove("active");
		menu.parentElement.removeChild(menu);
		Browser.document.body.removeEventListener("click", onClick);
		if (onClose != null)
			onClose();
	}

	function onClick(e:MouseEvent) {
		var t:Element = cast e.target;
		while (t != Browser.document.body) {
			if (t == menu)
				return;

			t = t.parentElement;
		}
		close();
	}
}
