import haxe.Timer;
import utils.Relatime;
import js.html.AnchorElement;
import js.html.TableRowElement;
import haxe.ds.StringMap;
import haxe.Resource;
import js.Browser;
import js.html.DivElement;
import jsasync.IJSAsync;

using Rules;

private typedef CampaignFicheInfo = {
	var fiche_id:String;
	var characterName:String;
	var latestDiceRoll:Null<PublicDiceRoll>;
	var events:Array<FicheEventTs>;
};

private typedef CampaignLoadResult = {
	var name:String;
	var fiches:Array<CampaignFicheInfo>;
	var campaignEvents:Array<CampaignEventTs>;
};

class Campaign implements IJSAsync {
	var campaign_id:String;
	var mainElem:DivElement;
	var charactersByFicheId:StringMap<FullCharacter>;
	var tableLineByFicheId:StringMap<TableRowElement>;
	var latestDiceRollByFicheId:StringMap<PublicDiceRoll>;
	var campaignState:CampaignState;
	var campaignEvents:Array<CampaignEventTs>;

	public function new(campaign_id:String) {
		this.campaign_id = campaign_id;

		mainElem = Browser.document.createDivElement();
		mainElem.classList.add("campaign");
		mainElem.innerHTML = Resource.getString('campaign.html');
		Browser.document.body.appendChild(mainElem);

		mainElem.querySelector(".add-npc").addEventListener("click", () -> {
			new elems.AddNPCDialog((npc) -> {
				pushEvent(ADD_NPC(npc));
			});
		});

		mainElem.querySelector(".end-encounter").addEventListener("click", () -> {
			new elems.YesNoAlert("Terminer la rencontre", "Terminer la rencontre en cours ?", () -> {
				pushEvent(CLEAR_ENCOUNTER);
			});
		});

		mainElem.querySelector("a.history").addEventListener("click", () -> {
			var ficheNames = new StringMap<String>();
			for (ficheId in charactersByFicheId.keys()) {
				ficheNames.set(ficheId, charactersByFicheId.get(ficheId).basics.characterName);
			}
			new CampaignEventHistory(campaign_id, campaignEvents, ficheNames);
		});

		load();
	}

	static public function dicerollToString(roll:PublicDiceRoll) {
		if (roll.mod != null && roll.mod != 0) {
			var mod = ' ${roll.mod.asMod(true)}';
			return '1d${roll.faces}$mod : ${roll.result}$mod';
		}

		return '1d${roll.faces}';
	}

	private function updateChar(fiche_id:String) {
		var tableLine = tableLineByFicheId.get(fiche_id);
		var character = charactersByFicheId.get(fiche_id);

		tableLine.querySelector(".pv").innerText = character.current_hp.string();
		tableLine.querySelector(".max").innerText = character.getMaxHitPoints().string();
		tableLine.querySelector(".tempmod .count").innerText = character.tempMods.length.string();
		updateRoll(fiche_id);
		renderEncounter();
	}

	function updateRoll(fiche_id:String) {
		var roll = latestDiceRollByFicheId.get(fiche_id);
		if (roll == null)
			return;

		var tableLine = tableLineByFicheId.get(fiche_id);
		var nameRe = ~/[_-]/g;
		var name = nameRe.replace(roll.field_name, " ");
		var rollCell = tableLine.querySelector(".roll");
		var diffTime = ((Date.now().getTime() - roll.ts) / 1000).int();
		rollCell.innerHTML = '
			<div class="fieldname">${name} &mdash; ${roll.result + roll.mod}</div>
			<div class="roll num">${dicerollToString(roll)}</div>
			<div class="ts">${Relatime.duration(diffTime)}</div>
			';
	}

	@:jsasync private function load() {
		var campaignIdRegex = ~/^[0-9a-f-]{36}$/;
		if (!campaignIdRegex.match(campaign_id))
			return;

		var result:CampaignLoadResult = Api.load('/campaign/$campaign_id').jsawait();
		mainElem.querySelector("h1").innerText = result.name;

		var characters = mainElem.querySelector(".characters");

		charactersByFicheId = new StringMap();
		tableLineByFicheId = new StringMap();
		latestDiceRollByFicheId = new StringMap();
		campaignState = new CampaignState();
		campaignEvents = result.campaignEvents;
		for (event in result.campaignEvents) {
			campaignState.processEvent(event.type);
		}
		renderNpcs();
		renderEncounter();
		for (char in result.fiches) {
			var elem = Browser.document.createTableRowElement();
			elem.innerHTML = Resource.getString('campaign_character.html');

			var fc = new FullCharacter();
			for (event in char.events) {
				fc.processEvent(event.type);
			}
			charactersByFicheId.set(char.fiche_id, fc);

			(cast elem.querySelector("a") : AnchorElement).href = '/fiche/${char.fiche_id}';
			var img = Browser.document.createImageElement();
			img.src = fc.basics.characterClass.classToIconPath();
			img.title = fc.basics.characterClass.classToString();
			img.alt = fc.basics.characterClass.classToString();
			var nameCell = elem.querySelector(".name");
			nameCell.appendChild(img);
			nameCell.appendChild(Browser.document.createTextNode(' ' + char.characterName.split(' ')[0]));

			tableLineByFicheId.set(char.fiche_id, elem);
			latestDiceRollByFicheId.set(char.fiche_id, char.latestDiceRoll);
			updateChar(char.fiche_id);

			elem.querySelector(".roll").addEventListener('click', () -> {
				new DiceRollHistory(char.fiche_id, null);
			});
			elem.querySelector(".tempmod .count").addEventListener('click', () -> {
				new TemporaryModifiersList(char.fiche_id, fc.tempMods);
			});
			elem.querySelector(".add-encounter a").addEventListener('click', () -> {
				var alreadyIn = campaignState.encounter.exists(e -> switch (e.entity) {
					case CHARACTER(id): id == char.fiche_id;
					case NPC(_): false;
				});
				if (alreadyIn) {
					new elems.Alert("Rencontre", '${charactersByFicheId.get(char.fiche_id).basics.characterName} est déjà dans la rencontre.');
					return;
				}
				var roll = latestDiceRollByFicheId.get(char.fiche_id);
				var initiative:Int;
				if (roll != null && roll.field_name == "initiative") {
					initiative = roll.result + (if (roll.mod != null) roll.mod else 0);
				} else {
					var input = js.Browser.window.prompt('Initiative de ${charactersByFicheId.get(char.fiche_id).basics.characterName} ?');
					if (input == null)
						return;
					var parsed = input.parseInt();
					if (parsed == null)
						return;
					initiative = parsed;
				}
				pushEvent(ADD_TO_ENCOUNTER(CHARACTER(char.fiche_id), initiative));
			});

			characters.querySelector("tbody").appendChild(elem);
		}

		var ws:WsTalker = null;
		ws = new WsTalker(() -> {
			for (i in result.fiches) {
				ws.subscribe(i.fiche_id, i.events[i.events.length - 1].id, true);
			}
		}, () -> {});
		ws.onNewEvent = (fiche_id:String, event:FicheEventTs) -> {
			var fc = charactersByFicheId.get(fiche_id);
			if (fc != null) {
				fc.processEvent(event.type);
				updateChar(fiche_id);
			}
		};
		ws.onNewDiceRoll = (fiche_id:String, dr:PublicDiceRoll) -> {
			latestDiceRollByFicheId.set(fiche_id, dr);
			updateChar(fiche_id);
		};

		var updateRollTimer = new Timer(5000);
		updateRollTimer.run = function() {
			for (i in latestDiceRollByFicheId.keys()) {
				updateRoll(i);
			}
		};
	}

	private function renderNpcs() {
		var tbody = mainElem.querySelector(".npcs tbody");
		tbody.innerHTML = "";
		for (npc in campaignState.npcs) {
			var row = Browser.document.createTableRowElement();
			var notes = if (npc.notes != null) npc.notes else "";
			var damageReductionStr = if (npc.damageReduction == null) "—" else {
				var types = npc.damageReduction.bypassTypes.map(t -> t.damageTypeToString()).join(", ");
				'${npc.damageReduction.amount}/${if (types == "") "—" else types}';
			};
			row.innerHTML = '
				<td class="npc-name"></td>
				<td>${npc.maxHp}</td>
				<td title="Contact: ${npc.acContact} / Surprise: ${npc.acBySurprise}">${npc.ac}</td>
				<td class="npc-rd"></td>
				<td>${npc.cr}</td>
				<td class="npc-notes"></td>
				<td class="add-encounter"><a>+</a></td>
			';
			var nameCell = row.querySelector(".npc-name");
			nameCell.innerText = npc.name;
			row.querySelector(".npc-rd").innerText = damageReductionStr;
			row.querySelector(".npc-notes").innerText = notes;
			nameCell.addEventListener("click", () -> {
				new ContextMenu(cast nameCell, ["Ajouter une arme", "Définir la RD"], (choice) -> {
					if (choice == 0) {
						new elems.NPCWeaponDialog((weapon) -> {
							pushEvent(ADD_NPC_WEAPON(npc.name, weapon));
						});
					} else if (choice == 1) {
						new elems.NPCDamageReductionDialog(npc.damageReduction, (damageReduction) -> {
							pushEvent(SET_NPC_DAMAGE_REDUCTION(npc.name, damageReduction));
						});
					}
					return true;
				});
			});
			row.querySelector(".add-encounter a").addEventListener("click", () -> {
				var initiative = dice(20) + npc.initiativeModifier;
				pushEvent(ADD_TO_ENCOUNTER(NPC(npc.name), initiative));
			});
			tbody.appendChild(row);
			for (weapon in npc.weapons) {
				var weaponRow = Browser.document.createTableRowElement();
				weaponRow.classList.add("npc-weapon");
				var damageTypesStr = weapon.damageTypes.map(dt -> switch (dt) {
					case PERFORANT: "P";
					case TRANCHANT: "T";
					case CONTONDANT: "C";
				}).join("/");
				var critStr = '${weapon.criticalNums.join(",")} ×${weapon.criticalMultiplier}';
				weaponRow.innerHTML = '<td colspan="7"></td>';
				var cell = weaponRow.querySelector("td");
				cell.innerText = '${weapon.name} — ${weapon.attackBonus.asMod()} — ${weapon.damage} (${damageTypesStr}) crit: ${critStr}';
				if (weapon.note != null) {
					var noteSpan = Browser.document.createSpanElement();
					noteSpan.className = "weapon-note";
					noteSpan.innerText = ' — ${weapon.note}';
					cell.appendChild(noteSpan);
				}
				tbody.appendChild(weaponRow);
			}
		}
	}

	private function renderEncounter() {
		var section = (cast mainElem.querySelector("section.encounter") : js.html.Element);
		var tbody = mainElem.querySelector("section.encounter tbody");
		var encounter = campaignState.encounter;
		section.classList.toggle("shown", encounter.length > 0);
		tbody.innerHTML = "";
		for (i in 0...encounter.length) {
			var entry = encounter[i];
			var isNpc = entry.entity.match(NPC(_));

			var fc:FullCharacter = null;
			var npc:NPCInfo = null;
			switch (entry.entity) {
				case CHARACTER(ficheId): fc = charactersByFicheId.get(ficheId);
				case NPC(npcName): npc = campaignState.npcs.find(n -> n.name == npcName);
			}

			var name = if (fc != null) fc.basics.characterName else if (npc != null) npc.name else "?";
			var hp = if (fc != null) '${fc.current_hp} / ${fc.getMaxHitPoints()}' else if (npc != null && entry.currentHp != null) '${entry.currentHp} / ${npc.maxHp}' else "?";
			var ac = if (fc != null) fc.getAC().string() else if (entry.currentAc != null) entry.currentAc.string() else "?";
			var acTooltip = if (fc != null) 'Contact: ${fc.getACContact()} / Surprise: ${fc.getACSurprise()}' else if (npc != null) 'Contact: ${npc.acContact} / Surprise: ${npc.acBySurprise}' else "";

			var row = Browser.document.createTableRowElement();
			row.innerHTML = '
				<td class="initiative"></td>
				<td class="name"></td>
				<td class="hp"></td>
				<td class="ca"></td>
				<td class="note"></td>
				<td><a class="remove-encounter">✕</a></td>
			';
			row.querySelector(".initiative").innerText = entry.initiative.string();
			row.querySelector(".hp").innerText = hp;
			var caCell = row.querySelector(".ca");
			caCell.innerText = ac;
			caCell.title = acTooltip;
			var noteCell = row.querySelector(".note");
			noteCell.innerText = if (entry.note != null) entry.note else "";
			noteCell.addEventListener("click", () -> {
				new elems.NoteDialog(entry.note, (note) -> {
					pushEvent(SET_ENCOUNTER_NOTE(i, note));
				});
			});
			row.querySelector(".remove-encounter").addEventListener("click", () -> {
				pushEvent(REMOVE_FROM_ENCOUNTER(i));
			});

			var nameCell = row.querySelector(".name");
			if (isNpc) {
				nameCell.classList.add("npc");
				nameCell.innerText = name;
				row.querySelector(".hp").classList.add("npc-hp");
				row.querySelector(".npc-hp").addEventListener("click", () -> {
					new ContextMenu(cast row.querySelector(".npc-hp"), ["Dégâts", "Soins"], (choice) -> {
						if (choice == 0) {
							new elems.DamageChoice((amount, damageType) -> {
								pushEvent(DAMAGE_NPC_IN_ENCOUNTER(i, amount, damageType));
							});
						} else if (choice == 1) {
							new elems.AmountChoice("Soins", "Combien de PV rendre ?", null, (amount, _) -> {
								pushEvent(HEAL_NPC_IN_ENCOUNTER(i, amount));
							});
						}
						return true;
					});
				});
				caCell.classList.add("npc-ac");
				caCell.addEventListener("click", () -> {
					new elems.AmountChoice("Modifier la CA", "Nouvelle valeur de CA :", {defaultValue: if (entry.currentAc != null) entry.currentAc else 0}, (newAc, _) -> {
						pushEvent(SET_NPC_AC_IN_ENCOUNTER(i, newAc));
					});
				});
				if (npc != null && npc.weapons.length > 0) {
					var weaponBtn = Browser.document.createAnchorElement();
					var weaponImg = Browser.document.createImageElement();
					weaponImg.src = "/assets/icons/attack.svg";
					weaponImg.alt = "Attaquer";
					weaponBtn.appendChild(weaponImg);
					weaponBtn.className = "use-weapon";
					weaponBtn.title = "Attaquer";
					row.querySelector("td:last-child").insertBefore(weaponBtn, row.querySelector(".remove-encounter"));
					weaponBtn.addEventListener("click", () -> {
						useWeapon(weaponBtn, npc.weapons);
					});
				}
			} else {
				nameCell.classList.add("character");
				if (fc != null) {
					var img = Browser.document.createImageElement();
					img.src = fc.basics.characterClass.classToIconPath();
					img.title = fc.basics.characterClass.classToString();
					img.alt = fc.basics.characterClass.classToString();
					nameCell.appendChild(img);
					nameCell.appendChild(Browser.document.createTextNode(' $name'));
				} else {
					nameCell.innerText = name;
				}
			}
			tbody.appendChild(row);
		}
	}

	private function useWeapon(anchor:js.html.AnchorElement, weapons:Array<NPCWeapon>) {
		if (weapons.length == 1) {
			new elems.WeaponRollDialog(weapons[0]);
		} else {
			new ContextMenu(cast anchor, weapons.map(w -> w.name), (choice) -> {
				new elems.WeaponRollDialog(weapons[choice]);
				return true;
			});
		}
	}

	@:jsasync private function pushEvent(event:CampaignEventType) {
		var result = Api.pushCampaignEvent(campaign_id, event).jsawait();
		if (result.success) {
			campaignState.processEvent(event);
			campaignEvents.push({type: event, id: result.eventId, ts: result.eventTs});
			renderNpcs();
			renderEncounter();
		}
	}
}
