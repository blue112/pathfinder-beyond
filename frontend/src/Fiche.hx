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
                        <div class='value num'>19</div>
                    </div>
                    <div class='field xs  m-s' data-id='height'>
                        <div class='label'>Taille</div>
                        <div class='value num'>152</div>
                    </div>
                    <div class='field xs  m-s' data-id='height'>
                        <div class='label'>Poids</div>
                        <div class='value num'>60</div>
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
        <section class='caracteristics'>
            <h2>Caractéristiques</h2>
            <div class='carac' data-id='str'>
                <div class='label'>FORCE</div>
                <div class='value'>12</div>
                <div class='mod'>+1</div>
            </div>
            <div class='carac' data-id='dex'>
                <div class='label'>DEXTÉRITÉ</div>
                <div class='value'>12</div>
                <div class='mod'>+1</div>
            </div>
            <div class='carac' data-id='con'>
                <div class='label'>CONSTITUTION</div>
                <div class='value'>12</div>
                <div class='mod'>+1</div>
            </div>
            <div class='carac' data-id='int'>
                <div class='label'>INTELLIGENCE</div>
                <div class='value'>12</div>
                <div class='mod'>+1</div>
            </div>
            <div class='carac' data-id='wis'>
                <div class='label'>SAGESSE</div>
                <div class='value'>12</div>
                <div class='mod'>+1</div>
            </div>
            <div class='carac' data-id='cha'>
                <div class='label'>CHARISME</div>
                <div class='value'>12</div>
                <div class='mod'>+1</div>
            </div>
        </section>
        <section class='hp' data-id='hp'>
            <div class='lethal' data-id='hp'>
                <div class='label'>Points de Vie</div>
                <div class='value'>
                    <span class='current'>21</span>
                    <span class='separator'>/</span>
                    <span class='max'>24</span>
                </div>
            </div>
            <div class='non-lethal' data-id='non-lethal-hp'>
                <div class='label'>Blessures non léthales</div>
                <div class='value'>
                    <span class='current'>0</span>
                    <span class='separator'>/</span>
                    <span class='max'>21</span>
                </div>
            </div>
        </section>
        <section class='speed' data-id='speed'>
            <div class='label'>Déplacement</div>
            <div class='value'>8c par tour</div>
        </section>
        <section class='initiative' data-id='initiative'>
            <div class='label'>Initiative</div>
            <div class='value'><span class='d20'></span><span class='mod'> + 3</span></div>
        </section>
        <section class='ac' data-id='ac'>
            <div class='label'>CA</div>
            <div class='value'>17</div>
        </section>
        <section class='contact' data-id='ac-contact'>
            <div class='label'>Contact</div>
            <div class='value'>13</div>
        </section>
        <section class='surprise' data-id='ac-surprise'>
            <div class='label'>Pris au dépourvu</div>
            <div class='value'>12</div>
        </section>
        <section class='saving'>
            <h2>Jets de sauvegarde</h2>
            <div class='reflexes' data-id='saving-reflexes'>
                <div class='label'>Reflexes</div>
                <div class='value'><span class='d20'></span> + 8</div>
            </div>
            <div class='vigor' data-id='saving-vigor'>
                <div class='label'>Vigueur</div>
                <div class='value'><span class='d20'></span> + 2</div>
            </div>
            <div class='will' data-id='saving-will'>
                <div class='label'>Volonté</div>
                <div class='value'><span class='d20'></span> - 1</div>
            </div>
        </section>
        <section class='fight'>
            <h2>Combat</h2>
            <div class='bba' data-id='bba'>
                <div class='label'>Bonus de Base à l'Attaque</div>
                <div class='value'>+ 2</div>
            </div>
            <div class='bmo' data-id='bmo'>
                <div class='label'>Manoeuvre Offensive</div>
                <div class='value'><span class='d20'></span> + 2</div>
            </div>
            <div class='dmd' data-id='dmd'>
                <div class='label'>Manoeuvre Défensive</div>
                <div class='value'>16</div>
            </div>
            <section class='weapons'>
                <h2>Armes</h2>
                <div class='weapon'>
                    <h3>Arc court de maître</h3>
                    <div class='field-line'>
                        <div class='field s'>
                            <div class='label'>Jet pour toucher</div>
                            <div class='value mod num'><span class='d20'></span> + 6</div>
                        </div>
                        <div class='field s'>
                            <div class='label'>Critique</div>
                            <div class='value num'>Si 20: x3</div>
                        </div>
                        <div class='field s'>
                            <div class='label'>Dégats</div>
                            <div class='value mod num'>1d6 + 4</div>
                        </div>
                    </div>
                    <div class='field-line'>
                        <div class='field s'>
                            <div class='label'>Type</div>
                            <div class='value'>Perforant</div>
                        </div>
                        <div class='field xs'>
                            <div class='label'>Portée</div>
                            <div class='value num'>12c</div>
                        </div>
                        <div class='field s'>
                            <div class='label'>Munitions</div>
                            <div class='value'>12 flèches</div>
                        </div>
                    </div>
                </div>
                <div class='weapon'>
                    <h3>Rapière</h3>
                    <div class='field-line'>
                        <div class='field s'>
                            <div class='label'>Jet pour toucher</div>
                            <div class='value mod num'><span class='d20'></span> + 3</div>
                        </div>
                        <div class='field s'>
                            <div class='label'>Critique</div>
                            <div class='value num'>Si 19 ou 20: x3</div>
                        </div>
                        <div class='field s'>
                            <div class='label'>Dégats</div>
                            <div class='value mod num'>1d8 + 3</div>
                        </div>
                    </div>
                    <div class='field-line'>
                        <div class='field s'>
                            <div class='label'>Type</div>
                            <div class='value'>Tranchant</div>
                        </div>
                        <div class='field xs'>
                            <div class='label'>Portée</div>
                            <div class='value num'>Contact</div>
                        </div>
                        <div class='field s'>
                            <div class='label'>Munitions</div>
                            <div class='value'>/</div>
                        </div>

                    </div>
                </div>
            </section>
        </section>
        <section class='skills'>
            <h2>Compétences</h2>
            <div class='skill'>
                <div class='label'>Acrobaties</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Artisanat</div>
                <div class='value'>+1</div>
            </div>
            <div class='skill'>
                <div class='label'>Art de la magie</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Bluff</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Exploration)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Folfklore Local)</div>
                <div class='value'>+3</div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Géographie)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Histoire)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Ingénierie)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Mystères)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Nature)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Noblesse)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Plans)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Connaissance (Religion)</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Déguisement</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Diplomatie</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Discrétion</div>
                <div class='value'>+8</div>
            </div>
            <div class='skill'>
                <div class='label'>Dressage</div>
                <div class='value'>+4</div>
            </div>
            <div class='skill'>
                <div class='label'>Équitation</div>
                <div class='value'>+3</div>
            </div>
            <div class='skill'>
                <div class='label'>Escalade</div>
                <div class='value'>+1</div>
            </div>
            <div class='skill'>
                <div class='label'>Escamotage</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Estimation</div>
                <div class='value'>-1</div>
            </div>
            <div class='skill'>
                <div class='label'>Évasion</div>
                <div class='value'>+4</div>
            </div>
            <div class='skill'>
                <div class='label'>Intimidation</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Linguistique</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Natation</div>
                <div class='value'>+1</div>
            </div>
            <div class='skill'>
                <div class='label'>Perception</div>
                <div class='value'>+4</div>
            </div>
            <div class='skill'>
                <div class='label'>Premiers secours</div>
                <div class='value'>-1</div>
            </div>
            <div class='skill'>
                <div class='label'>Profession</div>
                <div class='value'></div>
            </div>
            <div class='skill'>
                <div class='label'>Psychologie</div>
                <div class='value'>-1</div>
            </div>
            <div class='skill'>
                <div class='label'>Représ.</div>
                <div class='value'>+3</div>
            </div>
            <div class='skill'>
                <div class='label'>Représ.</div>
                <div class='value'>+3</div>
            </div>
            <div class='skill'>
                <div class='label'>Sabotage</div>
                <div class='value'>+8</div>
            </div>
            <div class='skill'>
                <div class='label'>Survie</div>
                <div class='value'>+3</div>
            </div>
            <div class='skill'>
                <div class='label'>Utilisation d'objets magiques</div>
                <div class='value'>+7</div>
            </div>
            <div class='skill'>
                <div class='label'>Vol</div>
                <div class='value'>+3</div>
            </div>
            <div class='skill'>
            </div>
            </div>
        </section>
        ";

		Browser.document.body.appendChild(mainElem);
	}
}
