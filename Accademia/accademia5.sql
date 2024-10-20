SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quali sono il nome, la data di inizio e la data di fine dei WP del progetto di nome
'Pegasus'?"
SELECT WP.id, WP.nome, WP.inizio, WP.fine FROM WP
INNER JOIN progetto on WP.progetto = progetto.id 
WHERE progetto.nome = 'Pegasus';

"2. Quali sono il nome, il cognome e la posizione degli strutturati che hanno almeno
una attività nel progetto 'Pegasus', ordinati per cognome decrescente?"
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.posizione FROM persona
INNER JOIN attivitaprogetto on persona.id = attivitaprogetto.persona
INNER JOIN progetto on attivitaprogetto.progetto = progetto.id
WHERE progetto.nome = 'Pegasus' ORDER BY cognome DESC;

"3. Quali sono il nome, il cognome e la posizione degli strutturati che hanno più di
una attività nel progetto 'Pegasus'?"
'Without the COUNT column' 'It works even without the DISTINCT'
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.posizione FROM attivitaprogetto
INNER JOIN persona on persona.id = attivitaprogetto.persona
INNER JOIN progetto on attivitaprogetto.progetto = progetto.id
WHERE progetto.nome = 'Pegasus'
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione
HAVING COUNT(persona.id) > 1;

'With the COUNT column'
SELECT DISTINCT COUNT(attivitaprogetto.persona), persona.id, persona.nome, persona.cognome, persona.posizione FROM attivitaprogetto
INNER JOIN persona on persona.id = attivitaprogetto.persona
INNER JOIN progetto on attivitaprogetto.progetto = progetto.id
WHERE progetto.nome = 'Pegasus'
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione
HAVING COUNT(persona.id) > 1;

"4. Quali sono il nome, il cognome e la posizione dei Professori Ordinari che hanno
fatto almeno una assenza per malattia?"
'HAVING COUNT(assenza.persona) >= 1 non è necessario'
SELECT persona.id, persona.nome, persona.cognome, persona.posizione FROM persona
INNER JOIN assenza on persona.id = assenza.persona
WHERE persona.posizione = 'Professore Ordinario' AND assenza.tipo = 'Malattia'
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione
HAVING COUNT(assenza.persona) >= 1;

"5. Quali sono il nome, il cognome e la posizione dei Professori Ordinari che hanno
fatto più di una assenza per malattia?"
SELECT persona.id, persona.nome, persona.cognome, persona.posizione FROM persona
INNER JOIN assenza on persona.id = assenza.persona
WHERE persona.posizione = 'Professore Ordinario' AND assenza.tipo = 'Malattia'
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione
HAVING COUNT(assenza.persona) > 1;

"6. Quali sono il nome, il cognome e la posizione dei Ricercatori che hanno almeno
un impegno per didattica?"
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.posizione FROM persona
INNER JOIN attivitanonprogettuale on persona.id = attivitanonprogettuale.persona
WHERE persona.posizione = 'Ricercatore';

"7. Quali sono il nome, il cognome e la posizione dei Ricercatori che hanno più di un
impegno per didattica?"
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.posizione FROM persona
INNER JOIN attivitanonprogettuale on persona.id = attivitanonprogettuale.persona
WHERE persona.posizione = 'Ricercatore'
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione
HAVING COUNT(attivitanonprogettuale.persona) > 1;

"8. Quali sono il nome e il cognome degli strutturati che nello stesso giorno hanno sia
attività progettuali che attività non progettuali?"
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.posizione FROM attivitanonprogettuale
INNER JOIN persona ON attivitanonprogettuale.persona = persona.id
INNER JOIN attivitaprogetto ON attivitaprogetto.persona = persona.id
WHERE attivitaprogetto.giorno = attivitanonprogettuale.giorno;

"9. Quali sono il nome e il cognome degli strutturati che nello stesso giorno hanno sia
attività progettuali che attività non progettuali? Si richiede anche di proiettare il
giorno, il nome del progetto, il tipo di attività non progettuali e la durata in ore di
entrambe le attività."
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.posizione, attivitanonprogettuale.giorno, progetto.nome, attivitanonprogettuale.tipo,
attivitaprogetto.oredurata, attivitanonprogettuale.oredurata
FROM attivitanonprogettuale
INNER JOIN persona ON attivitanonprogettuale.persona = persona.id
INNER JOIN attivitaprogetto ON attivitaprogetto.persona = persona.id
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
WHERE attivitaprogetto.giorno = attivitanonprogettuale.giorno;

"10. Quali sono il nome e il cognome degli strutturati che nello stesso giorno sono
assenti e hanno attività progettuali?"
SELECT DISTINCT persona.id, persona.nome, persona.cognome FROM persona
INNER JOIN assenza ON persona.id = assenza.persona
INNER JOIN attivitaprogetto ON persona.id = attivitaprogetto.persona
WHERE assenza.giorno = attivitaprogetto.giorno;

"11. Quali sono il nome e il cognome degli strutturati che nello stesso giorno sono
assenti e hanno attività progettuali? Si richiede anche di proiettare il giorno, il
nome del progetto, la causa di assenza e la durata in ore della attività progettuale."
SELECT DISTINCT persona.id, persona.nome, persona.cognome, assenza.giorno, progetto.tipo, assenza.nome, attivitaprogetto.oredurata FROM persona
INNER JOIN assenza ON persona.id = assenza.persona
INNER JOIN attivitaprogetto ON persona.id = attivitaprogetto.persona
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
WHERE assenza.giorno = attivitaprogetto.giorno;

"12. Quali sono i WP che hanno lo stesso nome, ma appartengono a progetti diversi?"
SELECT DISTINCT WP.nome FROM WP
GROUP BY WP.nome
HAVING COUNT(WP.nome) > 1;