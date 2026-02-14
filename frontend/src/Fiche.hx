import js.html.MouseEvent;
import RulesSkills.SkillType;
import js.html.DivElement;
import macros.GetAllFields;
import js.html.Element;
import haxe.ds.StringMap;
import jsasync.IJSAsync;
import js.Browser;

using Rules;

class Fiche implements IJSAsync {
	var availableFields:StringMap<Element>;
	var character:FullCharacter;

	var mainElem:DivElement;

	public function new(fiche_id:String) {
		mainElem = Browser.document.createDivElement();
		mainElem.classList.add("fiche");

		character = {skillRanks: []};

		mainElem.innerHTML = "
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
                        <div class='value'></div>
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
                <div class='label'>FORCE</div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='dex'>
                <div class='label'>DEXTÉRITÉ</div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='con'>
                <div class='label'>CONSTITUTION</div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='int'>
                <div class='label'>INTELLIGENCE</div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='wis'>
                <div class='label'>SAGESSE</div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
            <div class='carac' data-id='cha'>
                <div class='label'>CHARISME</div>
                <div class='value'></div>
                <div class='mod'></div>
            </div>
        </section>
        <section class='hp'>
            <h2>Points de vie</h2>
            <div class='lethal'>
                <div class='label'>Points de Vie</div>
                <div class='value'>
                    <span class='current' data-id='hp'></span>
                    <span class='separator'>/</span>
                    <span class='max' data-id='hp-max'></span>
                </div>
            </div>
            <div class='non-lethal'>
                <div class='label'>Blessures non léthales</div>
                <div class='value'>
                    <span class='current' data-id='non-lethal-damages'></span>
                    <span class='separator'>/</span>
                    <span class='max' data-id='non-lethal-max'></span>
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

				availableFields.set(id, e);
			}
		}

		bindD20();

		load(fiche_id);
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

	function rollD20(elem:Element) {
		var parent = elem.parentElement;
		var mod = null;
		if (parent.querySelector(".mod") != null) {
			mod = Std.parseInt(parent.querySelector(".mod").innerText.replace(" ", ""));
		}
		D20.roll(mod);
	}

	function bindD20() {
		mainElem.addEventListener('click', (e:MouseEvent) -> {
			var elem:Element = cast e.target;
			if (elem.classList.contains("d20") || elem.classList.contains("mod")) {
				rollD20(elem);
			}
		});
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
			"attack").innerText = (character.getCaracMod(weapon.weaponAttackCharacteristic) + Rules.getBBA(character) + weapon.attack_modifier).asMod();
		getField(divWeapon,
			"damage").innerText = [for (d in weapon.damage_dices) '1d' + d].join(" + ")
				+ " + "
				+ (weapon.damage_modifier + character.getCaracMod(weapon.weaponDamageCharacteristic));

		getField(divWeapon, "critical").innerHTML = "Si " + weapon.critical_text.nums.join(",") + ": x" + weapon.critical_text.damageMultiplier;
		mainElem.querySelector(".weapons").appendChild(divWeapon);
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

	private function calculateFields() {
		if (character.characteristics == null)
			return;

		var vd = Rules.getVD(character);
		availableFields.get("speed").innerText = '${vd}c par tour';
		var dexMod = character.characteristicsMod.dex;
		availableFields.get("initiative").innerText = dexMod.asMod(true);

		var maxHP = Rules.getMaxHitPoints(character).string();
		availableFields.get("hp-max").innerText = maxHP;
		availableFields.get("hp").innerText = maxHP;
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

		addSkills();
	}

	function addSkills() {
		var skillsDiv = mainElem.querySelector(".skills");
		skillsDiv.innerHTML = "<h2>Compétences</h2>";

		for (skill in character.getSkillsMods()) {
			var skillDiv = Browser.document.createDivElement();
			skillDiv.classList.add("skill");
			skillDiv.innerHTML = "
                <div class='label'></div>
                <div class='mod'></div>
                <div class='ranks'></div>";

			skillDiv.querySelector(".label").innerHTML = skill.label + (if (skill.classSkill) " <ins title='Compétence de classe'>(C)</ins>" else "");
			if (skill.canUse)
				skillDiv.querySelector(".mod").innerText = skill.mod.asMod();
			skillDiv.querySelector(".ranks").innerText = skill.ranks.string();

			skillDiv.classList.add("class-skill");

			skillsDiv.appendChild(skillDiv);
		}
	}

	@:jsasync private function load(fiche_id:String) {
		var ficheIdRegex = ~/^[0-9a-f-]{36}$/;
		if (!ficheIdRegex.match(fiche_id))
			return;

		var result:Array<FicheEventType> = Api.load('/fiche/$fiche_id').jsawait();
		trace('Fetched ${result.length} events for this fiche');
		var startTime = Date.now().getTime();
		for (i in result) {
			switch (i) {
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
				case ADD_WEAPON(weapon):
					addWeapon(weapon);
				case TRAIN_SKILL(skill):
					character.skillRanks.push(skill);
			}
		}

		calculateFields();
		var elapsed = Date.now().getTime() - startTime;
		trace('Computed in ${elapsed}ms');
	}

	@:expose("debug")
	static public function debug(what:String, param1:String) {
		var ficheId = Browser.window.location.pathname.split("/")[2];
		if (what == "carac") {
			generateCharac(ficheId);
			return "Ok";
		} else if (what == "weapon") {
			debugAddWeapon(ficheId);
			return "Ok";
		} else if (what == "skill") {
			return debugIncreaseSkill(ficheId, param1);
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
