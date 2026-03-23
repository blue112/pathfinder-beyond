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

        var data:Array<PublicDiceRoll> = Api.getRolls(fiche_id).jsawait();
        data.reverse();
        for (i in data) {
            var elem = Browser.document.createLIElement();
            var fieldLabel = if (fieldsNames != null) fieldsNames.get(i.field_name) else i.field_name;
            if (fieldLabel == null)
                fieldLabel = 'FIXME(${i.field_name})';

            var timeEl:js.html.Element = cast Browser.document.createElement("small");
            timeEl.innerText = '[${Date.fromTime(i.ts).format("%d/%m/%y %H:%M:%S")}]';
            var nameEl:js.html.Element = cast Browser.document.createElement("strong");
            nameEl.innerText = fieldLabel;
            elem.appendChild(timeEl);
            elem.appendChild(Browser.document.createTextNode(' '));
            elem.appendChild(nameEl);
            elem.appendChild(Browser.document.createTextNode(' '));
            i.appendDiceroll(elem);
            list.appendChild(elem);
        }

        getContent().appendChild(list);
    }
}
