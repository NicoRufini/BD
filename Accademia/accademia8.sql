SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quali sono le persone (id, nome e cognome) che hanno avuto assenze solo nei
giorni in cui non avevano alcuna attivitÃ (progettuali o non progettuali)?"
-- Primo risultato
WITH attivita AS (
SELECT persona, giorno FROM attivitaprogetto
UNION
SELECT persona, giorno FROM attivitanonprogettuale
), 
assenze_senza_attivita AS (
    SELECT assenza.giorno, assenza.persona,
    CASE
        WHEN assenza.giorno != attivita.giorno
        THEN 1 ELSE 0 END AS ass_att_gio
    FROM assenza
    INNER JOIN attivita ON assenza.persona = attivita.persona
)
SELECT DISTINCT persona.id, persona.nome, persona.cognome FROM persona, assenze_senza_attivita
WHERE persona.id NOT IN (
    SELECT assenze_senza_attivita.persona FROM assenze_senza_attivita
    WHERE ass_att_gio = 0
)
ORDER BY persona.id;

-- Secondo risultato
WITH attivita AS (
SELECT persona, giorno FROM attivitaprogetto
UNION
SELECT persona, giorno FROM attivitanonprogettuale
), 
assenze_senza_attivita AS (
    SELECT assenza.giorno, attivita.giorno, assenza.persona,
    CASE
        WHEN attivita.giorno IS NULL
        THEN 1 ELSE 0 END AS ass_att_gio
    FROM assenza
    LEFT JOIN attivita ON assenza.persona = attivita.persona AND assenza.giorno = attivita.giorno
)
SELECT DISTINCT persona.id, persona.nome, persona.cognome FROM persona, assenze_senza_attivita
WHERE persona.id NOT IN (
    SELECT assenze_senza_attivita.persona FROM assenze_senza_attivita
    WHERE ass_att_gio = 0
)
ORDER BY persona.id;

"2. Quali sono le persone (id, nome e cognome) che non hanno mai partecipato ad
alcun progetto durante la durata del progetto “Pegasus”?"
WITH progetto_pegasus AS (
    SELECT inizio, fine FROM progetto
    WHERE progetto.id = 1
),
pegasus_e_attivitaprogetto AS (
    SELECT attivitaprogetto.progetto, attivitaprogetto.persona, attivitaprogetto.giorno, progetto_pegasus.inizio FROM attivitaprogetto
    LEFT JOIN progetto_pegasus ON attivitaprogetto.giorno BETWEEN progetto_pegasus.inizio AND progetto_pegasus.fine
    WHERE progetto_pegasus.inizio IS NOT NULL
)
SELECT DISTINCT persona.id, persona.nome, persona.cognome FROM persona, pegasus_e_attivitaprogetto
WHERE persona.id NOT IN (
    SELECT pegasus_e_attivitaprogetto.persona FROM pegasus_e_attivitaprogetto
)
ORDER BY persona.id;

"3. Quali sono id, nome, cognome e stipendio dei ricercatori con stipendio maggiore
di tutti i professori (associati e ordinari)?"
-- Con LEFT JOIN
WITH professori AS (
    SELECT MAX(stipendio) AS stipendio_professori FROM persona
    WHERE posizione IN ('Professore Associato', 'Professore Ordinario')
)
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.stipendio, professori.stipendio_professori FROM persona
LEFT JOIN professori ON persona.stipendio > stipendio_professori
WHERE stipendio_professori IS NOT NULL;

-- Con INNER JOIN
WITH professori AS (
    SELECT MAX(stipendio) AS stipendio_professori FROM persona
    WHERE posizione IN ('Professore Associato', 'Professore Ordinario')
)
SELECT DISTINCT persona.id, persona.nome, persona.cognome, persona.stipendio, professori.stipendio_professori FROM persona
INNER JOIN professori ON persona.stipendio > stipendio_professori;

"4. Quali sono le persone che hanno lavorato su progetti con un budget superiore alla
media dei budget di tutti i progetti?"
SELECT persona.id, persona.nome, persona.cognome FROM attivitaprogetto
INNER JOIN persona ON persona.id = attivitaprogetto.persona
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
WHERE progetto.budget > (
    SELECT AVG(budget) AS media_budget_progetto FROM progetto
);

"5. Quali sono i progetti con un budget inferiore allala media, ma con un numero
complessivo di ore dedicate alle attività di ricerca sopra la media?"
SELECT DISTINCT progetto.id, progetto.nome FROM attivitaprogetto
INNER JOIN persona ON persona.id = attivitaprogetto.persona
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
WHERE progetto.budget < (
    SELECT AVG(budget) AS media_budget_progetto FROM progetto
) 
AND attivitaprogetto.oredurata > (
    SELECT AVG(oredurata) FROM attivitaprogetto
    WHERE tipo = 'Ricerca e Sviluppo'
);