import js.Browser;
import macros.BuildTime;

class App {
	public function new() {
		var url = Browser.window.location.pathname;
		var paths = url.split("/");
		if (paths.length > 1 && paths[1] != "") {
			switch (paths[1]) {
				case "fiche":
					var uuid = paths[2];
					if (uuid == "create") {
						new FicheCreator();
					} else {
						new Fiche(uuid);
					}
				case "campaign":
					new Campaign(paths[2]);
			}
		} else {
			new WelcomePage();
		}
	}

	static function main() {
		trace("=== APP STARTED");
		BuildTime.trace_build_age_with_parse();

		new App();
	}
}
