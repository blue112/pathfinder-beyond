package elems;

import Protocol.DamageType;
import js.html.MouseEvent;
import js.html.Element;
import js.html.DivElement;
import js.Browser;

class StatusTypeSelector {
	var container:DivElement;

	public var selectedType(default, null):StatusType = null;

	public function new() {
		container = Browser.document.createDivElement();
		container.className = "status-types";
		container.innerHTML = "
            <p class='status-types-label'>Quel status ?</p>
            <div class='statuses'>
            </div>
            ";

		for (i in StatusType.createAll()) {
			// <a class='type-btn' data-type='BLUDGEONING'>Contondant</a>
			var btn = Browser.document.createAnchorElement();
			btn.classList.add("type-btn");
			btn.innerText = i.statusToString();
			btn.addEventListener("click", (_:MouseEvent) -> {
				for (j in container.querySelectorAll(".type-btn.selected"))
					(cast j : Element).classList.remove("selected");
				btn.classList.add("selected");
				selectedType = i;
			});
			container.querySelector(".statuses").appendChild(btn);
		}
	}

	public function getElement():DivElement {
		return container;
	}
}
