import js.Browser;
import macros.BuildTime;

class App {
	public function new() {
		var url = Browser.window.location.pathname;
		var paths = url.split("/");
		if (paths.length > 0) {
			switch (paths[1]) {
				case "fiche":
					new Fiche(paths[2]);
			}
		}
	}

	static function main() {
		trace("=== APP STARTED");
		BuildTime.trace_build_age_with_parse();

		new App();
	}
}
