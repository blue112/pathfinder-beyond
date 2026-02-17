import js.Browser;
import jsasync.IJSAsync;

using DateTools;

class FicheEventHistory extends Popup implements IJSAsync {
	var fiche_id:String;

	public function new(fiche_id:String, events:Array<FicheEventTs>) {
		super("Historique de la fiche");

		this.fiche_id = fiche_id;

		var list = Browser.document.createUListElement();

		events = events.copy(); // So we can reverse
		events.reverse();
		for (i in events) {
			var elem = Browser.document.createLIElement();
			elem.innerHTML = '<a class="del">x</a> <small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%I:%S")}]</small> <strong>${i.type.string()}</strong>';
			list.appendChild(elem);
			elem.querySelector(".del").addEventListener("click", () -> {
				trace(Api.delEvent(fiche_id, i.id).then((_) -> {
					list.removeChild(elem);
				}));
			});
		}

		getContent().appendChild(list);
	}
}
