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

-- Secondo risultato CG
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

WITH pegasus_e_attivitaprogetto AS ( --progetto id "Pegasus" = 1 - join progetto
    SELECT attivitaprogetto.progetto, attivitaprogetto.persona, attivitaprogetto.giorno FROM attivitaprogetto, progetto
    WHERE attivitaprogetto.progetto = 1 AND giorno BETWEEN progetto.inizio AND progetto.fine
)
















































"3. Quali sono id, nome, cognome e stipendio dei ricercatori con stipendio maggiore
di tutti i professori (associati e ordinari)?"

"4. Quali sono le persone che hanno lavorato su progetti con un budget superiore alla
media dei budget di tutti i progetti?"

"5. Quali sono i progetti con un budget inferiore allala media, ma con un numero
complessivo di ore dedicate alle attività di ricerca sopra la media?"