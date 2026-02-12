class Formatter {
	public static function asMod(n:Int, ?withSpace:Bool) {
		if (n > 0)
			return if (withSpace) '+ $n' else '+$n';
		if (n < 0)
			return if (withSpace) '- ${- n}' else '$n';

		return if (withSpace) '+ 0' else '+0';
	}
}
