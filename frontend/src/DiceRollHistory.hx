import haxe.ds.StringMap;
import js.Browser;
import jsasync.IJSAsync;

using DateTools;

class DiceRollHistory extends Popup implements IJSAsync {
	var fiche_id:String;
	var fieldsNames:StringMap<String>;

	public function new(fiche_id:String, fieldsNames:StringMap<String>) {
		super("Derniers lancés de dés");

		this.fiche_id = fiche_id;
		this.fieldsNames = fieldsNames;

		fill();
	}

	@:jsasync function fill() {
		var list = Browser.document.createUListElement();

		var data = Api.getRolls(fiche_id).jsawait();
		data.reverse();
		for (i in data) {
			var elem = Browser.document.createLIElement();
			var fieldLabel = fieldsNames.get(i.field_name);
			if (fieldLabel == null)
				fieldLabel = 'FIXME(${i.field_name})';
			if (i.mod != null && i.mod != 0) {
				var mod = ' ${i.mod.asMod(true)}';
				elem.innerHTML = '<small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%M:%S")}]</small> <strong>${fieldLabel}</strong> 1d${i.faces}$mod : (<strong>${i.result}</strong>$mod) = <strong>${i.result + i.mod}</strong>';
			} else {
				elem.innerHTML = '<small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%M:%S")}]</small> <strong>${fieldLabel}</strong> 1d${i.faces} : <strong>${i.result}</strong>';
			}
			list.appendChild(elem);
		}

		getContent().appendChild(list);
	}
}
