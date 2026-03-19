package elems;

import js.html.InputElement;
import Protocol.Characteristics;

class CaracInputDialog extends Popup {
    public function new(onChoice:Characteristics->Void) {
        super("Saisir les caractéristiques");
        mainElem.classList.add("alert");
        mainElem.classList.add("carac-input");

        getContent().innerHTML = "
            <div class='carac-row'><label>Force</label><input type='number' name='str' value='10' min='1' /></div>
            <div class='carac-row'><label>Dextérité</label><input type='number' name='dex' value='10' min='1' /></div>
            <div class='carac-row'><label>Constitution</label><input type='number' name='con' value='10' min='1' /></div>
            <div class='carac-row'><label>Intelligence</label><input type='number' name='int' value='10' min='1' /></div>
            <div class='carac-row'><label>Sagesse</label><input type='number' name='wis' value='10' min='1' /></div>
            <div class='carac-row'><label>Charisme</label><input type='number' name='cha' value='10' min='1' /></div>
            <div class='actions'>
                <a class='validate'>Valider</a>
            </div>";

        var getVal = (name:String) -> {
            var inp:InputElement = cast mainElem.querySelector('input[name="$name"]');
            return Std.parseInt(inp.value);
        };

        mainElem.querySelector("a.validate").addEventListener("click", () -> {
            onChoice({
                str: getVal("str"),
                dex: getVal("dex"),
                con: getVal("con"),
                int: getVal("int"),
                wis: getVal("wis"),
                cha: getVal("cha"),
            });
            close();
        });
    }
}
