SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quali sono le persone (id, nome e cognome) che hanno avuto assenze solo nei
giorni in cui non avevano alcuna attività (progettuali o non progettuali)?"
-- persona, assenza, attivitaprogetto, attivitanonprogettuale - EXISTS(?)
-- Il risultato coincide, ma ritorna anche le persona che non hanno
-- avuto assenze. A noi ci interessa "le persona che hanno avute assenze solo nei ...".
WITH ga AS (
    SELECT persona, giorno giorno_att
    FROM attivitaprogetto
    UNION
    SELECT persona, giorno giorno_att
    FROM attivitanonprogettuale
),
ga_ass AS (
    SELECT ass.persona
    FROM assenza ass
    INNER JOIN ga
        ON ga.persona = ass.persona
    WHERE ass.giorno = ga.giorno_att
)
SELECT id, nome, cognome
FROM persona
WHERE id NOT IN (
    SELECT *
    FROM ga_ass
)
ORDER BY id;

--_______
-- E' la stessa ma è stato aggiunto 'AND id IN (SELECT persona FROM assenza)'
-- In teoria è giusta, ma il risultato non coincide con la risposta.
WITH ga AS (
    SELECT persona, giorno AS giorno_att
    FROM attivitaprogetto
    UNION
    SELECT persona, giorno
    FROM attivitanonprogettuale
),
ga_ass AS (
    SELECT ass.persona
    FROM assenza ass
    INNER JOIN ga
        ON ga.persona = ass.persona
       AND ass.giorno = ga.giorno_att
)
SELECT id, nome, cognome
FROM persona
WHERE id NOT IN (SELECT persona FROM ga_ass)
  AND id IN (SELECT persona FROM assenza)
ORDER BY id;

--_______
-- In teoria è giusta ma il risultato, anche se è simile, non coincide con la risposta.
SELECT DISTINCT p.id, p.nome, p.cognome
FROM Persona p
WHERE NOT EXISTS (
  SELECT 1
  FROM Assenza a
  WHERE a.persona = p.id
    AND EXISTS (
      SELECT 1
      FROM AttivitaProgetto ap
      WHERE ap.persona = p.id AND ap.giorno = a.giorno
    )
    OR EXISTS (
      SELECT 1
      FROM AttivitaNonProgettuale anp
      WHERE anp.persona = p.id AND anp.giorno = a.giorno
    )
);

"2. Quali sono le persone (id, nome e cognome) che non hanno mai partecipato ad
alcun progetto durante la durata del progetto “Pegasus”?"
-- persona, progetto, attivitaprogetto - WITH
-- Il risulato combacia con la risposta, e la query sembra scritta bene.
-- Però forse ci sta qualcosa di sbagliato nell'INNER JOIN di peg.
WITH peg AS (
    SELECT ap.persona
    FROM attivitaprogetto ap
    INNER JOIN progetto pr
        ON ap.giorno
            BETWEEN pr.inizio AND pr.fine
    WHERE pr.nome = 'Pegasus'
)
SELECT DISTINCT pe.id, pe.nome, pe.cognome
FROM persona pe
WHERE pe.id NOT IN (
    SELECT *
    FROM peg
)
ORDER BY pe.id;

"3. Quali sono id, nome, cognome e stipendio dei ricercatori con stipendio maggiore
di tutti i professori (associati e ordinari)?"
-- persona - MAX() - WITH
-- In teoria non serve il ditsinct. pe.id dovrebbe avere solo valori distinti visto che è una primary key.
WITH mp AS (
    SELECT MAX(stipendio) max_prof
    FROM persona
    WHERE posizione IN ('Professore Associato', 'Professore Ordinario')
)
SELECT pe.id, pe.nome, pe.cognome, pe.stipendio
FROM persona pe
CROSS JOIN mp
WHERE pe.posizione = 'Ricercatore'
    AND pe.stipendio > mp.max_prof;

"4. Quali sono le persone che hanno lavorato su progetti con un budget superiore alla
media dei budget di tutti i progetti?"
-- persona, attivitaprogetto, progetto - AVG() - WITH
WITH mp AS (
    SELECT AVG(budget) media_progetto
    FROM progetto
)
SELECT DISTINCT pe.id, pe.nome, pe.cognome
FROM persona pe
INNER JOIN attivitaprogetto ap
    ON ap.persona = pe.id
INNER JOIN progetto pr
    ON pr.id = ap.progetto
CROSS JOIN mp
WHERE pr.budget > mp.media_progetto;

"5. Quali sono i progetti con un budget inferiore alla media, ma con un numero
complessivo di ore dedicate alle attività di ricerca sopra la media?"
-- progetto, attivitaprogetto - AVG(), SUM() - WITH
-- Non serve DISTINCT se usi GROUP BY
WITH mb AS (
    SELECT AVG(budget) media_budget
    FROM progetto
),
mo AS (
    SELECT AVG(oredurata) media_ore
    FROM attivitaprogetto ap
)
SELECT pr.id, pr.nome
FROM progetto pr
INNER JOIN attivitaprogetto ap
    ON ap.progetto = pr.id
CROSS JOIN mb
CROSS JOIN mo
WHERE pr.budget < mb.media_budget
    AND ap.tipo = 'Ricerca e Sviluppo'
GROUP BY pr.id, pr.nome, mo.media_ore
HAVING SUM(ap.oredurata) > mo.media_ore;
