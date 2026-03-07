import CampaignProtocol;

class CampaignState {
	public var npcs:Array<NPCInfo>;

	public function new() {
		this.npcs = [];
	}

	public function processEvent(type:CampaignEventType) {
		switch (type) {
			case ADD_NPC(npc):
				npcs.push(npc);
		}
	}
}
