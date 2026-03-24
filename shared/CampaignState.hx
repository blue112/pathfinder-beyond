import CampaignProtocol;

class CampaignState {
    public var npcs:Array<NPCInfo>;
    public var encounter:Array<EncounterEntry>;

    public function new() {
        this.npcs = [];
        this.encounter = [];
    }

    public function processEvent(type:CampaignEventType) {
        switch (type) {
            case ADD_NPC(npc):
                npc.weapons = [];
                npcs.push(npc);
            case ADD_NPC_WEAPON(npcName, weapon):
                var npc = npcs.find(n -> n.name == npcName);
                if (npc != null) npc.weapons.push(weapon);
            case ADD_TO_ENCOUNTER(entity, initiative):
                encounter.push({entity: entity, initiative: initiative, currentHp: npcMaxHp(entity), currentAc: npcBaseAc(entity), note: null});
                encounter.sort((a, b) -> b.initiative - a.initiative);
            case REMOVE_FROM_ENCOUNTER(index):
                encounter.splice(index, 1);
            case CLEAR_ENCOUNTER:
                encounter = [];
            case DAMAGE_NPC_IN_ENCOUNTER(index, amount, damageType):
                var entry = encounter[index];
                if (entry.currentHp != null) {
                    var npc = switch (entry.entity) {
                        case NPC(npcName): npcs.find(n -> n.name == npcName);
                        case CHARACTER(_): null;
                    };
                    var effectiveAmount = if (npc != null && npc.damageReduction != null && !npc.damageReduction.bypassTypes.has(damageType))
                        Std.int(Math.max(amount - npc.damageReduction.amount, 0))
                    else
                        amount;
                    entry.currentHp = entry.currentHp - effectiveAmount;
                }
            case HEAL_NPC_IN_ENCOUNTER(index, amount):
                var entry = encounter[index];
                if (entry.currentHp != null) {
                    var maxHp = npcMaxHp(entry.entity);
                    entry.currentHp = if (maxHp != null) Std.int(Math.min(entry.currentHp + amount, maxHp)) else entry.currentHp + amount;
                }
            case SET_ENCOUNTER_NOTE(index, note):
                encounter[index].note = note;
        case SET_NPC_AC_IN_ENCOUNTER(index, ac):
            encounter[index].currentAc = ac;
        case SET_NPC_DAMAGE_REDUCTION(npcName, damageReduction):
            var npc = npcs.find(n -> n.name == npcName);
            if (npc != null) npc.damageReduction = damageReduction;
        case SET_INITIATIVE_IN_ENCOUNTER(index, initiative):
            encounter[index].initiative = initiative;
            encounter.sort((a, b) -> b.initiative - a.initiative);
        }
    }

    function npcMaxHp(entity:EncounterEntityType):Null<Int> {
        return switch (entity) {
            case NPC(npcName):
                var npc = npcs.find(n -> n.name == npcName);
                if (npc != null) npc.maxHp else null;
            case CHARACTER(_): null;
        };
    }

    function npcBaseAc(entity:EncounterEntityType):Null<Int> {
        return switch (entity) {
            case NPC(npcName):
                var npc = npcs.find(n -> n.name == npcName);
                if (npc != null) npc.ac else null;
            case CHARACTER(_): null;
        };
    }
}
