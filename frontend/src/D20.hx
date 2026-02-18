import haxe.Timer;
import js.html.DivElement;
import js.Browser;

@:expose("Dice")
class D20 {
	static public function roll(mod:Int, result:Int, numFaces:Int = 20) {
		var initialNumFaces = numFaces;
		var resultOnDice = result;

		var backdrop = if (Browser.document.getElementById("backdrop") != null) Browser.document.getElementById("backdrop") else {
			var backdrop = Browser.document.createDivElement();
			backdrop.classList.add("backdrop");
			backdrop.id = "backdrop";
			Browser.document.body.append(backdrop);
			backdrop.addEventListener("click", () -> {
				Browser.document.body.classList.remove("rolling");
				backdrop.className = "backdrop";
				var tray = Browser.document.body.querySelector(".dice-tray");
				Browser.document.body.removeChild(tray);
			});
			backdrop;
		}

		Browser.document.body.classList.add("rolling");

		if (numFaces == 3) {
			numFaces = 6;
			resultOnDice = (result * 2) - 1 + Std.random(2);
		}

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
		for (i in 0...numFaces) {
			var face = Browser.document.createElement("FIGURE");
			face.classList.add("face");
			face.classList.add('face-${i + 1}');
			dice.appendChild(face);
		}
		Browser.document.body.append(d20Tray);

		dice.dataset.face = resultOnDice.string();
		Timer.delay(() -> {
			d20Tray.querySelector("h3").innerText = 'Résultat: ${result + mod}';
			if (mod != null) {
				d20Tray.querySelector("h3").innerText += ' ($result + $mod)';
			}
			d20Tray.classList.add("reveal");

			var cls = if (numFaces == 20) {
				if (result == 20) {
					"critical-success";
				} else if (result == 1)
					"critical-fail";
				else
					null;
			} else null;

			if (cls != null) {
				backdrop.classList.add(cls);
				d20Tray.classList.add(cls);
			}
		}, 1000);
	}
}
