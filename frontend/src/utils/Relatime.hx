package utils;

class Relatime {
	static public function fulltime(date:Date, ?withDate:Bool = true) {
		if (withDate)
			return DateTools.format(date, "%d/%m/%Y&nbsp;à&nbsp;%H:%M:%S");

		return DateTools.format(date, "%H:%M:%S");
	}

	static public function showDate(date:Date) {
		var full = fulltime(date, true);
		var diff = (Date.now().getTime() - date.getTime()) / 1000;
		if (diff > YEAR)
			return full;

		return '${full} (${relatime(date)})';
	}

	static public function fulldate(date:Date) {
		return DateTools.format(date, "%d/%m/%Y");
	}

	static inline private var SECONDS = 1;
	static inline private var MINUTES = 60;
	static inline private var HOURS = 60 * 60;
	static inline private var DAYS = HOURS * 24;
	static inline private var MONTH = DAYS * 30;
	static inline private var YEAR = DAYS * 365;

	static public function fullduration(diff:Int) {
		var out = [];
		var units = ["année", "mois", "jour", "heure", "minute",];

		if (diff == 0)
			return "";
		if (diff < MINUTES)
			return "Quelques secondes";

		var time = [YEAR, MONTH, DAYS, HOURS, MINUTES];

		for (i in 0...units.length) {
			var unitLabel = units[i];
			var unitValue = time[i];

			if (diff >= unitValue) {
				var num = Math.floor(diff / unitValue);
				var label = num + " " + unitLabel;
				if (num > 1 && unitValue != MONTH)
					label += "s";
				out.push(label);
				diff = diff % unitValue;
			}
		}

		return out.join(", ");
	}

	static public function duration(diff:Int) {
		var units = ["an", "mois", "jour", "heure", "minute", "secondes"];

		if (diff == 0)
			return "Maintenant";

		var time = [YEAR, MONTH, DAYS, HOURS, MINUTES, SECONDS];

		for (i in 0...units.length) {
			var unitLabel = units[i];
			var unitValue = time[i];

			if (diff >= unitValue) {
				var num = Math.floor(diff / unitValue);
				var label = num + " " + unitLabel;
				if (num > 1 && unitValue != MONTH)
					label += "s";
				return label;
			}
		}

		return "";
	}

	static public function relatime(date:Date) {
		var diff = (Date.now().getTime() - date.getTime()) / 1000;
		if (diff < 0) {
			diff = -diff;
			if (diff < 5)
				return "dans un instant";
			if (diff < 60)
				return "dans " + Math.round(diff) + " secondes";
			if (diff < 60 * 60)
				return "dans " + Math.round(diff / 60) + " minutes";
			if (diff < 60 * 60 * 24)
				return "dans " + Math.round(diff / (60 * 60)) + " heures";
			if (diff < 60 * 60 * 24 * 2)
				return "demain";

			return "dans " + Math.round(diff / (3600 * 24)) + " jours";
		}
		if (diff < 5)
			return "il y a un instant";
		if (diff < MINUTES)
			return "il y a " + Math.round(diff) + " secondes";
		if (diff < HOURS)
			return "il y a " + Math.round(diff / MINUTES) + " minutes";
		if (diff < DAYS)
			return "il y a " + Math.round(diff / HOURS) + " heures";
		if (diff < MONTH)
			return "il y a " + Math.round(diff / DAYS) + " jours";
		if (diff < YEAR)
			return "il y a " + Math.round(diff / MONTH) + " mois";

		return "le " + fulltime(date);
	}
}
