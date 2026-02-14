import js.html.DivElement;
import js.Browser;

class D20 {
	static public function roll() {
		var backdrop = if (Browser.document.getElementById("backdrop") != null) Browser.document.getElementById("backdrop") else {
			var backdrop = Browser.document.createDivElement();
			backdrop.classList.add("backdrop");
			backdrop.id = "backdrop";
			Browser.document.body.append(backdrop);
			backdrop.addEventListener("click", () -> {
				Browser.document.body.classList.remove("rolling");
			});
			backdrop;
		}

		Browser.document.body.classList.add("rolling");

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
            </div>';
		Browser.document.body.append(d20Tray);
		var d20:DivElement = cast d20Tray.querySelector(".die-d20");
		d20.dataset.face = (Std.random(20) + 1).string();
	}
}
