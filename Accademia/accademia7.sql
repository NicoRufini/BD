SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Qual è media e deviazione standard degli stipendi per ogni categoria di strutturati?"
-- persona - AVG(), STDDEV()
SELECT posizione, AVG(stipendio) media, STDDEV(stipendio)
FROM persona
GROUP BY posizione;

"2. Quali sono i ricercatori (tutti gli attributi) con uno stipendio superiore alla media
della loro categoria?"
-- persona - AVG()
WITH mr AS (
    SELECT AVG(stipendio) media_ricercatore
    FROM persona
    WHERE posizione = 'Ricercatore'
)
SELECT pe.*
FROM persona pe
CROSS JOIN mr
WHERE pe.posizione = 'Ricercatore'
GROUP BY pe.id, mr.media_ricercatore
HAVING AVG(pe.stipendio) > mr.media_ricercatore;

"3. Per ogni categoria di strutturati quante sono le persone con uno stipendio che
differisce di al massimo una deviazione standard dalla media della loro categoria?"
-- persona - STDDEV(), AVG()(?)
--_______
WITH pecdv AS (
    SELECT posizione, AVG(stipendio) cat_media, STDDEV(stipendio) cat_dev_stan
    FROM persona
    GROUP BY posizione
)
SELECT pe.posizione, COUNT(*) persone
FROM persona pe
INNER JOIN pecdv
    ON pecdv.posizione = pe.posizione
WHERE pe.stipendio --_______
    BETWEEN pecdv.cat_media - pecdv.cat_dev_stan --_______
        AND pecdv.cat_media + pecdv.cat_dev_stan --_______
GROUP BY pe.posizione;

"4. Chi sono gli strutturati che hanno lavorato almeno 20 ore complessive in attività
progettuali? Restituire tutti i loro dati e il numero di ore lavorate."
-- persona, attivitaprogetto - SUM()
SELECT pe.*, SUM(oredurata) ore
FROM persona pe
INNER JOIN attivitaprogetto ap
    ON ap.persona = pe.id
GROUP BY pe.id
HAVING SUM(oredurata) >= 20;

"5. Quali sono i progetti la cui durata è superiore alla media delle durate di tutti i
progetti? Restituire nome dei progetti e loro durata in giorni."
-- progetto - AVG()
WITH dm AS (
    SELECT AVG(fine - inizio) dur_media
    FROM progetto
)
SELECT pr.nome, (pr.fine - pr.inizio) durata
FROM progetto pr
CROSS JOIN dm
WHERE (pr.fine - pr.inizio) > dm.dur_media;

"6. Quali sono i progetti terminati in data odierna che hanno avuto attività di tipo
“Dimostrazione”? Restituire nome di ogni progetto e il numero complessivo delle
ore dedicate a tali attività nel progetto."
-- progetto, attivitaprogetto - SUM()
SELECT pr.nome, SUM(ap.oredurata)
FROM progetto pr
INNER JOIN attivitaprogetto ap
    ON ap.progetto = pr.id
WHERE ap.tipo = 'Dimostrazione'
GROUP BY pr.nome;

"7. Quali sono i professori ordinari che hanno fatto più assenze per malattia del numero
di assenze medio per malattia dei professori associati? Restituire id, nome e
cognome del professore e il numero di giorni di assenza per malattia."
-- persona, assenza - AVG(), SUM()
WITH a_t AS (
    SELECT pe.posizione, COUNT(ass.*) ass_totali
    FROM persona pe
    INNER JOIN assenza ass
        ON ass.persona = pe.id
    WHERE pe.posizione = 'Professore Associato'
        AND ass.tipo = 'Malattia'
    GROUP BY pe.posizione
),
am AS (
    SELECT AVG(ass_totali) ass_media
    FROM a_t
)
SELECT pe.id, pe.nome, pe.cognome, COUNT(ass.*) num_giorni
FROM persona pe
INNER JOIN assenza ass
    ON ass.persona = pe.id
CROSS JOIN am
WHERE pe.posizione = 'Professore Ordinario'
    AND ass.tipo = 'Malattia'
GROUP BY pe.id, pe.nome, pe.cognome
HAVING COUNT(ass.*) > am.ass_media;
