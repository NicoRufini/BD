SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quali sono il nome, la data di inizio e la data di fine dei WP del progetto di nome
'Pegasus'?"
SELECT WP.nome, WP.inizio, WP.fine FROM WP, progetto p
WHERE p.id = WP.progetto
    AND p.nome = 'Pegasus';

"2. Quali sono il nome, il cognome e la posizione degli strutturati che hanno almeno
una attività nel progetto 'Pegasus', ordinati per cognome decrescente?"
-- persona, progetto, attivitaprogetto
SELECT DISTINCT pe.nome, pe.cognome, pe.posizione FROM attivitaprogetto ap
INNER JOIN persona pe ON pe.id = ap.persona
INNER JOIN progetto pr ON pr.id = ap.progetto
WHERE pr.nome = 'Pegasus'
ORDER BY pe.cognome DESC;

"3. Quali sono il nome, il cognome e la posizione degli strutturati che hanno più di
una attività nel progetto 'Pegasus'?"
SELECT pe.nome, pe.cognome, pe.posizione FROM attivitaprogetto ap
INNER JOIN persona pe ON pe.id = ap.persona
INNER JOIN progetto pr ON pr.id = ap.progetto
WHERE pr.nome = 'Pegasus'
GROUP BY pe.nome, pe.cognome, pe.posizione
HAVING COUNT(ap.persona) > 1
ORDER BY pe.cognome DESC;

"4. Quali sono il nome, il cognome e la posizione dei Professori Ordinari che hanno
fatto almeno una assenza per malattia?"
SELECT DISTINCT pe.nome, pe.cognome FROM persona pe
INNER JOIN assenza ass ON ass.persona = pe.id
WHERE pe.posizione = 'Professore Ordinario'
    AND ass.tipo = 'Malattia';

"5. Quali sono il nome, il cognome e la posizione dei Professori Ordinari che hanno
fatto più di una assenza per malattia?"
SELECT DISTINCT pe.nome, pe.cognome FROM persona pe
INNER JOIN assenza ass ON ass.persona = pe.id
WHERE pe.posizione = 'Professore Ordinario'
    AND ass.tipo = 'Malattia'
GROUP BY pe.nome, pe.cognome
HAVING COUNT(ass.persona) > 1;

"6. Quali sono il nome, il cognome e la posizione dei Ricercatori che hanno almeno
un impegno per didattica?"
-- persona, attivitanonprogettuale
SELECT DISTINCT pe.nome, pe.cognome FROM persona pe
INNER JOIN attivitanonprogettuale anp ON anp.persona = pe.id
WHERE pe.posizione = 'Ricercatore'
    AND anp.tipo = 'Didattica';

"7. Quali sono il nome, il cognome e la posizione dei Ricercatori che hanno più di un
impegno per didattica?"
-- persona, attivitanonprogettuale
SELECT DISTINCT pe.nome, pe.cognome FROM persona pe
INNER JOIN attivitanonprogettuale anp ON anp.persona = pe.id
WHERE pe.posizione = 'Ricercatore'
    AND anp.tipo = 'Didattica'
GROUP BY pe.nome, pe.cognome
HAVING COUNT(anp.persona) > 1;

"8. Quali sono il nome e il cognome degli strutturati che nello stesso giorno hanno sia
attività progettuali che attività non progettuali?"
-- persona, attivitaprogetto, attivitanonprogettuale
SELECT pe.nome, pe.cognome FROM persona pe
INNER JOIN attivitaprogetto ap ON ap.persona = pe.id
INNER JOIN attivitanonprogettuale anp ON anp.persona = pe.id
WHERE ap.giorno = anp.giorno;

"9. Quali sono il nome e il cognome degli strutturati che nello stesso giorno hanno sia
attività progettuali che attività non progettuali? Si richiede anche di proiettare il
giorno, il nome del progetto, il tipo di attività non progettuali e la durata in ore di
entrambe le attività."
SELECT pe.nome, pe.cognome, ap.giorno, pr.nome, anp.tipo, ap.oredurata ap_ore, anp.oredurata anp_ore
FROM persona pe
INNER JOIN attivitaprogetto ap ON ap.persona = pe.id
INNER JOIN attivitanonprogettuale anp ON anp.persona = pe.id
INNER JOIN progetto pr ON pr.id = ap.progetto
WHERE ap.giorno = anp.giorno;

"10. Quali sono il nome e il cognome degli strutturati che nello stesso giorno sono
assenti e hanno attività progettuali?"
-- persona, assenza, attivitaprogetto
SELECT pe.nome, pe.cognome FROM persona pe
INNER JOIN assenza ass ON ass.persona = pe.id
INNER JOIN attivitaprogetto ap ON ap.persona = pe.id
WHERE ass.giorno = ap.giorno;

"11. Quali sono il nome e il cognome degli strutturati che nello stesso giorno sono
assenti e hanno attività progettuali? Si richiede anche di proiettare il giorno, il
nome del progetto, la causa di assenza e la durata in ore della attività progettuale."
-- persona, assenza, attivitaprogetto
SELECT pe.nome, pe.cognome, ass.giorno, pr.nome, ass.tipo, ap.oredurata FROM persona pe
INNER JOIN assenza ass ON ass.persona = pe.id
INNER JOIN attivitaprogetto ap ON ap.persona = pe.id
INNER JOIN progetto pr ON pr.id = ap.progetto
WHERE ass.giorno = ap.giorno;

"12. Quali sono i WP che hanno lo stesso nome, ma appartengono a progetti diversi?"
SELECT nome FROM WP
GROUP BY nome
HAVING COUNT(progetto) > 1;
