import haxe.Timer;
import js.html.DivElement;
import js.Browser;

@:expose("Dice")
class Dice {
    static function ensureBackdrop():js.html.Element {
        if (Browser.document.getElementById("backdrop") != null)
            return Browser.document.getElementById("backdrop");
        var backdrop = Browser.document.createDivElement();
        backdrop.classList.add("backdrop");
        backdrop.id = "backdrop";
        Browser.document.body.append(backdrop);
        backdrop.addEventListener("click", () -> {
            Browser.document.body.classList.remove("rolling");
            backdrop.className = "backdrop";
            var tray = Browser.document.body.querySelector(".dice-tray");
            if (tray != null) Browser.document.body.removeChild(tray);
        });
        return backdrop;
    }

    static function addFaces(die:DivElement, numFaces:Int) {
        for (i in 0...numFaces) {
            var face = Browser.document.createElement("FIGURE");
            face.classList.add("face");
            face.classList.add('face-${i + 1}');
            die.appendChild(face);
        }
    }

    static function randomPartition(n:Int, faces:Int, total:Int):Array<Int> {
        var results = [];
        var remaining = total;
        for (i in 0...n - 1) {
            var lo = Std.int(Math.max(1, remaining - (n - i - 1) * faces));
            var hi = Std.int(Math.min(faces, remaining - (n - i - 1)));
            var val = lo + Std.random(hi - lo + 1);
            results.push(val);
            remaining -= val;
        }
        results.push(remaining);
        return results;
    }

    static function rollD100(mods:Array<Int>, result:Int, ?note:String) {
        var backdrop = ensureBackdrop();
        Browser.document.body.classList.add("rolling");

        var tray = Browser.document.createDivElement();
        tray.classList.add("dice-tray");

        var tensFace = Math.floor((result - 1) / 10) + 1;
        var unitsFace = ((result - 1) % 10) + 1;

        tray.innerHTML = '
        <div class="dice-tray-row">
            <div class="dice-container">
                <div class="die-d10 die-d10-tens rolling"></div>
            </div>
            <div class="dice-container">
                <div class="die-d10 rolling"></div>
            </div>
        </div>
        <h3>-</h3>
        <h3 class="critical critical-fail">Échec critique !</h3>
        <h3 class="critical critical-success">Réussite critique !</h3>
        ';

        var dieTens:DivElement = cast tray.querySelector('.die-d10-tens');
        var dieUnits:DivElement = cast tray.querySelector('.die-d10:not(.die-d10-tens)');
        addFaces(dieTens, 10);
        addFaces(dieUnits, 10);
        dieUnits.style.animationDelay = '300ms';
        dieUnits.style.visibility = "hidden";
        Timer.delay(() -> dieUnits.style.visibility = "visible", 300);
        Browser.document.body.append(tray);

        dieTens.dataset.face = Std.string(Std.int(tensFace));
        dieUnits.dataset.face = Std.string(unitsFace);

        Timer.delay(() -> {
            var totalMod = mods.fold((m, r) -> m + r, 0);
            tray.querySelector("h3").innerText = 'Résultat: ${result + totalMod}';
            tray.classList.add("reveal");
            if (note != null) {
                var noteP = Browser.document.createParagraphElement();
                noteP.className = "roll-note";
                noteP.innerText = note;
                tray.appendChild(noteP);
            }
        }, 1300);
    }

    static function rollMulti(mods:Array<Int>, result:Int, numFaces:Int, numDice:Int, ?note:String) {
        var backdrop = ensureBackdrop();
        Browser.document.body.classList.add("rolling");

        var tray = Browser.document.createDivElement();
        tray.classList.add("dice-tray");

        var rowDiv = Browser.document.createDivElement();
        rowDiv.classList.add("dice-tray-row");

        var numFacesForDie = if (numFaces == 2 || numFaces == 3) 6 else numFaces;
        var diceValues = randomPartition(numDice, numFaces, result);
        var dieElements:Array<DivElement> = [];

        for (i in 0...numDice) {
            var container = Browser.document.createDivElement();
            container.classList.add("dice-container");
            var die = Browser.document.createDivElement();
            die.classList.add('die-d$numFaces');
            die.classList.add("rolling");
            die.style.animationDelay = '${i * 300}ms';
            if (i > 0) {
                die.style.visibility = "hidden";
                var dieRef = die;
                Timer.delay(() -> dieRef.style.visibility = "visible", i * 300);
            }
            addFaces(die, numFacesForDie);
            container.appendChild(die);
            rowDiv.appendChild(container);
            dieElements.push(die);
        }

        tray.appendChild(rowDiv);
        var h3 = (cast Browser.document.createElement("h3") : js.html.HeadingElement);
        h3.innerText = "-";
        tray.appendChild(h3);
        var failH3 = (cast Browser.document.createElement("h3") : js.html.HeadingElement);
        failH3.className = "critical critical-fail";
        failH3.innerText = "Échec critique !";
        tray.appendChild(failH3);
        var successH3 = (cast Browser.document.createElement("h3") : js.html.HeadingElement);
        successH3.className = "critical critical-success";
        successH3.innerText = "Réussite critique !";
        tray.appendChild(successH3);
        Browser.document.body.append(tray);

        for (i in 0...numDice)
            dieElements[i].dataset.face = Std.string(diceValues[i]);

        Timer.delay(() -> {
            var totalMod = mods.fold((m, r) -> m + r, 0);
            var modsStr = mods.map(i -> i.asMod(true)).join(" ");
            tray.querySelector("h3").innerText = 'Résultat: ${result + totalMod}';
            if (mods.length > 0)
                tray.querySelector("h3").innerText += ' ($result $modsStr)';
            tray.classList.add("reveal");
            if (note != null) {
                var noteP = Browser.document.createParagraphElement();
                noteP.className = "roll-note";
                noteP.innerText = note;
                tray.appendChild(noteP);
            }
        }, 1000 + (numDice - 1) * 300);
    }

    static public function roll(mods:Array<Int>, result:Int, numFaces:Int = 20, ?note:String, ?numDice:Int) {
        if (numFaces == 100) {
            rollD100(mods, result, note);
            return;
        }
        if (numDice != null && numDice > 1) {
            rollMulti(mods, result, numFaces, numDice, note);
            return;
        }

        var backdrop = ensureBackdrop();
        Browser.document.body.classList.add("rolling");

        var d20Tray = Browser.document.createDivElement();
        d20Tray.classList.add("dice-tray");

        d20Tray.innerHTML = '
        <div class="dice-container">
            <div class="die-d$numFaces rolling">
            </div>
        </div>
        <h3>-</h3>
        <h3 class="critical critical-fail">Échec critique !</h3>
        <h3 class="critical critical-success">Réussite critique !</h3>
            ';

        var dice:DivElement = cast d20Tray.querySelector('.die-d$numFaces');
        var numFacesForDie = if (numFaces == 2 || numFaces == 3) 6 else numFaces;
        addFaces(dice, numFacesForDie);
        Browser.document.body.append(d20Tray);

        dice.dataset.face = Std.string(result);
        Timer.delay(() -> {
            var totalMod = mods.fold((m, r) -> m + r, 0);
            d20Tray.querySelector("h3").innerText = 'Résultat: ${result + totalMod}';
            if (mods.length > 0) {
                var modsStr = mods.map(i -> i.asMod(true)).join(" ");
                d20Tray.querySelector("h3").innerText += ' ($result $modsStr)';
            }
            d20Tray.classList.add("reveal");

            var cls = if (numFaces == 20) {
                if (result == 20) "critical-success"
                else if (result == 1) "critical-fail"
                else null;
            } else null;

            if (cls != null) {
                backdrop.classList.add(cls);
                d20Tray.classList.add(cls);
            }
            if (note != null) {
                var noteP = Browser.document.createParagraphElement();
                noteP.className = "roll-note";
                noteP.innerText = note;
                d20Tray.appendChild(noteP);
            }
        }, 1000);
    }
}
