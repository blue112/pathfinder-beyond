class Formatter {
    public static function asMod(n:Int, ?withSpace:Bool) {
        if (n > 0)
            return if (withSpace) '+ $n' else '+$n';
        if (n < 0)
            return if (withSpace) '- ${- n}' else '$n';

        return if (withSpace) '+ 0' else '+0';
    }

    static public function appendDiceroll(roll:PublicDiceRoll, parent:js.html.Element) {
        var count = if (roll.count != null && roll.count > 1) roll.count else 1;
        var diceStr = '${count}d${roll.faces}';
        if (roll.mod != null && roll.mod != 0) {
            var mod = ' ${roll.mod.asMod(true)}';
            parent.appendChild(js.Browser.document.createTextNode('$diceStr$mod : ('));
            var r1:js.html.Element = cast js.Browser.document.createElement("strong");
            r1.innerText = Std.string(roll.result);
            parent.appendChild(r1);
            parent.appendChild(js.Browser.document.createTextNode('$mod) = '));
            var r2:js.html.Element = cast js.Browser.document.createElement("strong");
            r2.innerText = Std.string(roll.result + roll.mod);
            parent.appendChild(r2);
        } else {
            parent.appendChild(js.Browser.document.createTextNode('$diceStr : '));
            var r:js.html.Element = cast js.Browser.document.createElement("strong");
            r.innerText = Std.string(roll.result);
            parent.appendChild(r);
        }
    }
}
