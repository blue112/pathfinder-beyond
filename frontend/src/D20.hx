import haxe.Timer;
import js.html.DivElement;
import js.Browser;

class D20 {
	static public function roll(mod:Int) {
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

		var dice = Std.random(20) + 1;

		var d20Tray = Browser.document.createDivElement();
		d20Tray.classList.add("dice-tray");
		d20Tray.innerHTML = '
        <div class="d20-container">
            <div class="die-d20 rolling">
                    <figure class="face face-1"></figure>
                    <figure class="face face-2"></figure>
                    <figure class="face face-3"></figure>
                    <figure class="face face-4"></figure>
                    <figure class="face face-5"></figure>
                    <figure class="face face-6"></figure>
                    <figure class="face face-7"></figure>
                    <figure class="face face-8"></figure>
                    <figure class="face face-9"></figure>
                    <figure class="face face-10"></figure>
                    <figure class="face face-11"></figure>
                    <figure class="face face-12"></figure>
                    <figure class="face face-13"></figure>
                    <figure class="face face-14"></figure>
                    <figure class="face face-15"></figure>
                    <figure class="face face-16"></figure>
                    <figure class="face face-17"></figure>
                    <figure class="face face-18"></figure>
                    <figure class="face face-19"></figure>
                    <figure class="face face-20"></figure>
                </div>
            </div>
            <h3>-</h3>
            <h3 class="critical critical-fail">Échec critique !</h3>
            <h3 class="critical critical-success">Réussite critique !</h3>
            ';
		Browser.document.body.append(d20Tray);
		var d20:DivElement = cast d20Tray.querySelector(".die-d20");
		d20.dataset.face = dice.string();
		Timer.delay(() -> {
			d20Tray.querySelector("h3").innerText = 'Résultat: ${dice + mod}';
			if (mod != null) {
				d20Tray.querySelector("h3").innerText += ' ($dice + $mod)';
			}
			d20Tray.classList.add("reveal");
			var cls = if (dice == 20) {
				"critical-success";
			} else if (dice == 1) "critical-fail"; else null;
			if (cls != null) {
				backdrop.classList.add(cls);
				d20Tray.classList.add(cls);
			}
		}, 1000);
	}
}
