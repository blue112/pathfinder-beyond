class MathExprTest {
    static var passed = 0;
    static var failed = 0;

    static function eq(expected:Int, actual:Int, label:String) {
        if (expected == actual) {
            trace('  PASS  $label');
            passed++;
        } else {
            trace('  FAIL  $label  —  expected $expected, got $actual');
            failed++;
        }
    }

    static function section(name:String) {
        trace(name);
    }

    public static function run() {
        section("integer literals");
        eq(0,  MathExpr.eval("0"),  "0");
        eq(42, MathExpr.eval("42"), "42");
        eq(0,  MathExpr.eval(""),   "empty string");

        section("addition / subtraction");
        eq(7, MathExpr.eval("3+4"),     "3+4");
        eq(1, MathExpr.eval("3-2"),     "3-2");
        eq(6, MathExpr.eval("1+2+3"),   "1+2+3");
        eq(0, MathExpr.eval("5-3-2"),   "5-3-2");

        section("multiplication / division");
        eq(12, MathExpr.eval("3*4"),  "3*4");
        eq(3,  MathExpr.eval("9/3"),  "9/3");
        eq(2,  MathExpr.eval("5/2"),  "5/2 (integer division)");

        section("operator precedence");
        eq(7, MathExpr.eval("1+2*3"),    "1+2*3");
        eq(5, MathExpr.eval("10-2*2-1"), "10-2*2-1");
        eq(7, MathExpr.eval("1+12/2*1"), "1+12/2*1");

        section("leading sign");
        eq(5,  MathExpr.eval("+5"),   "+5");
        eq(-3, MathExpr.eval("-3"),   "-3");
        eq(2,  MathExpr.eval("-3+5"), "-3+5");

        section("whitespace");
        eq(7, MathExpr.eval("3 + 4"),   "3 + 4");
        eq(6, MathExpr.eval(" 2 * 3 "), " 2 * 3 ");

        section("flat mod after dice removal (0 substituted for XdY)");
        eq(5,  MathExpr.eval("0+5"),    "0+5  (1d8+5)");
        eq(10, MathExpr.eval("0+10"),   "0+10 (1d6+NLS, NLS=10)");
        eq(5,  MathExpr.eval("0+10/2"), "0+10/2 (1d8+NLS/2, NLS=10)");
        eq(0,  MathExpr.eval("0"),      "0    (1d8, no modifier)");

        trace('');
        trace('$passed passed, $failed failed');
        if (failed > 0) js.Node.process.exit(1);
    }
}
