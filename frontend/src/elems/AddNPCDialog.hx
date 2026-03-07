package elems;

class AddNPCDialog extends Popup {
	public function new(onChoice:NPCInfo->Void) {
		super("Ajouter un PNJ");
		mainElem.classList.add("weapon");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
		<div class='input-field'>
			<label>Nom</label>
			<input type='text' name='name' />
		</div>
		<div class='input-field'>
			<label>PV max</label>
			<input type='number' name='max-hp' value='10' />
		</div>
		<div class='input-field'>
			<label>CA</label>
			<input type='number' name='ac' value='10' />
		</div>
		<div class='input-field'>
			<label>CA contact</label>
			<input type='number' name='ac-contact' value='10' />
		</div>
		<div class='input-field'>
			<label>CA par surprise</label>
			<input type='number' name='ac-surprise' value='10' />
		</div>
		<div class='input-field'>
			<label>Modificateur d'initiative</label>
			<input type='number' name='initiative' value='0' />
		</div>
		<div class='input-field'>
			<label>Réflexes</label>
			<input type='number' name='reflexes' value='0' />
		</div>
		<div class='input-field'>
			<label>Vigueur</label>
			<input type='number' name='vigor' value='0' />
		</div>
		<div class='input-field'>
			<label>Volonté</label>
			<input type='number' name='will' value='0' />
		</div>
		<div class='input-field'>
			<label>Facteur de puissance (FP)</label>
			<input type='text' name='cr' />
		</div>
		<div class='input-field'>
			<label>Notes</label>
			<textarea name='notes'></textarea>
		</div>
		<div class='actions'>
			<a class='validate'>Valider</a>
		</div>";

		mainElem.querySelector("a.validate").addEventListener("click", () -> {
			var notesStr = inputValue("notes");
			var npc:NPCInfo = {
				name: inputValue("name"),
				maxHp: inputValue("max-hp").parseInt(),
				ac: inputValue("ac").parseInt(),
				acContact: inputValue("ac-contact").parseInt(),
				acBySurprise: inputValue("ac-surprise").parseInt(),
				initiativeModifier: inputValue("initiative").parseInt(),
				savingThrows: {
					reflexes: inputValue("reflexes").parseInt(),
					vigor: inputValue("vigor").parseInt(),
					will: inputValue("will").parseInt(),
				},
				cr: inputValue("cr"),
				notes: if (notesStr == "") null else notesStr,
			};
			onChoice(npc);
			close();
		});
	}
}
