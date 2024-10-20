SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quali sono le persone (id, nome e cognome) che hanno avuto assenze solo nei
giorni in cui non avevano alcuna attivitÃ (progettuali o non progettuali)?"
SELECT persona.id, persona.nome, persona.cognome FROM persona
INNER JOIN attivitaprogetto ON persona.id = attivitaprogetto.persona
INNER JOIN attivitanonprogettuale ON persona.id = attivitanonprogettuale.persona
INNER JOIN assenza ON persona.id = assenza.persona
WHERE  assenza.giorno != attivitaprogetto.giorno AND assenza.giorno != attivitanonprogettuale.giorno;

SELECT persona.id, persona.nome, persona.cognome FROM persona
INNER JOIN attivitaprogetto ON persona.id = attivitaprogetto.persona
INNER JOIN attivitanonprogettuale ON persona.id = attivitanonprogettuale.persona
INNER JOIN assenza ON persona.id = assenza.persona
WHERE EXISTS (
    SELECT persona.id, persona.nome, persona.cognome FROM persona
INNER JOIN attivitaprogetto ON persona.id = attivitaprogetto.persona
INNER JOIN attivitanonprogettuale ON persona.id = attivitanonprogettuale.persona
INNER JOIN assenza ON persona.id = assenza.persona
WHERE  assenza.giorno != attivitaprogetto.giorno AND assenza.giorno != attivitanonprogettuale.giorno
);

-- Usare il case ed assegnare 1 usa poi ALL

WITH assenze_senza_attivita AS (
    SELECT persona.id, persona.nome, persona.cognome,
    CASE
        WHEN assenza.giorno != attivitaprogetto.giorno AND assenza.giorno != attivitanonprogettuale.giorno
        THEN 1 ELSE 0  END as ass_sen_att
    FROM persona
    INNER JOIN attivitaprogetto ON persona.id = attivitaprogetto.persona
    INNER JOIN attivitanonprogettuale ON persona.id = attivitanonprogettuale.persona
    INNER JOIN assenza ON persona.id = assenza.persona
)
SELECT DISTINCT persona.id, persona.nome, persona.cognome FROM persona
CROSS JOIN assenze_senza_attivita
WHERE ass_sen_att = ALL (
    SELECT ass_sen_att FROM assenze_senza_attivita
    WHERE ass_sen_att = 1)
ORDER BY persona.id;


-- Forse ALL non è necessario, potrei usare più di un WITH.
-- Confrontare il COUNT() delle assenze generiche per persona con il COUNT() delle assenze per persona che rispettano la condizione ass_sen_att. ..
-- ..Se i due COUNT() sono uguali allore appariranno nella tabella.































"2. Quali sono le persone (id, nome e cognome) che non hanno mai partecipato ad
alcun progetto durante la durata del progetto “Pegasus”?"

"3. Quali sono id, nome, cognome e stipendio dei ricercatori con stipendio maggiore
di tutti i professori (associati e ordinari)?"

"4. Quali sono le persone che hanno lavorato su progetti con un budget superiore alla
media dei budget di tutti i progetti?"

"5. Quali sono i progetti con un budget inferiore allala media, ma con un numero
complessivo di ore dedicate alle attività di ricerca sopra la media?"