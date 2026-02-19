package elems;

import js.html.TextAreaElement;
import js.Browser;

class NoteDialog extends Popup {
	var textarea:TextAreaElement;

	public function new(currentNote:String, onSave:String->Void) {
		var isNewNote = currentNote == null;
		super(if (isNewNote) "Ajouter une note" else "Modifier une note");

		mainElem.classList.add("notes");
		mainElem.classList.add("alert");

		getContent().innerHTML = "
        <textarea></textarea>
        <div class='actions'>
            <a class='save'>Sauvegarder</a>
        </div>
        ";

		textarea = cast getContent().querySelector("textarea");

		if (!isNewNote)
			textarea.value = currentNote;

		getContent().querySelector("a.save").addEventListener("click", () -> {
			onSave(textarea.value);
			close();
		});

		Browser.document.body.appendChild(mainElem);
	}
}
