#!/usr/bin/env python3
"""
Convert raw spells.json to one normalized JSON file per character class.
Output goes to backend/static/data/spells_<class>.json.
Run from the repo root: python3 scripts/preprocess_spells.py
"""

import json
import re
import sys
from pathlib import Path

# Map raw school strings to our SpellSchool enum values
SCHOOL_MAP = {
    'abjuration':   'ABJURATION',
    'divination':   'DIVINATION',
    'enchantement': 'ENCHANTMENT',
    'illusion':     'ILLUSION',
    'invocation':   'CONJURATION',
    'nécromancie':  'NECROMANCY',
    'transmutation':'TRANSMUTATION',
    'universel':    'UNIVERSAL',
    'universelle':  'UNIVERSAL',
    'évocation':    'EVOCATION',
}

# Map our CharacterClass enum values to raw JSON level keys (in priority order)
CLASS_KEYS = {
    'CONJURATEUR': ['conu'],
    'MAGICIEN':    ['ens/mag', 'mag'],
    'PRETRE':      ['prê', 'prêtre'],
}

def normalize_school(raw):
    if not raw:
        return None
    # Strip trailing garbage: semicolons, non-breaking spaces, newlines, sub-clauses
    cleaned = re.split(r'[\s;:\xa0\n]', raw.strip())[0].lower()
    return SCHOOL_MAP.get(cleaned)

def normalize_components(comps):
    result = []
    seen = set()
    for c in comps:
        c = c.strip()
        if c.startswith('V') and 'VERBAL' not in seen:
            result.append('VERBAL')
            seen.add('VERBAL')
        elif c.startswith('G') and 'SOMATIC' not in seen:
            result.append('SOMATIC')
            seen.add('SOMATIC')
        elif c.startswith('M') and 'MATERIAL' not in seen:
            result.append('MATERIAL')
            seen.add('MATERIAL')
        # F / FD (focus / divine focus) are ignored — not in our model
    return result

def normalize_saving_throw(jds_type):
    if not jds_type:
        return None
    j = jds_type.lower()
    if 'réflexes' in j:
        return 'REFLEXES'
    if 'vigueur' in j:
        return 'VIGOR'
    if 'volonté' in j:
        return 'WILL'
    return None

def normalize_save_effect(jds_result):
    if not jds_result:
        return None
    r = jds_result.lower()
    if '1/2' in r or 'moitié' in r or 'partiel' in r:
        return 'HALF_DAMAGE'
    if 'annule' in r or 'annuler' in r:
        return 'NEGATES'
    if 'dévoile' in r or 'dévoiler' in r or 'percer' in r:
        return 'REVEALS'
    return None

def get_level_for_class(spell, cls):
    raw_levels = spell.get('levels', {})
    for key in CLASS_KEYS[cls]:
        if key in raw_levels:
            return raw_levels[key]
    return None

def convert_spell(spell, level):
    school = normalize_school(spell.get('school', ''))
    if school is None:
        return None

    entry = {
        'name':             spell['name'],
        'level':            level,
        'school':           school,
        'components':       normalize_components(spell.get('composantes', [])),
        'spellResistance':  spell.get('rm') == 'oui',
    }

    short_desc = (spell.get('description_short') or '').strip()
    if short_desc:
        entry['shortDesc'] = short_desc

    description = (spell.get('description') or '').strip()
    if description:
        entry['description'] = description

    st = normalize_saving_throw(spell.get('jds_type'))
    if st:
        entry['savingThrow'] = st
        se = normalize_save_effect(spell.get('jds_result'))
        if se:
            entry['saveEffect'] = se

    target = (spell.get('target') or '').strip()
    if target:
        entry['target'] = target

    return entry

def main():
    src_files = [
        Path('frontend/src/assets/spells.json'),
        Path('frontend/src/assets/spells-2.json'),
        Path('frontend/src/assets/spells-3.json'),
    ]
    out_dir = Path('backend/static/data')
    out_dir.mkdir(parents=True, exist_ok=True)

    # Merge all source files, last file wins on duplicate names
    spells_by_name = {}
    for src in src_files:
        with open(src, encoding='utf-8') as f:
            for spell in json.load(f):
                spells_by_name[spell['name']] = spell
    spells = list(spells_by_name.values())
    print(f'Merged: {len(spells)} unique spells from {len(src_files)} files')

    for cls in CLASS_KEYS:
        entries = []
        skipped_school = 0
        for spell in spells:
            level = get_level_for_class(spell, cls)
            if level is None:
                continue
            entry = convert_spell(spell, level)
            if entry is None:
                skipped_school += 1
                continue
            entries.append(entry)

        # Sort by level, then name
        entries.sort(key=lambda e: (e['level'], e['name']))

        out_path = out_dir / f'spells_{cls.lower()}.json'
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(entries, f, ensure_ascii=False, separators=(',', ':'))

        size_kb = out_path.stat().st_size // 1024
        print(f'{cls}: {len(entries)} spells → {out_path} ({size_kb} KB, {skipped_school} skipped bad school)')

if __name__ == '__main__':
    main()
