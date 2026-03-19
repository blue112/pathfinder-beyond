import macros.BuildTime;
import utils.Relatime;
import haxe.Resource;
import js.Browser;

class WelcomePage {
    public function new() {
        var mainElem = Browser.document.createDivElement();
        mainElem.classList.add("welcome");

        mainElem.innerHTML = Resource.getString("welcome.html");

        var ba = BuildTime.get_build_age();
        mainElem.querySelector(".last-build").innerText = Relatime.duration(ba);

        Browser.document.body.appendChild(mainElem);
    }
}
