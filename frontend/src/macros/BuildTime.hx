package macros;

import haxe.macro.Context;

class BuildTime {
	// This macro generates code using Context.parse()
	public static macro function trace_build_age_with_parse() {
		var buildTime = Date.now();

		var code = '{
      var runTime = Math.floor(Date.now().getTime() / 1000);
      var age = runTime - ${buildTime.getTime() / 1000};
      trace("Last build: ${buildTime.toString()} ("+age+" seconds ago)");
    }';

		return Context.parse(code, Context.currentPos());
	}
}
