import express.Next;
import express.Response;
import express.Request;
import express.Router;
import jsasync.IJSAsync;

using Lambda;

class SpellsRouter implements IJSAsync {
    static var cache:Map<String, Array<SpellEntry>> = new Map();

    static public function getRouter() {
        var router = new Router();
        router.param("characterClass", validateClass);
        // detail route must be registered before /:maxLevel to avoid "detail" matching as an Int
        router.get("/:characterClass/detail/:name", onGetDetail);
        router.get("/:characterClass/:maxLevel", onGetIndex);
        return router;
    }

    static function validateClass(req:Request, res:Response, next:Next, cls:String) {
        var lower = cls.toLowerCase();
        if (lower != "conjurateur" && lower != "magicien" && lower != "pretre") {
            res.status(400).end("Invalid class");
        } else {
            next.call();
        }
    }

    @:jsasync static function loadClass(cls:String):js.lib.Promise<Array<SpellEntry>> {
        if (!cache.exists(cls)) {
            var content = Fs.readFile('static/data/spells_$cls.json').jsawait().toString();
            cache.set(cls, haxe.Json.parse(content));
        }
        return cache.get(cls);
    }

    @:jsasync static function onGetIndex(req:Request, res:Response, next:Next) {
        var params:{characterClass:String, maxLevel:String} = cast req.params;
        var cls = params.characterClass.toLowerCase();
        var maxLevel = Std.parseInt(params.maxLevel);

        var spells = loadClass(cls).jsawait();
        var result = spells.filter(s -> s.level <= maxLevel).map(s -> {name: s.name, level: s.level});
        res.json(result);
    }

    @:jsasync static function onGetDetail(req:Request, res:Response, next:Next) {
        var params:{characterClass:String, name:String} = cast req.params;
        var cls = params.characterClass.toLowerCase();
        var name = params.name;

        var spells = loadClass(cls).jsawait();
        var found = spells.find(s -> s.name == name);

        if (found == null) {
            res.status(404).end("Spell not found");
            return;
        }

        res.json(found);
    }
}
