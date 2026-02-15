import js.Browser;
import jsasync.IJSAsync;

using DateTools;

class DiceRollHistory extends Popup implements IJSAsync {
	var fiche_id:String;

	public function new(fiche_id:String) {
		super("Lancés de dés");

		this.fiche_id = fiche_id;

		fill();
	}

	@:jsasync function fill() {
		var list = Browser.document.createUListElement();

		var data = Api.getRolls(fiche_id).jsawait();
		data.reverse();
		for (i in data) {
			var elem = Browser.document.createLIElement();
			elem.innerHTML = '${Date.fromTime(i.ts).format("%d/%m/%y %H:%I:%S")}, 1d${i.faces} ${i.field_name} : ${i.result}';
			list.appendChild(elem);
		}

		getContent().appendChild(list);
	}
}
