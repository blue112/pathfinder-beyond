import js.Browser;

class Fiche {
	public function new() {
		var mainElem = Browser.document.createDivElement();
		mainElem.classList.add("fiche");

		mainElem.innerHTML = "
        <section class='meta'>
            <div class='left'>
                <div class='logo'><span>Feuille de personnage</span></div>
            </div>
            <div class='right'>
                <div class='field-line'>
                    <div class='field' data-id='character-name'>
                        <div class='label'>Nom du personnage</div>
                        <div class='value'>Alysa</div>
                    </div>
                    <div class='field' data-id='alignement'>
                        <div class='label'>Alignement</div>
                        <div class='value'>Neutre/Bon</div>
                    </div>
                    <div class='field' data-id='player-name'>
                        <div class='label'>Joueur/Joueuse</div>
                        <div class='value'>Ysa</div>
                    </div>
                </div>
                <div class='field-line'>
                    <div class='field l' data-id='class'>
                        <div class='label'>Classe</div>
                        <div class='value'>Roublarde</div>
                    </div>
                    <div class='field xxs m-s' data-id='level'>
                        <div class='label'>Niveau</div>
                        <div class='value'>3</div>
                    </div>
                    <div class='field' data-id='divinity-name'>
                        <div class='label'>Divinité</div>
                        <div class='value'>Aucune</div>
                    </div>
                    <div class='field' data-id='origin'>
                        <div class='label'>Origine</div>
                        <div class='value'>Ville</div>
                    </div>
                </div>
                <div class='field-line'>
                    <div class='field' data-id='race'>
                        <div class='label'>Race</div>
                        <div class='value'>Humaine</div>
                    </div>
                    <div class='field xs' data-id='size-cat'>
                        <div class='label'>Catégorie de taille</div>
                        <div class='value'>M</div>
                    </div>
                    <div class='field xs m-s' data-id='gender'>
                        <div class='label'>Genre</div>
                        <div class='value'>F</div>
                    </div>
                    <div class='field xs m-s' data-id='age'>
                        <div class='label'>Age</div>
                        <div class='value'>19</div>
                    </div>
                    <div class='field xs  m-s' data-id='height'>
                        <div class='label'>Taille (cm)</div>
                        <div class='value'>152</div>
                    </div>
                    <div class='field xs  m-s' data-id='height'>
                        <div class='label'>Poids (kg)</div>
                        <div class='value'>60</div>
                    </div>
                    <div class='field s' data-id='hair'>
                        <div class='label'>Cheveux</div>
                        <div class='value'>M/Marrons</div>
                    </div>
                    <div class='field s' data-id='eyes'>
                        <div class='label'>Yeux</div>
                        <div class='value'>Marrons</div>
                    </div>
                </div>
            </div>
        </section>
        ";

		Browser.document.body.appendChild(mainElem);
	}
}
