import haxe.Timer;
import utils.Relatime;
import js.html.AnchorElement;
import js.html.TableRowElement;
import haxe.ds.StringMap;
import haxe.Resource;
import js.Browser;
import js.html.DivElement;
import jsasync.IJSAsync;

class Campaign implements IJSAsync {
	var campaign_id:String;
	var mainElem:DivElement;
	var charactersByFicheId:StringMap<FullCharacter>;
	var tableLineByFicheId:StringMap<TableRowElement>;
	var latestDiceRollByFicheId:StringMap<PublicDiceRoll>;

	public function new(campaign_id:String) {
		this.campaign_id = campaign_id;

		mainElem = Browser.document.createDivElement();
		mainElem.classList.add("campaign");
		mainElem.innerHTML = Resource.getString('campaign.html');
		Browser.document.body.appendChild(mainElem);

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

		var result:{
			name:String,
			fiches:Array<{
				fiche_id:String,
				characterName:String,
				latestDiceRoll:PublicDiceRoll,
				events:Array<FicheEventTs>
			}>
		} = Api.load('/campaign/$campaign_id').jsawait();
		mainElem.querySelector("h1").innerText = result.name;

		var characters = mainElem.querySelector(".characters");

		charactersByFicheId = new StringMap();
		tableLineByFicheId = new StringMap();
		latestDiceRollByFicheId = new StringMap();
		for (char in result.fiches) {
			var elem = Browser.document.createTableRowElement();
			elem.innerHTML = Resource.getString('campaign_line.html');

			var fc = new FullCharacter();
			for (event in char.events) {
				fc.processEvent(event.type);
			}
			charactersByFicheId.set(char.fiche_id, fc);

			(cast elem.querySelector("a") : AnchorElement).href = '/fiche/${char.fiche_id}';
			elem.querySelector(".name").innerText = char.characterName.split(' ')[0];
			elem.querySelector(".cls").innerText = fc.basics.characterClass.classToString();

			tableLineByFicheId.set(char.fiche_id, elem);
			latestDiceRollByFicheId.set(char.fiche_id, char.latestDiceRoll);
			updateChar(char.fiche_id);

			elem.querySelector(".roll").addEventListener('click', () -> {
				new DiceRollHistory(char.fiche_id, null);
			});
			elem.querySelector(".tempmod .count").addEventListener('click', () -> {
				new TemporaryModifiersList(char.fiche_id, fc.tempMods);
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
}
