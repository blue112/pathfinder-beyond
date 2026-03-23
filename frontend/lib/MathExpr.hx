class MathExpr {
    public static function eval(s:String):Int {
        var pos = 0;
        function skipWs() {
            while (pos < s.length && s.charAt(pos) == ' ') pos++;
        }
        function readNum():Int {
            skipWs();
            var sign = 1;
            if (pos < s.length && s.charAt(pos) == '-') { sign = -1; pos++; }
            else if (pos < s.length && s.charAt(pos) == '+') pos++;
            skipWs();
            var start = pos;
            while (pos < s.length && s.charCodeAt(pos) >= '0'.code && s.charCodeAt(pos) <= '9'.code) pos++;
            var n = if (pos > start) Std.parseInt(s.substring(start, pos)) else null;
            return sign * (if (n == null) 0 else n);
        }
        function readTerm():Int {
            var v = readNum();
            skipWs();
            while (pos < s.length && (s.charAt(pos) == '*' || s.charAt(pos) == '/')) {
                var op = s.charAt(pos++);
                var r = readNum();
                v = if (op == '*') v * r else Std.int(v / r);
                skipWs();
            }
            return v;
        }
        function readExpr():Int {
            var v = readTerm();
            skipWs();
            while (pos < s.length && (s.charAt(pos) == '+' || s.charAt(pos) == '-')) {
                var op = s.charAt(pos++);
                var r = readTerm();
                v = if (op == '+') v + r else v - r;
                skipWs();
            }
            return v;
        }
        skipWs();
        if (pos >= s.length) return 0;
        return readExpr();
    }
}
