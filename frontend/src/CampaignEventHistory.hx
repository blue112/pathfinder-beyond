import js.html.MouseEvent;
import haxe.ds.StringMap;
import js.Browser;

using DateTools;
using ProtocolUtil;

class CampaignEventHistory extends Popup {
	var campaign_id:String;

	public function new(campaign_id:String, events:Array<CampaignEventTs>, ficheNames:StringMap<String>) {
		super("Historique de la campagne");

		getContent().classList.add("event-history");

		this.campaign_id = campaign_id;

		var currentEncounter:Array<{entity:EncounterEntityType, initiative:Int}> = [];

		var list = Browser.document.createUListElement();

		for (i in events) {
			var elem = Browser.document.createLIElement();
			var event = switch (i.type) {
				case ADD_NPC(npc): 'Ajout d\'un PNJ: ${npc.name.htmlEscape()}';
				case ADD_NPC_WEAPON(npcName, weapon): 'Ajout d\'une arme à ${npcName.htmlEscape()}: ${weapon.name.htmlEscape()}';
				case ADD_TO_ENCOUNTER(entity, initiative):
					currentEncounter.push({entity: entity, initiative: initiative});
					currentEncounter.sort((a, b) -> b.initiative - a.initiative);
					var entityName = entityToName(entity, ficheNames);
					'Ajout à la rencontre: ${entityName.htmlEscape()} (init $initiative)';
				case REMOVE_FROM_ENCOUNTER(index):
					var removed = currentEncounter.splice(index, 1)[0];
					var entityName = entityToName(removed.entity, ficheNames);
					'Retrait de la rencontre: ${entityName.htmlEscape()}';
				case CLEAR_ENCOUNTER:
					currentEncounter = [];
					'Fin de rencontre';
				case DAMAGE_NPC_IN_ENCOUNTER(index, amount, damageType):
					var entityName = index < currentEncounter.length ? entityToName(currentEncounter[index].entity, ficheNames) : '?';
					'Dégâts sur ${entityName.htmlEscape()}: $amount pv (${damageType.damageTypeToString().toLowerCase()})';
				case HEAL_NPC_IN_ENCOUNTER(index, amount):
					var entityName = index < currentEncounter.length ? entityToName(currentEncounter[index].entity, ficheNames) : '?';
					'Soins sur ${entityName.htmlEscape()}: $amount pv';
				case SET_ENCOUNTER_NOTE(index, note):
					var entityName = index < currentEncounter.length ? entityToName(currentEncounter[index].entity, ficheNames) : '?';
					'Note sur ${entityName.htmlEscape()}: ${note.htmlEscape()}';
				case SET_NPC_AC_IN_ENCOUNTER(index, ac):
					var entityName = index < currentEncounter.length ? entityToName(currentEncounter[index].entity, ficheNames) : '?';
					'CA modifiée sur ${entityName.htmlEscape()}: $ac';
				case SET_NPC_DAMAGE_REDUCTION(npcName, damageReduction):
					var types = damageReduction.bypassTypes.map(t -> t.damageTypeToString()).join(", ");
					var rdStr = '${damageReduction.amount}/${if (types == "") "&mdash;" else types}';
					'RD de ${npcName.htmlEscape()} définie: $rdStr';
			};
			elem.innerHTML = '<a class="del">x</a> <small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%M:%S")}]</small> $event';
			list.appendChild(elem);
			elem.querySelector(".del").addEventListener("click", (e:MouseEvent) -> {
				if (e.shiftKey) {
					trace(Api.delCampaignEvent(campaign_id, i.id).then((_) -> {
						list.removeChild(elem);
					}));
				} else {
					trace('Ignored, must press shift');
				}
			});
		}

		getContent().appendChild(list);
	}

	static function entityToName(entity:EncounterEntityType, ficheNames:StringMap<String>):String {
		return switch (entity) {
			case CHARACTER(ficheId): ficheNames.exists(ficheId) ? ficheNames.get(ficheId) : ficheId;
			case NPC(npcName): npcName;
		};
	}
}
