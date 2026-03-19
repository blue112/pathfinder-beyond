import js.html.MouseEvent;
import RulesSkills;
import js.Browser;
import jsasync.IJSAsync;

using DateTools;
using ProtocolUtil;

class FicheEventHistory extends Popup implements IJSAsync {
    var fiche_id:String;

    public function new(fiche_id:String, events:Array<FicheEventTs>) {
        super("Historique de la fiche");

        getContent().classList.add("event-history");

        var currentMods = [];
        var currentItems = [];
        var currentSpells:Array<Spell> = [];
        var currentProtections:Array<Protection> = [];
        var currentWeapons:Array<Weapon> = [];
        this.fiche_id = fiche_id;

        var list = Browser.document.createUListElement();

        for (i in events) {
            var elem = Browser.document.createLIElement();
            var event = switch (i.type) {
                case CREATE(_): "Création du personnage";
                case SET_CHARACTERISTICS(_): "Lancer de caractéristiques initial";
                case ADD_TEMPORARY_MODIFIER(mod):
                    currentMods.push(mod);
                    'Ajout d\'un modificateur temporaire (${mod.mod.asMod()}, ${mod.why.htmlEscape()})';
                case REMOVE_TEMPORARY_MODIFIER(n):
                    var mod = currentMods.splice(n, 1)[0];
                    'Retrait d\'un modificateur temporaire (${mod.why.htmlEscape()})';
                case ADD_CLASS_SKILL(skill): 'Ajout d\'une compétence de classe (${RulesSkills.getSkillLabel(skill)})';
                case SET_SKILL_MODIFIER(skill, mod): 'Ajout d\'un modificateur de compétence (${RulesSkills.getSkillLabel(skill)}): ${mod.asMod()}';
                case SET_SAVING_THROW_MODIFIER(st, mod): 'Modificateur permanent de jet de sauvegarde (${st.savingThrowToString()}): ${mod.asMod()}';
                case SET_SPEED_MODIFIER(mod): 'Modificateur de déplacement : ${mod.asMod()} case(s)';
                case CHANGE_ALIGNEMENT(alignement): 'Changement d\'alignement : ${alignement.alignementToString()}';
                case CHANGE_CARAC(c, amount): 'Modification ${c.caracToString(true)} : ${amount.asMod()}';
                case ADD_WEAPON(weapon):
                    currentWeapons.push(weapon);
                    'Ajout d\'une arme (${weapon.name.htmlEscape()})';
                case REMOVE_WEAPON(n):
                    var w = currentWeapons.splice(n, 1)[0];
                    'Retrait d\'une arme (${w.name.htmlEscape()})';
                case TRAIN_SKILL(skill): 'Ajout d\'un rang dans une capacité (${RulesSkills.getSkillLabel(skill)})';
                case DECREASE_SKILL(skill): 'Retrait d\'un rang dans une capacité (${RulesSkills.getSkillLabel(skill)})';
                case CHANGE_HP(amount) if (amount > 0): 'Récupération de points de vie (${amount} pv)';
                case CHANGE_HP(amount): 'Dégats subis (${- amount} pv)';
                case DAMAGE_HP(amount, damageType): 'Dégats subis: ${amount} pv (${damageType.damageTypeToString().toLowerCase()})';
                case ADD_DAMAGE_RESISTANCE(damageType, amount): 'Résistance modifiée: ${damageType.damageTypeToString()}: ${amount}';
                case REMOVE_DAMAGE_RESISTANCE(damageType): 'Résistance retirée: ${damageType.damageTypeToString()}';
                case CHANGE_MONEY(amount) if (amount > 0): 'Gain d\'argent (${amount} PO)';
                case CHANGE_MONEY(amount): 'Perte d\'argent (${- amount} PO)';
                case CHANGE_BANK_MONEY(amount) if (amount > 0): 'Dépôt en banque (${amount} PO)';
                case CHANGE_BANK_MONEY(amount): 'Retrait en banque (${- amount} PO)';
                case CHANGE_MAX_HP(amount): 'Changement des PV max (${amount.asMod()} pv)';
                case LEVEL_UP(dice): 'Montée d\'un niveau ! Dé de vie = + $dice pv';
                case ADD_PROTECTION(armor):
                    currentProtections.push(armor);
                    var malusStr = if (armor.armorMalus != null && armor.armorMalus != 0) ', malus ${armor.armorMalus.asMod()}' else "";
                    'Ajout ${switch (armor.type) {
                        case ARMOR: "d'une armure";
                        case SHIELD: "d'un bouclier";
                        case NATURAL_ARMOR: "d'une armure naturelle";
                        case EVADE: "d'un bonus d'esquive";
                        case ARMOR_BONUS: "bonus à la CA";
                    }}: ${armor.name.htmlEscape()} (+${armor.armor} CA$malusStr)';
                case REMOVE_PROTECTION(n):
                    var p = currentProtections.splice(n, 1)[0];
                    'Retrait d\'une protection (${p.name.htmlEscape()})';
                case ADD_INVENTORY_ITEM(item):
                    currentItems.push(Reflect.copy(item));
                    'Ajout d\'un objet à l\'inventaire: ${item.name.htmlEscape()} (x${item.quantity})';
                case CHANGE_ITEM_QUANTITY(item_n, new_quantity):
                    var item = currentItems[item_n];
                    'Changement de quantité d\'un objet: ${item.name.htmlEscape()} (x${new_quantity})';
                case CHANGE_ITEM_NAME(item_n, new_name):
                    var item = currentItems[item_n];
                    var str = 'Changement du nom d\'un objet: ${item.name.htmlEscape()} -> ${new_name.htmlEscape()}';
                    item.name = new_name; // Need to do that after so we have old and new name
                    str;
                case CHANGE_ITEM_PRIORITY(item_n, priority):
                    var item = currentItems[item_n];
                    item.priority = priority;
                    'Changement de priorité d\'un objet: ${item.name.htmlEscape()} ($priority)';
                case REMOVE_INVENTORY_ITEM(item_n):
                    var item = currentItems.splice(item_n, 1)[0];
                    'Suppression d\'un objet de l\'inventaire: ${item.name.htmlEscape()}';
                case ADD_SPELL(spell):
                    currentSpells.push(Reflect.copy(spell));
                    'Ajout d\'un sort: ${spell.name.htmlEscape()} (niv.${spell.level}, ${spell.school.spellSchoolToString()})';
                case REMOVE_SPELL(index):
                    var spell = currentSpells.splice(index, 1)[0];
                    'Suppression d\'un sort: ${spell.name.htmlEscape()}';
                case ADD_EXCEPTIONAL_MODIFIER(mod):
                    'Ajout d\'un modificateur exceptionnel sur ${mod.mod.asMod()} (${mod.why.htmlEscape()})';
            }
            elem.innerHTML = '<a class="del">x</a> <small>[${Date.fromTime(i.ts).format("%d/%m/%y %H:%M:%S")}]</small> $event';
            list.appendChild(elem);
            elem.querySelector(".del").addEventListener("click", (e:MouseEvent) -> {
                if (e.shiftKey) {
                    trace(Api.delEvent(fiche_id, i.id).then((_) -> {
                        list.removeChild(elem);
                    }));
                } else {
                    trace('Ignored, must press shift');
                }
            });
        }

        getContent().appendChild(list);
    }
}
