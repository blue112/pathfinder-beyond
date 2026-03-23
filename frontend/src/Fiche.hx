import jsasync.JSAsync;
import jsasync.Nothing;
import js.lib.Promise;
import haxe.Resource;
import js.html.MouseEvent;
import RulesSkills.SkillType;
import js.html.DivElement;
import macros.GetAllFields;
import js.html.Element;
import haxe.ds.StringMap;
import jsasync.IJSAsync;
import js.Browser;
import elems.*;

using DateTools;
using Rules;

class Fiche implements IJSAsync {
    var availableFields:StringMap<Element>;
    var character:FullCharacter;
    var fiche_id:String;

    var fieldsNames:StringMap<String>;
    var ficheEvents:Array<FicheEventTs>;

    var mainElem:DivElement;
    var ws:WsTalker;
    var currentSpellPopup:Null<elems.SpellListPopup>;

    public function new(fiche_id:String) {
        mainElem = Browser.document.createDivElement();
        mainElem.classList.add("fiche");

        this.fiche_id = fiche_id;

        character = new FullCharacter();

        mainElem.innerHTML = Resource.getString("fiche.html");

        Browser.document.body.appendChild(mainElem);

        availableFields = new StringMap();
        fieldsNames = new StringMap();
        fieldsNames.set("libre", "Lancé de dé libre");
        for (r in elems.FreeDiceDialog.contactRolls)
            fieldsNames.set(r.id, r.label);
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
        bindMoneyActions();
        bindFightActions();
        bindACActions();
        bindSavingThrowActions();
        bindSpeedActions();
        bindInitiativeActions();
        bindChangeAlignementAction();

        load(fiche_id);
    }

    function pushEvent(event:FicheEventType) {
        Api.pushEvent(fiche_id, event);
    }

    function bindFightActions() {
        var menuLabels = ["Ajouter une arme"];
        var action = mainElem.querySelector("section.fight h2 .plus");
        action.addEventListener("click", () -> {
            new ContextMenu(action.parentElement.parentElement, menuLabels, (choice) -> {
                new WeaponDialog(menuLabels[choice], (weapon:Weapon) -> {
                    pushEvent(ADD_WEAPON(weapon));
                });
                return true;
            });
        });
    }

    function bindMoneyActions() {
        var action = mainElem.querySelector("[data-id=po] .plus");
        action.addEventListener("click", () -> {
            new ContextMenu(cast action, ["Ajouter/retirer des PO", "Ajouter/retirer en banque"], (choice) -> {
                if (choice == 0) {
                    new AmountChoice('Ajouter/retirer des PO', "Combien de PO ajouter ou retirer ?", {canBeNegative: true}, (value, _) -> {
                        if (value != 0)
                            pushEvent(CHANGE_MONEY(value));
                    });
                } else if (choice == 1) {
                    new AmountChoice('Ajouter/retirer des PO en banque', "Combien de PO ajouter ou retirer ?", {canBeNegative: true}, (value, _) -> {
                        if (value != 0)
                            pushEvent(CHANGE_BANK_MONEY(value));
                    });
                }
                return true;
            });
        });
        var bankAction = mainElem.querySelector("[data-id=bank-po] .plus");
        bankAction.addEventListener("click", () -> {
            new AmountChoice('Ajouter/retirer des PO en banque', "Combien de PO ajouter ou retirer ?", {canBeNegative: true}, (value, _) -> {
                if (value != 0)
                    pushEvent(CHANGE_BANK_MONEY(value));
            });
        });
        mainElem.querySelector(".spells-btn").addEventListener("click", (e:js.html.MouseEvent) -> {
            if (!e.shiftKey) return;
            new elems.SpellListPopup(character, pushEvent, (p) -> { currentSpellPopup = p; }, fiche_id);
        });
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
        var hd = character.getHitDice();
        var diceRoll = Api.rollDice(fiche_id, hd, 0, "level").jsawait();
        var result = diceRoll.result;
        new Alert("Montée de niveau", 'Résultat du lancer de dé de point de vie (d${hd}): $result');
        pushEvent(LEVEL_UP(result));
    }

    function bindInitiativeActions() {
        var plus = mainElem.querySelector(".initiative .plus");
        makeTempModMenu(plus, plus.parentElement.parentElement, INITIATIVE);
    }

    function bindCaracActions() {
        var actions = mainElem.querySelectorAll(".carac .plus");
        for (p in actions) {
            var main = p.parentElement.parentElement;
            var id = main.parentElement.dataset.id;
            makeTempModMenu(cast p, main, CHARACTERISTIC(id.parseCarac()), ["Modifier la valeur"], (_) -> {
                new AmountChoice("Modifier la valeur", "Quel modification de valeur appliquer ?", {canBeNegative: true}, (result, _) -> {
                    if (result == 0)
                        return;

                    pushEvent(CHANGE_CARAC(id.parseCarac(), result));
                });
            });
        }
    }

    function bindSpeedActions() {
        var plus = mainElem.querySelector(".speed .plus");
        plus.addEventListener("click", () -> {
            new AmountChoice("Modificateur de déplacement", "Quel modificateur appliquer (en cases) ?", {canBeNegative: true}, (result, _) -> {
                pushEvent(SET_SPEED_MODIFIER(result));
            });
        });
    }

    function bindSavingThrowActions() {
        var actions = mainElem.querySelectorAll(".saving .plus");
        for (p in actions) {
            var main = p.parentElement.parentElement;
            var id = main.parentElement.dataset.id;
            var st = switch (id) {
                case "saving-will": WILL;
                case "saving-reflexes": REFLEXES;
                case "saving-vigor": VIGOR;
                default: throw "Unknown saving throw " + id;
            };
            makeTempModMenu(cast p, main, SAVING_THROW(st), ["Ajouter un modificateur permanent"], (choice) -> {
                if (choice == 1)
                    new AmountChoice("Ajouter un modificateur permanent", "Quel modificateur appliquer ?", {canBeNegative: true}, (result, _) -> {
                        pushEvent(SET_SAVING_THROW_MODIFIER(st, result));
                    });
            });
        }
    }

    function bindChangeAlignementAction() {
        var plus = mainElem.querySelector(".field[data-id=alignement] .plus");
        plus.addEventListener("click", () -> {
            var all = CharacterAlignement.createAll();
            new ChoicesDialog("Changer l'alignement", all.map(a -> a.alignementToString()), (choice) -> {
                pushEvent(CHANGE_ALIGNEMENT(all[choice]));
            });
        });
    }

    function bindACActions() {
        var action = mainElem.querySelector(".ac .plus");
        makeTempModMenu(action, action.parentElement.parentElement, AC, ["Ajouter une protection"], (_) -> {
            new AddProtectionDialog((protection) -> {
                pushEvent(ADD_PROTECTION(protection));
            });
        });
    }

    function bindHPActions() {
        var p = mainElem.querySelector(".hp .plus");
        p.addEventListener("click", () -> {
            var resistCount = [for (_ in character.damageResistances.keys()) true].length;
            var menuLabels = [
                "Retirer des PV (dégats)",
                "Ajouter des PV (soins)",
                "Ajouter une résistance",
                'Voir les résistances ($resistCount)'
            ];
            new ContextMenu(p.parentElement.parentElement, menuLabels, (choice) -> {
                if (choice == 0) {
                    new DamageChoice((amount, damageType) -> {
                        if (amount == 0)
                            return;
                        pushEvent(DAMAGE_HP(amount, damageType));
                    });
                } else if (choice == 1) {
                    new AmountChoice(menuLabels[choice], "Combien de PV ajouter ?", (result, _) -> {
                        if (result == 0)
                            return;
                        pushEvent(CHANGE_HP(result));
                    });
                } else if (choice == 2) {
                    new ResistanceChoice((amount, damageType) -> {
                        if (amount == 0)
                            return;
                        pushEvent(ADD_DAMAGE_RESISTANCE(damageType, amount));
                    });
                } else if (choice == 3) {
                    new ResistancesList(fiche_id, character.damageResistances);
                }
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
        mainElem.querySelector("a.see-temp-mods").addEventListener("click", () -> {
            new TemporaryModifiersList(fiche_id, character.tempMods);
        });
        mainElem.querySelector("a.roll-free-dice").addEventListener("click", () -> {
            new FreeDiceDialog((choice) -> {
                if (FreeDiceDialog.isContactRoll(choice)) {
                    var roll = FreeDiceDialog.contactRollForIndex(choice);
                    var bba = Rules.getBBA(character);
                    var caracMod = if (roll.id == "contact-cac") character.characteristicsMod.str else character.characteristicsMod.dex;
                    var sizeMod = Rules.getSizeMod(character, false);
                    var mods = if (sizeMod != 0) [bba, caracMod, sizeMod] else [bba, caracMod];
                    doDiceRoll(mods, roll.id);
                } else {
                    rollFreeDice(FreeDiceDialog.diceForIndex(choice));
                }
            });
        });
        mainElem.querySelector("a.new-day").addEventListener("click", () -> {
            new YesNoAlert("Nouveau jour", 'Confirmer le début d\'un nouveau jour ? Les sorts préparés seront réinitialisés et le personnage récupère ${character.level} PV.', () -> {
                pushEvent(NEW_DAY);
            });
        });
    }

    @:jsasync function rollFreeDice(faces:Int) {
        var apiResult = Api.rollDice(fiche_id, faces, 0, "libre").jsawait();
        Dice.roll([], apiResult.result, faces);
    }

    function bindD20() {
        mainElem.addEventListener('click', (e:MouseEvent) -> {
            var elem:Element = cast e.target;
            if (elem.classList.contains("d20") || elem.classList.contains("mod")) {
                rollDice(elem);
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

    @:jsasync function rollDice(elem:Element, ?additionalMod:Int) {
        var parent = elem.parentElement;
        var modInt = null;
        if (parent.querySelector(".mod") != null) {
            var mod = parent.querySelector(".mod").innerText.replace(" ", "");
            if (mod.contains("d")) // It's not a d20
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

                var apiResult = Api.rollDice(fiche_id, diceType, mod, parent.parentElement.dataset.id).jsawait();
                Dice.roll([mod], apiResult.result, diceType);
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

        var expModEnum = if (parent.dataset.id.startsWith("saving-")) {
            SAVING_THROW(SavingThrow.createByName(parent.dataset.id.split("-")[1].toUpperCase()));
        } else if (parent.dataset.id == "attack") WEAPON_ATTACK else if (parent.dataset.id == "damage") WEAPON_DAMAGE else null;

        var reloadableWeaponIdx:Null<Int> = null;
        if (parent.dataset.id == "attack") {
            var weaponDiv = parent.parentElement;
            while (weaponDiv != null && !weaponDiv.classList.contains("weapon"))
                weaponDiv = weaponDiv.parentElement;
            if (weaponDiv != null) {
                var widx = Std.parseInt(weaponDiv.dataset.weaponIdx);
                if (character.weapons[widx] != null && character.weapons[widx].shouldBeReloaded == true)
                    reloadableWeaponIdx = widx;
            }
        }

        var savingThrowNote:Null<String> = null;
        if (expModEnum != null) {
            switch (expModEnum) {
                case SAVING_THROW(st):
                    var noteMods = character.exceptionalModifiers.filter(s -> Type.enumEq(s.on, SAVING_THROW_NOTE(st)));
                    if (noteMods.length > 0)
                        savingThrowNote = noteMods[0].why;
                case _:
            }
            var expMods = character.exceptionalModifiers.filter(s -> Type.enumEq(s.on, expModEnum));
            if (expMods.length > 0) {
                new ChoicesDialog("Lancer avec modificateur ?", ["Normal"].concat(expMods.map(n -> '${n.why} (${n.mod.asMod()})')), (choice) -> {
                    (if (choice == 0)
                        doDiceRoll([modInt], parent.dataset.id, savingThrowNote)
                    else {
                        var mod = expMods[choice - 1];
                        doDiceRoll([modInt, mod.mod], parent.dataset.id, savingThrowNote);
                    }).then((_) -> if (reloadableWeaponIdx != null) pushEvent(FIRE_WEAPON(reloadableWeaponIdx)));
                });
                return null;
            }
        }

        var mods = [modInt];
        if (additionalMod != null && additionalMod != 0)
            mods.push(additionalMod);

        var result = doDiceRoll(mods, parent.dataset.id, savingThrowNote).jsawait();
        if (reloadableWeaponIdx != null)
            pushEvent(FIRE_WEAPON(reloadableWeaponIdx));
        return result;
    }

    @:jsasync public function doDiceRoll(mods:Array<Int>, id:String, ?note:String) {
        var apiResult = Api.rollDice(fiche_id, 20, mods.fold((m, r) -> m + r, 0), id).jsawait();
        Dice.roll(mods, apiResult.result, 20, note);
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

    private function updateWeapons() {
        var weaponsSection = mainElem.querySelector(".weapons");
        weaponsSection.innerHTML = "<h2>Armes</h2>";

        for (idx in 0...character.weapons.length)
            addWeapon(character.weapons[idx], idx);

        if (character.weapons.length <= 1)
            return;

        var weaponDivs = weaponsSection.querySelectorAll(".weapon");
        var tabsDiv = Browser.document.createDivElement();
        tabsDiv.classList.add("weapon-tabs");

        for (idx in 0...character.weapons.length) {
            var tab = Browser.document.createDivElement();
            tab.classList.add("weapon-tab");
            tab.innerText = character.weapons[idx].name;
            tab.dataset.label = character.weapons[idx].name;
            if (idx == 0)
                tab.classList.add("active");
            else
                (cast weaponDivs.item(idx) : Element).classList.add("hidden");
            tab.addEventListener("click", () -> {
                tabsDiv.querySelector(".weapon-tab.active").classList.remove("active");
                (cast weaponsSection.querySelector(".weapon:not(.hidden)") : Element).classList.add("hidden");
                (cast weaponDivs.item(idx) : Element).classList.remove("hidden");
                tab.classList.add("active");
            });
            tabsDiv.appendChild(tab);
        }

        weaponsSection.insertBefore(tabsDiv, weaponDivs.item(0));
    }

    private function addWeapon(weapon:Weapon, idx:Int) {
        var divWeapon = Browser.document.createDivElement();
        divWeapon.classList.add("weapon");
        divWeapon.dataset.weaponIdx = Std.string(idx);
        divWeapon.innerHTML = Resource.getString("weapon.html");

        divWeapon.querySelector("h3 span").innerText = weapon.name;
        var plus = divWeapon.querySelector("h3 .plus");
        plus.addEventListener("click", () -> {
            new ContextMenu(plus, ["Supprimer l'arme"], (choice) -> {
                if (choice == 0)
                    pushEvent(REMOVE_WEAPON(idx));
                return true;
            });
        });
        if (weapon.munitions != null && weapon.munitions != "")
            getField(divWeapon, "ammo").innerText = weapon.munitions;
        else
            getField(divWeapon, "ammo").innerText = "N/A";

        getField(divWeapon, "range").innerText = if (weapon.range != 0 && weapon.range != null) '${weapon.range}c' else 'Contact';
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

        var attackMod = character.getCaracMod(weapon.weaponAttackCharacteristic) + Rules.getSizeMod(character, false) + Rules.getBBA(character)
            + weapon.attack_modifier + character.getTempMods([WEAPON_ATTACK]).sum();

        character.applyTempModsClass(getField(divWeapon, "attack").parentElement.parentElement,
            [WEAPON_ATTACK, CHARACTERISTIC(weapon.weaponAttackCharacteristic)]);
        getField(divWeapon, "attack").innerText = attackMod.asMod();

        var damage = weapon.damage_modifier + character.getCaracMod(weapon.weaponDamageCharacteristic) + character.getTempMods([WEAPON_DAMAGE]).sum();
        if (weapon.weaponHasPlus50PercentDamage) {
            damage += Math.floor(character.getCaracMod(weapon.weaponDamageCharacteristic) / 2);
        }

        getField(divWeapon, "damage").innerText = [for (d in weapon.damage_dices) '1d' + d].join(" + ") + " " + damage.asMod(true);

        character.applyTempModsClass(getField(divWeapon, "damage").parentElement, [WEAPON_DAMAGE, CHARACTERISTIC(weapon.weaponDamageCharacteristic)]);
        getField(divWeapon, "critical").innerHTML = "Si " + weapon.critical_text.nums.join(",") + ": x" + weapon.critical_text.damageMultiplier;

        var plusAttack = divWeapon.querySelector("[data-id='attack'] a.plus");
        makeTempModMenu(plusAttack, plusAttack.parentElement.parentElement, WEAPON_ATTACK);
        var plusDamage = divWeapon.querySelector("[data-id='damage'] a.plus");
        makeTempModMenu(plusDamage, plusDamage.parentElement.parentElement, WEAPON_DAMAGE);

        if (weapon.shouldBeReloaded == true && character.firedWeapons.exists(idx)) {
            var overlay = Browser.document.createDivElement();
            overlay.className = "reload-overlay";
            var reloadBtn = Browser.document.createAnchorElement();
            reloadBtn.className = "reload-btn";
            reloadBtn.innerText = "Recharger";
            reloadBtn.addEventListener("click", () -> {
                new YesNoAlert("Recharger l'arme", "Recharger l'arme (nécessite une action de mouvement) ?", () -> {
                    pushEvent(RELOAD_WEAPON(idx));
                });
            });
            overlay.appendChild(reloadBtn);
            divWeapon.appendChild(overlay);
        }

        mainElem.querySelector(".weapons").appendChild(divWeapon);

        fieldsNames.set("damage", "Dégats d'arme");
        fieldsNames.set("attack", "Jet pour toucher");
    }

    private function updateCharacts() {
        for (i in Reflect.fields(character.characteristics)) {
            var value:Int = Reflect.getProperty(character.characteristics, i);
            var mod:Int = Reflect.getProperty(character.characteristicsMod, i);
            var tempMod = character.getTempMods([CHARACTERISTIC(i.parseCarac())]).sum();
            var valueField = availableFields.get(i);
            valueField.innerText = Std.string(value + tempMod);
            character.applyTempModsClass(valueField, [CHARACTERISTIC(i.parseCarac())]);
            var modField = valueField.parentElement.querySelector(".mod");

            character.applyTempModsClass(modField, [CHARACTERISTIC(i.parseCarac())]);

            modField.innerText = mod.asMod(false);
        }
    }

    function makeTempModMenu(plusElem:Element, attachMenuOn:Element, on:Field, ?otherLabels:Array<String>, ?onOtherChoices:Int->Void) {
        plusElem.addEventListener("click", () -> {
            var menuLabels = ['Ajouter un modificateur temporaire'];
            if (otherLabels != null)
                menuLabels = menuLabels.concat(otherLabels);
            new ContextMenu(attachMenuOn, menuLabels, (choice) -> {
                if (choice == 0) {
                    new AmountChoice(menuLabels[choice], "Quel modificateur appliquer ?", {canBeNegative: true, askReason: true}, (result, reason) -> {
                        pushEvent(ADD_TEMPORARY_MODIFIER({
                            mod: result,
                            why: reason,
                            on: on
                        }));
                    });
                } else if (onOtherChoices != null) {
                    onOtherChoices(choice);
                }
                return true;
            });
        });
    }

    private function updateAC(field:String, includeArmor:Bool, includeDex:Bool) {
        var acDiv = availableFields.get(field);

        var mod = character.getAC(includeArmor, includeDex);

        // Check if we have a temp modifier on that or on related characteristic
        var match = [];
        if (includeArmor) {
            match.push(AC);
            mod += character.getTempMods(match).sum();
        }
        if (includeDex)
            match.push(CHARACTERISTIC(DEXTERITY));

        var totalTempMod = character.getTempMods(match).sum();
        if (totalTempMod != 0) {
            acDiv.classList.add("temp-mod");
            if (totalTempMod < 0)
                acDiv.classList.add("negative");
        } else {
            acDiv.classList.remove("temp-mod");
        }

        // Check if we have an exceptional mod
        var expCA = character.exceptionalModifiers.filter(m -> m.on.match(AC));
        if (expCA.length > 0) {
            mainElem.querySelector('.ac').classList.add('exp');
            var expEl = mainElem.querySelector('.ac .exp');
            expEl.innerHTML = "";
            var whyEl:js.html.Element = cast Browser.document.createElement("strong");
            whyEl.innerText = expCA[0].why;
            expEl.appendChild(whyEl);
            expEl.appendChild(Browser.document.createTextNode(' : ${expCA[0].mod.asMod()} = ${mod + expCA[0].mod}')); // Fixme multiple CA mod
        }

        acDiv.innerText = mod.string();
    }

    private function updateSavingThrow(fieldId:String, st:SavingThrow) {
        var stDiv = availableFields.get(fieldId);

        var mod = Rules.getSavingThrowMod(character, st);

        // Check if we have a temp modifier on that or on related characteristic
        var totalTempMod = character.getTempMods([SAVING_THROW(st), CHARACTERISTIC(Rules.getSavingThrowCarac(st))]).sum();
        mod += character.getTempMods([SAVING_THROW(st)]).sum();
        if (totalTempMod != 0) {
            stDiv.parentElement.classList.add("temp-mod");
            if (totalTempMod < 0)
                stDiv.parentElement.classList.add("negative");
        } else {
            stDiv.parentElement.classList.remove("temp-mod");
        }

        stDiv.innerText = mod.asMod(true);
    }

    private function updateBasics() {
        var outBasics:Dynamic = Reflect.copy(character.basics);
        outBasics.alignement = character.basics.alignement.alignementToString();
        outBasics.characterClass = character.basics.characterClass.classToString();
        outBasics.sizeCategory = character.basics.sizeCategory.sizeCategoryToString();
        outBasics.race = character.basics.race.raceToString();
        outBasics.gender = character.basics.gender.genderToString();
        for (f in Reflect.fields(character.basics)) {
            var fieldName = convertFieldName(f);
            if (availableFields.exists(fieldName)) {
                var value = Reflect.getProperty(outBasics, f);
                if (Std.is(value, Int)) {
                    value = Std.string(value);
                }
                if (Std.is(value, String)) {
                    availableFields.get(fieldName).innerHTML = value;
                } else {
                    trace('Invalid value for $fieldName: $value');
                }
            } else if (fieldName != "use-predilection-h-p") {
                Browser.console.warn('[PFB] Field does not exist: $fieldName');
            }
        }
    }

    private function updateFiche() {
        if (currentSpellPopup != null) currentSpellPopup.render();
        elems.SpellCastPopup.registerFieldNames(character.spells, fieldsNames);
        updateBasics();
        var spellsSection = mainElem.querySelector("section.spells-section");
        if (character.basics.characterClass.canCastSpells()) {
            spellsSection.classList.remove("hidden");
        } else {
            spellsSection.classList.add("hidden");
        }
        if (character.characteristics == null) {
            new ChoicesDialog("Caractéristiques", ["Tirer les caractéristiques", "Saisir les valeurs manuellement"], (choice) -> {
                if (choice == 0)
                    new Alert("Non implémenté", "Le tirage aléatoire des caractéristiques n'est pas encore disponible.");
                else if (choice == 1)
                    new CaracInputDialog((caracs) -> pushEvent(SET_CHARACTERISTICS(caracs)));
            });
            return;
        }

        updateCharacts();

        Browser.document.title = character.basics.characterName + " - Pathfinder Beyond 1e";

        var vd = Rules.getVD(character);
        availableFields.get("speed").innerText = '${vd}c par tour';
        var dexMod = character.characteristicsMod.dex;

        var initField = availableFields.get("initiative");
        character.applyTempModsClass(initField.parentElement, [CHARACTERISTIC(DEXTERITY), INITIATIVE]);
        initField.innerText = (dexMod + character.getTempMods([INITIATIVE]).sum()).asMod(true);

        var maxHP = character.getMaxHitPoints().string();
        availableFields.get("hp-max").innerText = maxHP;
        availableFields.get("hp").innerText = character.current_hp.string();
        availableFields.get("non-lethal-max").innerText = maxHP;
        availableFields.get("non-lethal-damages").innerText = 0.string();

        updateAC("ac", true, true);
        updateAC("ac-contact", false, true);
        updateAC("ac-surprise", true, false);

        updateSavingThrow("saving-reflexes", REFLEXES);
        updateSavingThrow("saving-vigor", VIGOR);
        updateSavingThrow("saving-will", WILL);
        availableFields.get("bba").innerText = Rules.getBBA(character).asMod(true);
        availableFields.get("bmo").innerText = Rules.getBMO(character).asMod(true);
        availableFields.get("dmd").innerText = Rules.getDMD(character).string();
        availableFields.get("level").innerText = character.level.string();

        addSkills();
        addArmor();
        updateWeapons();
        updateInventory();

        availableFields.get("po").innerText = character.money_po.string();
        availableFields.get("bank-po").innerText = character.bank_po.string();
        mainElem.querySelector("[data-id=bank-po]").classList.toggle("hidden", character.bank_po == 0);

        if (character.tempMods.length > 0) {
            mainElem.querySelector(".see-temp-mods .count").innerText = character.tempMods.length.string();
        } else {
            mainElem.querySelector(".see-temp-mods .count").innerText = '';
        }
    }

    function addArmor() {
        var armorsDiv = mainElem.querySelector(".armorlist");
        armorsDiv.innerHTML = "<h2>Protections <small>(déjà appliquées à la CA)</small></h2>";
        for (i in 0...character.protections.length) {
            var p = character.protections[i];
            var armorDiv = Browser.document.createDivElement();
            armorDiv.classList.add("armor");
            var actionsHover = Browser.document.createDivElement();
            actionsHover.className = "actions-hover";
            var plus = Browser.document.createAnchorElement();
            plus.className = "plus";
            plus.innerText = "+";
            actionsHover.appendChild(plus);
            armorDiv.appendChild(actionsHover);
            var nameSpan = Browser.document.createSpanElement();
            nameSpan.className = "name";
            nameSpan.innerText = p.name;
            armorDiv.appendChild(nameSpan);
            var acSpan = Browser.document.createSpanElement();
            acSpan.className = "ac";
            acSpan.innerText = '${p.armor.asMod()} CA';
            armorDiv.appendChild(acSpan);
            plus.addEventListener("click", () -> {
                new ContextMenu(armorDiv, ["Supprimer la protection"], (choice) -> {
                    if (choice == 0)
                        pushEvent(REMOVE_PROTECTION(i));
                    return true;
                });
            });
            armorsDiv.appendChild(armorDiv);
        }
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

            var iconPath = skill.characteristic.characteristicToIconPath();
            var caracName = skill.characteristic.caracToString(false);
            var labelDiv = skillDiv.querySelector(".label");
            var img = Browser.document.createImageElement();
            img.src = iconPath;
            img.className = "carac-icon";
            img.title = caracName;
            img.alt = caracName;
            labelDiv.appendChild(img);
            labelDiv.appendChild(Browser.document.createTextNode(' ${skill.label}'));
            if (skill.classSkill) {
                var ins:js.html.Element = cast Browser.document.createElement("ins");
                ins.title = "Compétence de classe";
                ins.innerText = "(C)";
                labelDiv.appendChild(Browser.document.createTextNode(' '));
                labelDiv.appendChild(ins);
            }
            var mod = skill.mod + character.getTempMods([SKILL(skill.name)]).sum();
            if (skill.canUse)
                skillDiv.querySelector(".mod").innerText = mod.asMod();

            if (character.skillModifiers.exists(skill.name)) {
                skillDiv.querySelector(".skill-mod").innerText = character.skillModifiers.get(skill.name).asMod();
                skillDiv.classList.add("has-skill-mod");
            }

            // Check if we have a temp modifier on that or on related characteristic
            character.applyTempModsClass(skillDiv.querySelector(".mod"), [SKILL(skill.name), CHARACTERISTIC(skill.characteristic)]);
            skillDiv.querySelector(".ranks").innerText = skill.ranks.string();

            skillDiv.classList.add("class-skill");

            skillDiv.querySelector(".mod").addEventListener("click", (e:MouseEvent) -> {
                e.stopPropagation();
                var expMods = character.exceptionalModifiers.filter(s -> Type.enumEq(s.on, SKILL(skill.name)));
                if (expMods.length > 0) {
                    new ChoicesDialog("Lancer avec modificateur ?", ["Normal"].concat(expMods.map(n -> '${n.why} (${n.mod.asMod()})')), (choice) -> {
                        if (choice == 0)
                            rollDice(skillDiv.querySelector(".mod"));
                        else {
                            var mod = expMods[choice - 1];
                            rollDice(skillDiv.querySelector(".mod"), mod.mod);
                        }
                    });
                    return;
                }

                rollDice(skillDiv.querySelector(".mod"));
            });

            var plus = skillDiv.querySelector(".actions-hover .plus");
            var choicesText = ["Ajouter un rang", "Retirer un rang", "Ajouter un modificateur permanent"];
            makeTempModMenu(plus, skillDiv, SKILL(skill.name), choicesText, (choice) -> {
                if (choice == 1 || choice == 2) {
                    if (choice == 2 && skill.ranks == 0) {
                        new Alert("Action impossible", "Aucun rang à retirer sur " + skill.label);
                        return;
                    }

                    var text = choicesText[choice - 1];
                    new YesNoAlert("Confirmer ?", text + " à la compétence " + skill.label + " ?", () -> {
                        if (choice == 1)
                            pushEvent(TRAIN_SKILL(skill.name));
                        else
                            pushEvent(DECREASE_SKILL(skill.name));
                    });
                } else {
                    new Alert("Non implémenté", "Cette fonctionnalité n'est pas encore implémentée");
                }
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
            character.processEvent(i.type);
        }

        updateFiche();
        var elapsed = Date.now().getTime() - startTime;
        trace('Fiche processed in ${elapsed}ms');

        ws = new WsTalker(() -> {
            ws.subscribe(fiche_id, ficheEvents[ficheEvents.length - 1].id, false);
        }, () -> {});
        ws.onNewEvent = (fiche_id:String, event:FicheEventTs) -> {
            if (fiche_id == this.fiche_id) {
                ficheEvents.push(event);
                character.processEvent(event.type);
                updateFiche();
            }
        };

        loadNotes();
    }

    function updateInventory() {
        var inventory = mainElem.querySelector("section.inventory");
        inventory.innerHTML = "<h2>Inventaire</h2>
        <ul></ul>
    <a class='add-new'>Ajouter un nouvel objet</a>";

        var sorted = character.inventory.copy();
        sorted.sort((a, b) -> (if (a.priority == null) 0 else a.priority) - (if (b.priority == null) 0 else b.priority));

        for (item in sorted) {
            var li = Browser.document.createLIElement();
            li.innerHTML = "<div class='qty'><a class='change'>✎</a><span class='text'></span></div><div class='name'></div><div class='priority'></div><a class='delete' title='Supprimer'>X</a>";
            li.querySelector(".qty .text").innerText = item.quantity.string();
            li.querySelector(".name").innerText = item.name;
            li.querySelector(".priority").innerText = (if (item.priority == null) 0 else item.priority).string();
            li.querySelector(".delete").addEventListener('click', () -> {
                new YesNoAlert("Effacer un objet", 'Supprimer l\'objet ${item.name} de l\'inventaire ?', () -> {
                    pushEvent(REMOVE_INVENTORY_ITEM(character.inventory.indexOf(item)));
                });
            });
            li.querySelector(".change").addEventListener('click', () -> {
                new AmountChoice('Changer la quantité de l\'objet ${item.name}', "Nouvelle quantité ?", {defaultValue: item.quantity}, (newQty, _) -> {
                    if (newQty > 0) {
                        pushEvent(CHANGE_ITEM_QUANTITY(character.inventory.indexOf(item), newQty));
                    }
                });
            });
            li.querySelector(".name").addEventListener('click', () -> {
                new StringDialog('Changer le nom de l\'objet', "Nouveau nom", item.name, (newName) -> {
                    pushEvent(CHANGE_ITEM_NAME(character.inventory.indexOf(item), newName));
                });
            });
            li.querySelector(".priority").addEventListener('click', () -> {
                new AmountChoice('Priorité de l\'objet ${item.name}', "Priorité (−1000 à 1000)", {defaultValue: if (item.priority == null) 0 else item.priority, canBeNegative: true}, (newPriority, _) -> {
                    pushEvent(CHANGE_ITEM_PRIORITY(character.inventory.indexOf(item), newPriority));
                });
            });
            inventory.querySelector("ul").appendChild(li);
        }

        inventory.querySelector("a.add-new").addEventListener("click", () -> {
            new ItemDialog((quantity, name, priority) -> {
                pushEvent(ADD_INVENTORY_ITEM({
                    name: name,
                    quantity: quantity,
                    priority: priority
                }));
            });
        });
    }

    @:jsasync function loadNotes():Promise<Nothing> {
        var notes:Array<FicheNote> = Api.load('/fiche/$fiche_id/notes').jsawait();
        mainElem.querySelector(".notes")
            .innerHTML = "
    <h2>Notes<a class='refresh'>Recharger</a></h2>
    <ul></ul>
    <a class='add-new'>Ajouter une note</a>";
        var noteUl = mainElem.querySelector(".notes ul");
        for (n in notes) {
            var li = Browser.document.createLIElement();
            li.innerHTML = "<span class='text'></span><span class='date'></span>";
            li.querySelector(".text").innerText = n.content;
            li.querySelector(".date").innerText = "- " + Date.fromTime(n.last_edit).format("%d/%m/%Y %H:%M");
            noteUl.appendChild(li);

            li.addEventListener("click", () -> {
                new NoteDialog(n.content, (content) -> {
                    Api.saveNote(fiche_id, n.id, content).then((_) -> {
                        if (content.length == 0) {
                            noteUl.removeChild(li);
                            return;
                        }
                        li.querySelector(".text").innerText = content;
                        li.querySelector(".date").innerText = "- " + Date.now().format("%d/%m/%Y %H:%M");
                        n.content = content;
                        n.last_edit = Date.now().getTime();
                    });
                });
            });
        }

        mainElem.querySelector(".notes a.add-new").addEventListener("click", () -> {
            new NoteDialog(null, JSAsync.jsasync((value) -> {
                Api.saveNote(fiche_id, null, value).jsawait();
                loadNotes();
            }));
        });
        mainElem.querySelector(".notes a.refresh").addEventListener("click", () -> {
            mainElem.querySelector(".notes").innerHTML = "<h2>Chargement...</h2>";
            haxe.Timer.delay(loadNotes, 300);
        });
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
        } else if (what == "expskillmod") {
            var skill = SkillType.createByName(param1.toUpperCase());
            if (skill == null) {
                return "Skill type not found";
            }
            Api.pushEvent(ficheId, ADD_EXCEPTIONAL_MODIFIER({on: SKILL(skill), mod: param2.parseInt(), why: param3}));
            return "Ok";
        } else if (what == "expsavingmod") {
            var st = SavingThrow.createByName(param1.toUpperCase());
            if (st == null) {
                return "ST not found";
            }
            Api.pushEvent(ficheId, ADD_EXCEPTIONAL_MODIFIER({on: SAVING_THROW(st), mod: param2.parseInt(), why: param3}));
            return "Ok";
        } else if (what == "expsavingnote") {
            var st = SavingThrow.createByName(param1.toUpperCase());
            if (st == null) {
                return "ST not found";
            }
            Api.pushEvent(ficheId, ADD_EXCEPTIONAL_MODIFIER({on: SAVING_THROW_NOTE(st), mod: 0, why: param2}));
            return "Ok";
        } else if (what == "expattackmod") {
            Api.pushEvent(ficheId, ADD_EXCEPTIONAL_MODIFIER({on: WEAPON_ATTACK, mod: param1.parseInt(), why: param2}));
            return "Ok";
        } else if (what == "expacmod") {
            Api.pushEvent(ficheId, ADD_EXCEPTIONAL_MODIFIER({on: AC, mod: param1.parseInt(), why: param2}));
            return "Ok";
        } else if (what == "skillmod") {
            var skill = SkillType.createByName(param1.toUpperCase());
            if (skill == null) {
                return "Skill type not found";
            }
            Api.pushEvent(ficheId, SET_SKILL_MODIFIER(skill, param2.parseInt()));
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
