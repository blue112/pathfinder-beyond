package elems;

import Protocol.DamageType;
import js.html.MouseEvent;
import js.html.Element;
import js.Browser;

class NPCDamageReductionDialog extends AmountChoice {
	public function new(currentDamageReduction:Null<NPCDamageReduction>, onChoice:NPCDamageReduction->Void) {
		var selectedTypes:Array<DamageType> = if (currentDamageReduction != null) currentDamageReduction.bypassTypes.copy() else [];

		super("Résistance aux Dommages (RD)", "Valeur de RD",
			if (currentDamageReduction != null) {defaultValue: currentDamageReduction.amount} else null,
			(amount, _) -> {
				onChoice({amount: amount, bypassTypes: selectedTypes.copy()});
			});
		mainElem.classList.add("damage");

		var typesContainer = Browser.document.createDivElement();
		typesContainer.innerHTML = "
		<p class='damage-types-label'>Types qui contournent la RD<br><small>(aucun = RD/&mdash;)</small></p>
		<div class='damage-types'>
			<div class='category'>
				<span class='cat-label'>Physique</span>
				<a class='type-btn' data-type='BLUDGEONING'>Contondant</a>
				<a class='type-btn' data-type='PIERCING'>Perforant</a>
				<a class='type-btn' data-type='SLASHING'>Tranchant</a>
			</div>
			<div class='category'>
				<span class='cat-label'>Alignement</span>
				<a class='type-btn' data-type='CHAOTIC'>Chaotique</a>
				<a class='type-btn' data-type='EVIL'>Mal</a>
				<a class='type-btn' data-type='GOOD'>Bien</a>
				<a class='type-btn' data-type='LAWFUL'>Loi</a>
			</div>
		</div>";

		var typeButtons = typesContainer.querySelectorAll(".type-btn");
		for (i in 0...typeButtons.length) {
			var btn:Element = cast typeButtons.item(i);
			var type = DamageType.createByName(btn.getAttribute("data-type"));
			if (selectedTypes.has(type))
				btn.classList.add("selected");
			btn.addEventListener("click", function(_:MouseEvent):Void {
				if (btn.classList.contains("selected")) {
					btn.classList.remove("selected");
					selectedTypes.remove(type);
				} else {
					btn.classList.add("selected");
					selectedTypes.push(type);
				}
			});
		}

		getContent().insertBefore(typesContainer, getContent().querySelector(".actions"));
	}
}
