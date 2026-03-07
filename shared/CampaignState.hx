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
				npcs.push(npc);
			case ADD_TO_ENCOUNTER(entity, initiative):
				encounter.push({entity: entity, initiative: initiative, currentHp: npcMaxHp(entity), note: null});
				encounter.sort((a, b) -> b.initiative - a.initiative);
			case REMOVE_FROM_ENCOUNTER(index):
				encounter.splice(index, 1);
			case CLEAR_ENCOUNTER:
				encounter = [];
			case DAMAGE_NPC_IN_ENCOUNTER(index, amount, _):
				var entry = encounter[index];
				if (entry.currentHp != null)
					entry.currentHp = entry.currentHp - amount;
			case HEAL_NPC_IN_ENCOUNTER(index, amount):
				var entry = encounter[index];
				if (entry.currentHp != null) {
					var maxHp = npcMaxHp(entry.entity);
					entry.currentHp = if (maxHp != null) Std.int(Math.min(entry.currentHp + amount, maxHp)) else entry.currentHp + amount;
				}
			case SET_ENCOUNTER_NOTE(index, note):
				encounter[index].note = note;
		}
	}

	function npcMaxHp(entity:EncounterEntityType):Null<Int> {
		return switch (entity) {
			case NPC(npcName):
				var npc = npcs.find(n -> n.name == npcName);
				if (npc != null) npc.maxHp else null;
			case CHARACTER(_): null; // HP is tracked in FullCharacter, not CampaignState
		};
	}
}
