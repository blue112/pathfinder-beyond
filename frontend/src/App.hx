import macros.BuildTime;

class App {
	public function new() {
		new Fiche();
	}

	static function main() {
		trace("=== APP STARTED");
		BuildTime.trace_build_age_with_parse();

		new App();
	}
}
