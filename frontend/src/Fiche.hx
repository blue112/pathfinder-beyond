import js.html.MouseEvent;
import RulesSkills.SkillType;
import js.html.DivElement;
import macros.GetAllFields;
import js.html.Element;
import haxe.ds.StringMap;
import jsasync.IJSAsync;
import js.Browser;
import elems.*;

using Rules;

class Fiche implements IJSAsync {
	var availableFields:StringMap<Element>;
	var character:FullCharacter;
	var fiche_id:String;

	var fieldsNames:StringMap<String>;
	var ficheEvents:Array<FicheEventTs>;

	var mainElem:DivElement;
	var ws:WsTalker;

	public function new(fiche_id:String) {
		mainElem = Browser.document.createDivElement();
		mainElem.classList.add("fiche");

		this.fiche_id = fiche_id;

		character = {
			skillRanks: [],
			current_hp: 0,
			levelUpDices: [],
			level: 1,
			max_hp_modifier: 0,
			additionalClassSkills: [],
			skillModifiers: new Map(),
		};

		mainElem.innerHTML = "
		<section class='actions'>
			<a class='see-dice-rolls'>Voir les lancés de dés</a>
			<a class='history'>Historique</a>
		</section>
        <section class='meta'>
            <div class='left'>
                <div class='logo'><span>Feuille de personnage</span></div>
            </div>
            <div class='right'>
                <div class='field-line'>
                    <div class='field' data-id='character-name'>
                        <div class='label'>Nom du personnage</div>
                        <div class='value'></div>
                    </div>
                    <div class='field' data-id='alignement'>
                        <div class='label'>Alignement</div>
                        <div class='value'></div>
                    </div>
                    <div class='field' data-id='player-name'>
                        <div class='label'>Joueur/Joueuse</div>
                        <div class='value'></div>
                    </div>
                </div>
                <div class='field-line'>
                    <div class='field l' data-id='character-class'>
                        <div class='label'>Classe</div>
                        <div class='value'></div>
                    </div>
                    <div class='field xxs m-s' data-id='level'>
                        <div class='label'>Niveau</div>
                        <div class='value'>
							<span class='text'></span>
							<div class='actions-hover'><a class='plus'>+</a></div>
						</div>
                    </div>
                    <div class='field' data-id='divinity-name'>
                        <div class='label'>Divinité</div>
                        <div class='value'></div>
                    </div>
                    <div class='field' data-id='origin'>
                        <div class='label'>Origine</div>
                        <div class='value'></div>
                    </div>
                </div>
                <div class='field-line'>
                    <div class='field' data-id='race'>
                        <div class='label'>Race</div>
                        <div class='value'></div>
                    </div>
                    <div class='field xs' data-id='size-category'>
                        <div class='label'>Catégorie de taille</div>
                        <div class='value'></div>
                    </div>
                    <div class='field xs m-s' data-id='gender'>
                        <div class='label'>Genre</div>
                        <div class='value'></div>
                    </div>
                    <div class='field xs m-s' data-id='age'>
                        <div class='label'>Age</div>
                        <div class='value num'></div>
                    </div>
                    <div class='field xs  m-s' data-id='height-cm'>
                        <div class='label'>Taille</div>
                        <div class='value num'></div>
                    </div>
                    <div class='field xs  m-s' data-id='weight-kg'>
                        <div class='label'>Poids</div>
                        <div class='value num'></div>
                    </div>
                    <div class='field s' data-id='hair'>
                        <div class='label'>Cheveux</div>
                        <div class='value'></div>
                    </div>
                    <div class='field s' data-id='eyes'>
                        <div class='label'>Yeux</div>
                        <div class='value'></div>
                    </div>
                </div>
            </div>
        </section>
        <section class='caracteristics'>
            <h2>Caractéristiques</h2>
            <div class='carac' data-id='str'>
                <div class='label'><div class='actions-hover'><a class='plus'>+</a></div><span class='text'>Force</span></div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='dex'>
                <div class='label'><div class='actions-hover'><a class='plus'>+</a></div><span class='text'>Dextérité</span></div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='con'>
                <div class='label'><div class='actions-hover'><a class='plus'>+</a></div><span class='text'>Constitution</span></div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='int'>
                <div class='label'><div class='actions-hover'><a class='plus'>+</a></div><span class='text'>Intelligence</span></div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='wis'>
                <div class='label'><div class='actions-hover'><a class='plus'>+</a></div><span class='text'>Sagesse</span></div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='cha'>
                <div class='label'><div class='actions-hover'><a class='plus'>+</a></div><span class='text'>Charisme</span></div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
        </section>
        <section class='hp'>
            <h2>Points de vie</h2>
            <div class='lethal'>
                <div class='label'>
					<div class='actions-hover'>
						<a class='plus'>+</a>
					</div>
					<span class='text'>Points de Vie</span>
				</div>
                <div class='value'>
                    <div class='current' data-id='hp'>
						<span class='value'></span>
					</div>
                    <div class='separator'>/</div>
                    <div class='max' data-id='hp-max'></div>
                </div>
            </div>
            <div class='non-lethal'>
                <div class='label'>Blessures non léthales</div>
                <div class='value'>
                    <div class='current' data-id='non-lethal-damages'></div>
                    <div class='separator'>/</div>
                    <div class='max' data-id='non-lethal-max'></div>
                </div>
            </div>
        </section>
        <section class='speed'>
            <h2>Déplacement</h2>
            <section data-id='speed'>
                <div class='label'>Déplacement</div>
                <div class='value'></div>
            </section>
        </section>
        <section class='initiative'>
            <h2>Initiative</h2>
            <section data-id='initiative'>
                <div class='label'>Initiative</div>
                <div class='value'><span class='d20'></span><span class='mod'></span></div>
            </section>
        </section>
        <section class='armor'>
            <h2>Défense</h2>
            <section class='ac' data-id='ac'>
                <div class='label'>CA</div>
                <div class='value'></div>
            </section>
            <section class='contact' data-id='ac-contact'>
                <div class='label'>Contact</div>
                <div class='value'></div>
            </section>
            <section class='surprise' data-id='ac-surprise'>
                <div class='label'>Pris au dépourvu</div>
                <div class='value'></div>
            </section>
        </section>
        <section class='saving'>
            <h2>Jets de sauvegarde</h2>
            <div class='reflexes' data-id='saving-reflexes'>
                <div class='label'>Reflexes</div>
                <div class='value'><span class='d20'></span><span class='mod'></span></div>
            </div>
            <div class='vigor' data-id='saving-vigor'>
                <div class='label'>Vigueur</div>
                <div class='value'><span class='d20'></span><span class='mod'></span></div>
            </div>
            <div class='will' data-id='saving-will'>
                <div class='label'>Volonté</div>
                <div class='value'><span class='d20'></span><span class='mod'></span></div>
            </div>
        </section>
        <section class='fight'>
            <h2>Combat</h2>
            <div class='bba' data-id='bba'>
                <div class='label'>Bonus de Base à l'Attaque</div>
                <div class='value'></div>
            </div>
            <div class='bmo' data-id='bmo'>
                <div class='label'>Manoeuvre Offensive</div>
                <div class='value'><span class='d20'></span> <span class='mod'></span></div>
            </div>
            <div class='dmd' data-id='dmd'>
                <div class='label'>Manoeuvre Défensive</div>
                <div class='value'></div>
            </div>
            <section class='weapons'>
                <h2>Armes</h2>
            </section>
        </section>
        <section class='skills'>
        </section>
        ";

		Browser.document.body.appendChild(mainElem);

		availableFields = new StringMap();
		fieldsNames = new StringMap();
		for (i in mainElem.querySelectorAll("*")) {
			var e:Element = cast i;
			var id = e.dataset.id;
			if (id != null) {
				var value = e.querySelector(".value");
				if (value != null)
					e = value;
				var mod = e.querySelector(".mod");
				if (mod != null)
					e = mod;
				var text = e.querySelector(".text");
				if (text != null)
					e = text;

				availableFields.set(id, e);
				var label = (cast i : Element).querySelector(".label");
				if (label != null) {
					fieldsNames.set(id, label.innerText);
				}
			}
		}

		bindD20();
		bindMenu();
		bindHPActions();
		bindCaracActions();
		bindLevelActions();

		load(fiche_id);
	}

	function bindLevelActions() {
		var menuLabels = ["Monter de niveau"];
		var action = mainElem.querySelector(".field[data-id=level] .plus");
		action.addEventListener("click", () -> {
			new ContextMenu(cast action, menuLabels, (choice) -> {
				new YesNoAlert("Montée de niveau", "Valider la montée de niveau ?", () -> {
					onActionLevelUp();
				});
				return true;
			});
		});
	}

	@:jsasync function onActionLevelUp() {
		var hd = Rules.getHitDice(character.basics.characterClass);
		var diceRoll = Api.rollDice(fiche_id, hd, "level").jsawait();
		var result = diceRoll.result;
		new Alert("Montée de niveau", 'Résultat du lancer de dé de point de vie (d${hd}): $result');
		Api.pushEvent(fiche_id, LEVEL_UP(result));
	}

	function bindCaracActions() {
		var menuLabels = ["Ajouter un modificateur temporaire", "Ajouter un modificateur permanent"];
		var actions = mainElem.querySelectorAll(".carac .plus");
		for (p in actions) {
			var main = p.parentElement.parentElement;
			var id = main.parentElement.dataset.id;
			p.addEventListener("click", () -> {
				new ContextMenu(main, menuLabels, (choice) -> {
					if (choice == 1) {
						new AmountChoice(menuLabels[choice], "Quel modificateur appliquer ?", {canBeNegative: true}, (result) -> {
							if (result == 0)
								return;

							Api.pushEvent(fiche_id, CHANGE_CARAC(id.parseCarac(), result));
						});
					}
					return true;
				});
			});
		}
	}

	function bindHPActions() {
		var p = mainElem.querySelector(".hp .plus");
		p.addEventListener("click", () -> {
			var menuLabels = ["Retirer des PV (dégats)", "Ajouter des PV (soins)"];
			new ContextMenu(p.parentElement.parentElement, menuLabels, (choice) -> {
				new AmountChoice(menuLabels[choice], if (choice == 0) "Combien de PV retirer ?" else "Combien de PV ajouter ?", (result) -> {
					if (result == 0)
						return;

					if (choice == 0)
						result = -result;

					Api.pushEvent(fiche_id, CHANGE_HP(result));
				});
				return true;
			});
		});
	}

	function bindMenu() {
		mainElem.querySelector("a.see-dice-rolls").addEventListener("click", () -> {
			new DiceRollHistory(fiche_id, fieldsNames);
		});
		mainElem.querySelector("a.history").addEventListener("click", () -> {
			new FicheEventHistory(fiche_id, ficheEvents);
		});
	}

	function bindD20() {
		mainElem.addEventListener('click', (e:MouseEvent) -> {
			var elem:Element = cast e.target;
			if (elem.classList.contains("d20") || elem.classList.contains("mod")) {
				rollD20(elem);
			}
		});
	}

	function getField(parentElement:Element, id:String) {
		var elem = parentElement.querySelector('[data-id="$id"]');
		if (elem == null)
			return null;

		var e:Element = cast elem;
		var value = e.querySelector(".value");
		if (value != null)
			e = value;
		var mod = e.querySelector(".mod");
		if (mod != null)
			e = mod;

		return e;
	}

	@:jsasync function rollD20(elem:Element) {
		var parent = elem.parentElement;
		var modInt = null;
		if (parent.querySelector(".mod") != null) {
			var mod = parent.querySelector(".mod").innerText.replace(" ", "");
			if (mod.contains("d")) // It's not a d20?
			{
				var diceRegex = ~/([1-9])d([1-9][0-9]*)((\+|-)[0-9]+)/;
				diceRegex.match(mod);
				var numDice = diceRegex.matched(1).parseInt();
				var diceType = diceRegex.matched(2).parseInt();
				var mod = diceRegex.matched(3).parseInt();
				if (numDice > 1) {
					new Alert("Non implémenté", "Plus qu'un seul dé à la fois non implémenté");
					return 0;
				}

				var apiResult = Api.rollDice(fiche_id, diceType, parent.dataset.id).jsawait();
				D20.roll(mod, apiResult.result, diceType);
				return apiResult.result + mod;
			}
			modInt = Std.parseInt(mod);
		}
		while (parent.dataset.id == null && parent != Browser.document.body) {
			parent = parent.parentElement;
		}
		if (parent == Browser.document.body) {
			throw "Cannot find parent id for this dice roll";
		}

		var apiResult = Api.rollDice(fiche_id, 20, parent.dataset.id).jsawait();
		D20.roll(modInt, apiResult.result);
		return apiResult.result;
	}

	static public function convertFieldName(apiFieldName:String) {
		var kCase = "";
		for (i in 0...apiFieldName.length) {
			var c = apiFieldName.charAt(i);
			if (c == c.toUpperCase()) {
				kCase += "-";
			}
			kCase += c.toLowerCase();
		}

		return kCase;
	}

	private function addWeapon(weapon:Weapon) {
		var divWeapon = Browser.document.createDivElement();
		divWeapon.classList.add("weapon");
		divWeapon.innerHTML = "
            <h3></h3>
            <div class='field-line'>
                <div class='field s' data-id='attack'>
                    <div class='label'>Pour toucher</div>
                    <div class='value mod num'><span class='d20'></span><span class='mod'></span></div>
                </div>
                <div class='field s' data-id='critical'>
                    <div class='label'>Critique</div>
                    <div class='value num'></div>
                </div>
                <div class='field s' data-id='damage'>
                    <div class='label'>Dégats</div>
                    <div class='value mod num'></div>
                </div>
            </div>
            <div class='field-line'>
                <div class='field s' data-id='type'>
                    <div class='label'>Type</div>
                    <div class='value'></div>
                </div>
                <div class='field xs' data-id='range'>
                    <div class='label'>Portée</div>
                    <div class='value num'></div>
                </div>
                <div class='field s' data-id='ammo'>
                    <div class='label'>Munitions</div>
                    <div class='value'></div>
                </div>
            </div>";

		divWeapon.querySelector("h3").innerText = weapon.name;
		getField(divWeapon, "ammo").innerText = weapon.munitions;
		getField(divWeapon, "range").innerText = if (weapon.range != null) '${weapon.range}c' else 'Contact';
		getField(divWeapon, "type").innerText = [
			for (dt in weapon.damage_types)
				switch (dt) {
					case PERFORANT:
						"Perforant";
					case TRANCHANT:
						"Tranchant";
					case CONTONDANT:
						"Contondant";
				}
		].join(" / ");
		getField(divWeapon,
			"attack").innerText = (character.getCaracMod(weapon.weaponAttackCharacteristic) + Rules.getSizeMod(character, false) + Rules.getBBA(character)
				+ weapon.attack_modifier).asMod();
		getField(divWeapon,
			"damage").innerText = [for (d in weapon.damage_dices) '1d' + d].join(" + ")
				+ " "
				+ (weapon.damage_modifier + character.getCaracMod(weapon.weaponDamageCharacteristic)).asMod(true);

		getField(divWeapon, "critical").innerHTML = "Si " + weapon.critical_text.nums.join(",") + ": x" + weapon.critical_text.damageMultiplier;
		mainElem.querySelector(".weapons").appendChild(divWeapon);

		fieldsNames.set("damage", "Dégats d'arme");
		fieldsNames.set("attack", "Jet pour toucher");
	}

	private function updateCharacts() {
		character.characteristicsMod = cast {};
		for (i in Reflect.fields(character.characteristics)) {
			var value:Int = Reflect.getProperty(character.characteristics, i);
			var mod:Int = Std.int(value / 2) - 5;
			Reflect.setProperty(character.characteristicsMod, i, mod);
			availableFields.get(i).innerText = Std.string(value);
			var modField = availableFields.get(i).parentElement.querySelector(".mod");
			modField.innerText = mod.asMod(false);
		}
	}

	private function updateHP() {
		character.current_hp = Rules.getMaxHitPoints(character);
	}

	private function calculateFields() {
		if (character.characteristics == null)
			return;

		var vd = Rules.getVD(character);
		availableFields.get("speed").innerText = '${vd}c par tour';
		var dexMod = character.characteristicsMod.dex;
		availableFields.get("initiative").innerText = dexMod.asMod(true);

		var maxHP = Rules.getMaxHitPoints(character).string();
		availableFields.get("hp-max").innerText = maxHP;
		availableFields.get("hp").innerText = character.current_hp.string();
		availableFields.get("non-lethal-max").innerText = maxHP;
		availableFields.get("non-lethal-damages").innerText = 0.string();

		availableFields.get("ac").innerText = Rules.getAC(character).string();
		availableFields.get("ac-contact").innerText = Rules.getACContact(character).string();
		availableFields.get("ac-surprise").innerText = Rules.getACSurprise(character).string();

		availableFields.get("saving-reflexes").innerText = Rules.getSavingThrowMod(character, REFLEXES).asMod(true);
		availableFields.get("saving-vigor").innerText = Rules.getSavingThrowMod(character, VIGOR).asMod(true);
		availableFields.get("saving-will").innerText = Rules.getSavingThrowMod(character, WILL).asMod(true);
		availableFields.get("bba").innerText = Rules.getBBA(character).asMod(true);
		availableFields.get("bmo").innerText = Rules.getBMO(character).asMod(true);
		availableFields.get("dmd").innerText = Rules.getDMD(character).string();
		availableFields.get("level").innerText = character.level.string();

		addSkills();
	}

	function addSkills() {
		var skillsDiv = mainElem.querySelector(".skills");
		skillsDiv.innerHTML = "<h2>Compétences</h2>";

		for (skill in character.getSkillsMods()) {
			var skillDiv = Browser.document.createDivElement();
			skillDiv.classList.add("skill");
			skillDiv.dataset.id = 'skill-${skill.id}';
			skillDiv.innerHTML = "
				<div class='actions-hover'>
					<a class='plus'>+</a>
				</div>
                <div class='label'></div>
                <div class='mod'></div>
                <div class='ranks'></div>
                <div class='skill-mod'></div>
			";

			skillDiv.querySelector(".label").innerHTML = skill.label + (if (skill.classSkill) " <ins title='Compétence de classe'>(C)</ins>" else "");
			if (skill.canUse)
				skillDiv.querySelector(".mod").innerText = skill.mod.asMod();

			if (character.skillModifiers.exists(skill.name)) {
				skillDiv.querySelector(".skill-mod").innerText = character.skillModifiers.get(skill.name).asMod();
				skillDiv.classList.add("has-skill-mod");
			}

			skillDiv.querySelector(".ranks").innerText = skill.ranks.string();

			skillDiv.classList.add("class-skill");

			skillDiv.querySelector(".actions-hover .plus").addEventListener("click", () -> {
				var choicesText = [
					"Ajouter un rang",
					"Retirer un rang",
					"(Ajouter un modificateur permanent)",
					"(Ajouter un modificateur temporaire)",
				];
				var menu = new ContextMenu(skillDiv, choicesText, (choice:Int) -> {
					if (choice == 0 || choice == 1) {
						if (choice == 1 && skill.ranks == 0) {
							new Alert("Action impossible", "Aucun rang à retirer sur " + skill.label);
							return true;
						}

						var text = choicesText[choice];
						new YesNoAlert("Confirmer ?", text + " à la compétence " + skill.label + " ?", () -> {
							if (choice == 0)
								Api.pushEvent(fiche_id, TRAIN_SKILL(skill.name));
							else
								Api.pushEvent(fiche_id, DECREASE_SKILL(skill.name));
						});
					} else {
						new Alert("Non implémenté", "Cette fonctionnalité n'est pas encore implémentée");
					}
					return true;
				});
			});

			skillsDiv.appendChild(skillDiv);

			fieldsNames.set(skillDiv.dataset.id, skill.label);
		}
	}

	@:jsasync private function load(fiche_id:String) {
		var ficheIdRegex = ~/^[0-9a-f-]{36}$/;
		if (!ficheIdRegex.match(fiche_id))
			return;

		var result:Array<FicheEventTs> = Api.load('/fiche/$fiche_id').jsawait();
		ficheEvents = result;
		var startTime = Date.now().getTime();
		trace('Fetched ${result.length} events for this fiche');
		for (i in result) {
			processEvent(i.type);
		}

		calculateFields();
		var elapsed = Date.now().getTime() - startTime;
		trace('Fiche processed in ${elapsed}ms');

		ws = new WsTalker(() -> {
			ws.subscribe(fiche_id, ficheEvents[ficheEvents.length - 1].id);
		}, () -> {});
		ws.onNewEvent = (fiche_id:String, event:FicheEventTs) -> {
			if (fiche_id == this.fiche_id) {
				ficheEvents.push(event);
				processEvent(event.type);
				calculateFields();
			}
		};
	}

	function processEvent(type:FicheEventType) {
		switch (type) {
			case CREATE(data):
				this.character.basics = data;
				var outData:Dynamic = Reflect.copy(data);
				outData.alignement = data.alignement.alignementToString();
				outData.characterClass = data.characterClass.classToString();
				outData.sizeCategory = data.sizeCategory.sizeCategoryToString();
				for (f in Reflect.fields(data)) {
					var fieldName = convertFieldName(f);
					if (availableFields.exists(fieldName)) {
						var value = Reflect.getProperty(outData, f);
						if (Std.is(value, Int)) {
							value = Std.string(value);
						}
						if (Std.is(value, String)) {
							availableFields.get(fieldName).innerHTML = value;
						} else {
							trace('Invalid value for $fieldName: $value');
						}
					} else {
						Browser.console.warn('[PFB] Field does not exist: $fieldName');
					}
				}
			case SET_CHARACTERISTICS(data):
				this.character.characteristics = data;
				updateCharacts();
				updateHP();
			case ADD_CLASS_SKILL(skill):
				if (!Rules.isClassSkill(character, skill))
					this.character.additionalClassSkills.push(skill);

			case CHANGE_CARAC(c, amount):
				switch (c) {
					case STRENGTH: this.character.characteristics.str += amount;
					case DEXTERITY: this.character.characteristics.dex += amount;
					case CONSTITUTION:
						var oldMod = Math.floor(this.character.characteristics.con / 2);
						this.character.characteristics.con += amount;
						var newMod = Math.floor(this.character.characteristics.con / 2);
						// We need to update current HP depending on mod
						var diffHP = (newMod - oldMod) * character.level;
						if (diffHP > 0) character.current_hp = Math.min(character.current_hp + diffHP, character.getMaxHitPoints()).int();
					case INTELLIGENCE: this.character.characteristics.int += amount;
					case WISDOM: this.character.characteristics.wis += amount;
					case CHARISMA: this.character.characteristics.cha += amount;
				}
				updateCharacts();
			case ADD_WEAPON(weapon):
				addWeapon(weapon);
			case LEVEL_UP(hp_dice):
				character.level += 1;
				hp_dice = Math.min(hp_dice, Rules.getHitDice(character.basics.characterClass)).int(); // ?
				character.levelUpDices.push(hp_dice);
			case TRAIN_SKILL(skill):
				character.skillRanks.push(skill);
			case DECREASE_SKILL(skill):
				character.skillRanks.remove(skill);
			case CHANGE_HP(amount):
				character.current_hp = Math.min(character.current_hp + amount, character.getMaxHitPoints()).int();
			case CHANGE_MAX_HP(amount):
				character.max_hp_modifier += amount;
			case SET_SKILL_MODIFIER(skill, mod):
				character.skillModifiers.set(skill, mod);
		}
	}

	@:expose("debug")
	static public function debug(what:String, param1:String, param2:String, param3:String, param4:String, param5:String, param6:String) {
		var ficheId = Browser.window.location.pathname.split("/")[2];
		if (what == "caracroll") {
			generateCharac(ficheId);
			return "Ok";
		} else if (what == "maxhp") {
			Api.pushEvent(ficheId, CHANGE_MAX_HP(param1.parseInt()));
			return "Ok";
		} else if (what == "levelup") {
			Api.pushEvent(ficheId, LEVEL_UP(param1.parseInt()));
			return "Ok";
		} else if (what == "skillmod") {
			var skill = SkillType.createByName(param1.toUpperCase());
			if (skill == null) {
				return "Skill type not found";
			}
			Api.pushEvent(ficheId, SET_SKILL_MODIFIER(skill, param2.parseInt()));
			return "Ok";
		} else if (what == "caracset") {
			Api.pushEvent(ficheId, SET_CHARACTERISTICS({
				str: param1.parseInt(),
				dex: param2.parseInt(),
				con: param3.parseInt(),
				int: param4.parseInt(),
				wis: param5.parseInt(),
				cha: param6.parseInt(),
			}));
			return "Ok";
		} else if (what == "weapon") {
			debugAddWeapon(ficheId);
			return "Ok";
		} else if (what == "cskill") {
			var skill = SkillType.createByName(param1.toUpperCase());
			if (skill == null) {
				return "Skill type not found";
			}
			Api.pushEvent(ficheId, ADD_CLASS_SKILL(skill));
		}

		return 'Unknown debug $what';
	}

	static public function debugIncreaseSkill(ficheId:String, skillName:String) {
		var skill = SkillType.createByName(skillName.toUpperCase());
		if (skill == null) {
			return "Skill type not found";
		}
		Api.pushEvent(ficheId, TRAIN_SKILL(skill));
		return "Ok";
	}

	static public function debugAddWeapon(ficheId:String) {
		Api.pushEvent(ficheId, ADD_WEAPON({
			name: "Arc Court",
			attack_modifier: 0,
			damage_modifier: 0,
			weaponDamageCharacteristic: DEXTERITY,
			weaponAttackCharacteristic: DEXTERITY,
			damage_types: [PERFORANT],
			munitions: "Illimitées",
			range: 12,
			critical_text: {
				nums: [20],
				damageMultiplier: 3
			},
			damage_dices: [6]
		}));
	}

	static public function generateCharac(ficheId:String) {
		var charac = GetAllFields.getNames(Characteristics);
		var obj = {};
		for (i in charac) {
			var values = [for (i in 0...4) dice(6)];
			values.sort((a, b) -> a - b);
			values.splice(0, 1);
			var total = values.fold((i, r) -> i + r, 0);
			Reflect.setField(obj, i, total);
		}
		trace(obj);
		Api.pushEvent(ficheId, SET_CHARACTERISTICS(cast obj));
	}
}
