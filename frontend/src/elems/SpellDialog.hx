package elems;

import js.Browser;
import js.html.InputElement;
import js.html.SelectElement;
import Protocol;
import ProtocolUtil;
import jsasync.IJSAsync;

using ProtocolUtil;
using jsasync.JSAsyncTools;

class SpellDialog extends Popup implements IJSAsync {
    public function new(characterClass:CharacterClass, maxSpellLevel:Int, onChoice:Spell->Void) {
        super("Ajouter un sort");
        mainElem.classList.add("spell");

        getContent().innerHTML = '
        <div class="spell-form">
            <div class="spell-row spell-search-row">
                <label>Rechercher</label>
                <div class="spell-search-wrap">
                    <input type="text" name="spell-search" placeholder="Nom du sort..." autocomplete="off" />
                    <ul class="spell-suggestions hidden"></ul>
                </div>
            </div>
            <div class="spell-row">
                <label>Nom *</label>
                <input type="text" name="name" />
            </div>
            <div class="spell-row">
                <label>Niveau (0-9) *</label>
                <input type="number" name="level" min="0" max="9" value="1" />
            </div>
            <div class="spell-row">
                <label>École *</label>
                <select name="school">
                    <option value="ABJURATION">Abjuration</option>
                    <option value="CONJURATION">Invocation</option>
                    <option value="DIVINATION">Divination</option>
                    <option value="ENCHANTMENT">Enchantement</option>
                    <option value="EVOCATION">Évocation</option>
                    <option value="ILLUSION">Illusion</option>
                    <option value="NECROMANCY">Nécromancie</option>
                    <option value="TRANSMUTATION">Transmutation</option>
                    <option value="UNIVERSAL">Universel</option>
                </select>
            </div>
            <div class="spell-row">
                <label>Description courte</label>
                <input type="text" name="short-description" placeholder="Optionnelle" />
            </div>
            <div class="spell-row">
                <label>Utilisations / jour</label>
                <input type="number" name="uses-per-day" min="0" placeholder="Si pouvoir magique" />
            </div>
            <div class="spell-row">
                <label>Portée *</label>
                <select name="range">
                    <option value="PERSONAL">Personnelle</option>
                    <option value="TOUCH">Contact</option>
                    <option value="CLOSE">Courte</option>
                    <option value="MEDIUM">Moyenne</option>
                    <option value="LONG">Longue</option>
                    <option value="SPECIFIC">Spécifique</option>
                </select>
                <input type="text" name="range-specific" class="hidden sub-input" placeholder="ex: NLS/2 cases" />
            </div>
            <div class="spell-row">
                <label>Temps d\'incantation *</label>
                <select name="casting-time">
                    <option value="STANDARD_ACTION">Action simple</option>
                    <option value="FULL_ACTION">Action complexe</option>
                    <option value="N_ROUNDS">N rounds</option>
                    <option value="N_MINUTES">N minutes</option>
                </select>
                <input type="text" name="casting-time-n" class="hidden sub-input" placeholder="ex: NLS/2" />
            </div>
            <div class="spell-row">
                <label>Durée *</label>
                <select name="duration">
                    <option value="INSTANTANEOUS">Instantanée</option>
                    <option value="N_ROUNDS">N rounds</option>
                    <option value="N_MINUTES">N minutes</option>
                    <option value="CONCENTRATION">Concentration</option>
                </select>
                <input type="text" name="duration-n" class="hidden sub-input" placeholder="ex: NLS/2" />
            </div>
            <div class="spell-row can-end-row">
                <label>Peut être terminé volontairement</label>
                <input type="checkbox" name="can-end-voluntarily" />
            </div>
            <div class="spell-row">
                <label>Composantes</label>
                <span class="checkbox-group">
                    <label class="inline"><input type="checkbox" name="comp-verbal" checked /> Verbale</label>
                    <label class="inline"><input type="checkbox" name="comp-somatic" checked /> Gestuelle</label>
                    <label class="inline"><input type="checkbox" name="comp-material" /> Matérielle</label>
                </span>
            </div>
            <div class="spell-row">
                <label>Jet de sauvegarde</label>
                <select name="saving-throw">
                    <option value="">Aucun</option>
                    <option value="VIGOR">Vigueur</option>
                    <option value="REFLEXES">Réflexes</option>
                    <option value="WILL">Volonté</option>
                </select>
            </div>
            <div class="spell-row save-effect-row">
                <label>Résultat de sauvegarde</label>
                <select name="save-effect">
                    <option value="">Aucun</option>
                    <option value="HALF_DAMAGE">1/2 dégâts</option>
                    <option value="NEGATES">Annule</option>
                    <option value="REVEALS">Dévoile</option>
                </select>
            </div>
            <div class="spell-row saving-throw-dc-row">
                <label>DD du jet de sauvegarde</label>
                <input type="text" name="saving-throw-dc" placeholder="ex: 10 + NLS/2 + CHA" />
            </div>
            <div class="spell-row">
                <label>Résistance à la magie</label>
                <input type="checkbox" name="spell-resistance" />
            </div>
            <div class="spell-row">
                <label>Cibles</label>
                <input type="text" name="targets" placeholder="ex: 1 créature, NLS créatures..." />
            </div>
            <div class="spell-row">
                <label>Zone d\'effet</label>
                <input type="text" name="area-of-effect" placeholder="Optionnelle, ex: NLS/2 mètres" />
            </div>
            <div class="spell-row">
                <label>Priorité</label>
                <input type="number" name="priority" value="0" />
            </div>
            <div class="spell-row spell-row-full">
                <label>Description longue</label>
                <textarea name="long-description" rows="6"></textarea>
            </div>
            <div class="actions">
                <a class="validate">Valider</a>
            </div>
        </div>';

        var rangeSelect:SelectElement = cast getContent().querySelector('select[name=range]');
        var rangeSpecific:InputElement = cast getContent().querySelector('input[name=range-specific]');
        rangeSelect.addEventListener("change", () -> {
            if (rangeSelect.value == "SPECIFIC") {
                rangeSpecific.classList.remove("hidden");
            } else {
                rangeSpecific.classList.add("hidden");
            }
        });

        var castingTimeSelect:SelectElement = cast getContent().querySelector('select[name=casting-time]');
        var castingTimeN:InputElement = cast getContent().querySelector('input[name=casting-time-n]');
        castingTimeSelect.addEventListener("change", () -> {
            if (castingTimeSelect.value == "N_ROUNDS" || castingTimeSelect.value == "N_MINUTES") {
                castingTimeN.classList.remove("hidden");
            } else {
                castingTimeN.classList.add("hidden");
            }
        });

        var durationSelect:SelectElement = cast getContent().querySelector('select[name=duration]');
        var durationN:InputElement = cast getContent().querySelector('input[name=duration-n]');
        var saveEffectRow = getContent().querySelector('.save-effect-row');
        var savingThrowDCRow = getContent().querySelector('.saving-throw-dc-row');
        var stSelect:SelectElement = cast getContent().querySelector('select[name=saving-throw]');
        var usesPerDayInput:InputElement = cast getContent().querySelector('input[name=uses-per-day]');
        saveEffectRow.classList.add("hidden");
        savingThrowDCRow.classList.add("hidden");

        usesPerDayInput.addEventListener("input", () -> {
            var val = Std.parseInt(usesPerDayInput.value);
            if (val != null && val > 0) {
                savingThrowDCRow.classList.remove("hidden");
            } else {
                savingThrowDCRow.classList.add("hidden");
            }
        });
        stSelect.addEventListener("change", () -> {
            if (stSelect.value == "") {
                saveEffectRow.classList.add("hidden");
            } else {
                saveEffectRow.classList.remove("hidden");
            }
        });

        var canEndRow = getContent().querySelector('.can-end-row');
        canEndRow.classList.add("hidden");
        durationSelect.addEventListener("change", () -> {
            if (durationSelect.value == "N_ROUNDS" || durationSelect.value == "N_MINUTES") {
                durationN.classList.remove("hidden");
            } else {
                durationN.classList.add("hidden");
            }
            if (durationSelect.value == "INSTANTANEOUS") {
                canEndRow.classList.add("hidden");
            } else {
                canEndRow.classList.remove("hidden");
            }
        });

        // Autocomplete setup
        var clsName = switch (characterClass) {
            case CONJURATEUR | CONJURATEUR_EIDOLON_BIPED: "conjurateur";
            case MAGICIEN: "magicien";
            case PRETRE: "pretre";
            case ROUBLARD | METAMORPHE: "magicien"; // fallback, shouldn't be reached
        };
        var searchInput:InputElement = cast getContent().querySelector('input[name=spell-search]');
        var suggestions = getContent().querySelector('ul.spell-suggestions');
        var spellIndex:Array<Dynamic> = [];

        Api.getSpells(clsName, maxSpellLevel).then(index -> {
            spellIndex = index;
        });

        function selectSpell(name:String) {
            searchInput.value = name;
            suggestions.classList.add("hidden");
            Api.getSpellDetail(clsName, name).then(spell -> {
                setValue("name", spell.name);
                setValue("level", Std.string(spell.level));
                if (spell.school != null) setValue("school", spell.school);
                if (spell.shortDesc != null) setValue("short-description", spell.shortDesc);
                if (spell.description != null) setValue("long-description", spell.description);
                var comps:Array<String> = if (spell.components != null) spell.components else [];
                var compVerbal:InputElement = cast getContent().querySelector('input[name=comp-verbal]');
                var compSomatic:InputElement = cast getContent().querySelector('input[name=comp-somatic]');
                var compMaterial:InputElement = cast getContent().querySelector('input[name=comp-material]');
                compVerbal.checked = comps.indexOf("VERBAL") >= 0;
                compSomatic.checked = comps.indexOf("SOMATIC") >= 0;
                compMaterial.checked = comps.indexOf("MATERIAL") >= 0;
                if (spell.savingThrow != null) {
                    stSelect.value = spell.savingThrow;
                    saveEffectRow.classList.remove("hidden");
                    if (spell.saveEffect != null) setValue("save-effect", spell.saveEffect);
                }
                var srInput:InputElement = cast getContent().querySelector('input[name=spell-resistance]');
                srInput.checked = spell.spellResistance == true;
                if (spell.target != null) setValue("targets", spell.target);
            });
        }

        function normalize(s:String):String {
            return js.Syntax.code("{0}.normalize('NFD').replace(/[\\u0300-\\u036f]/g, '').toLowerCase()", s);
        }

        searchInput.addEventListener("input", () -> {
            var query = normalize(searchInput.value.trim());
            suggestions.innerHTML = "";
            if (query.length < 2) {
                suggestions.classList.add("hidden");
                return;
            }
            var matches = spellIndex.filter(s -> normalize(s.name).indexOf(query) >= 0);
            if (matches.length == 0) {
                suggestions.classList.add("hidden");
                return;
            }
            if (matches.length > 10) matches = matches.slice(0, 10);
            suggestions.classList.remove("hidden");
            for (s in matches) {
                var li = Browser.document.createLIElement();
                li.innerText = '${s.name} (niv. ${s.level})';
                li.addEventListener("click", () -> selectSpell(s.name));
                suggestions.appendChild(li);
            }
        });

        getContent().querySelector("a.validate").addEventListener("click", () -> {
            var srInput:InputElement = cast getContent().querySelector('input[name=spell-resistance]');
            var canEndInput:InputElement = cast getContent().querySelector('input[name=can-end-voluntarily]');
            var compVerbal:InputElement = cast getContent().querySelector('input[name=comp-verbal]');
            var compSomatic:InputElement = cast getContent().querySelector('input[name=comp-somatic]');
            var compMaterial:InputElement = cast getContent().querySelector('input[name=comp-material]');

            var components:Array<SpellComponent> = [];
            if (compVerbal.checked) components.push(VERBAL);
            if (compSomatic.checked) components.push(SOMATIC);
            if (compMaterial.checked) components.push(MATERIAL);

            var castingTime:SpellCastingTime = if (castingTimeSelect.value == "N_ROUNDS") {
                N_ROUNDS(castingTimeN.value);
            } else if (castingTimeSelect.value == "N_MINUTES") {
                N_MINUTES(castingTimeN.value);
            } else {
                SpellCastingTime.createByName(castingTimeSelect.value);
            };

            var duration:SpellDuration = if (durationSelect.value == "N_ROUNDS") {
                N_ROUNDS(durationN.value);
            } else if (durationSelect.value == "N_MINUTES") {
                N_MINUTES(durationN.value);
            } else {
                SpellDuration.createByName(durationSelect.value);
            };

            var range:SpellRange = if (rangeSelect.value == "SPECIFIC") {
                SPECIFIC(rangeSpecific.value);
            } else {
                SpellRange.createByName(rangeSelect.value);
            };

            var shortDescVal = inputValue("short-description");
            var usesVal = inputValue("uses-per-day");
            var aoeVal = inputValue("area-of-effect");
            var dcVal = inputValue("saving-throw-dc");

            var spell:Spell = {
                name: inputValue("name"),
                shortDescription: if (shortDescVal == "") null else shortDescVal,
                school: SpellSchool.createByName(inputValue("school")),
                level: Std.parseInt(inputValue("level")),
                usesPerDay: if (usesVal == "") null else Std.parseInt(usesVal),
                savingThrowType: if (stSelect.value == "") null else SavingThrow.createByName(stSelect.value),
                saveEffect: if (inputValue("save-effect") == "") null else SpellSaveEffect.createByName(inputValue("save-effect")),
                spellResistance: srInput.checked,
                targets: inputValue("targets"),
                castingTime: castingTime,
                duration: duration,
                canEndVoluntarily: durationSelect.value != "INSTANTANEOUS" && canEndInput.checked,
                components: components,
                areaOfEffect: if (aoeVal == "") null else aoeVal,
                range: range,
                longDescription: inputValue("long-description"),
                priority: Std.parseInt(inputValue("priority")),
                savingThrowDC: if (dcVal == "") null else dcVal,
            };

            onChoice(spell);
            close();
        });
    }
}
