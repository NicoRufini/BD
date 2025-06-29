SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Qual è la durata media, per ogni compagnia, dei voli che partono da un aeroporto
situato in Italia?"
-- arrpart, luogoaeroporto, volo - AVG()
SELECT v.comp, AVG(v.durataminuti)
FROM volo v
INNER JOIN arrpart ap
    ON ap.comp = v.comp
        AND ap.codice = v.codice
INNER JOIN luogoaeroporto la
    ON la.aeroporto = ap.partenza
WHERE la.nazione = 'Italy'
GROUP BY v.comp;

"2. Quali sono le compagnie che operano voli con durata media maggiore della durata
media di tutti i voli?"
-- volo - AVG
WITH mvt AS (
    SELECT AVG(durataminuti) durataminuti_media_totale
    FROM volo
)
SELECT comp, AVG(durataminuti) durataminuti_media_comp
FROM volo v
CROSS JOIN mvt
GROUP BY comp, mvt.durataminuti_media_totale
HAVING AVG(durataminuti) > mvt.durataminuti_media_totale;

"3. Quali sono le città dove il numero totale di voli in arrivo è maggiore del numero
medio dei voli in arrivo per ogni città?" 
WITH voli_arrivo AS (
    SELECT la.citta, COUNT(ap.arrivo) n_voli_arrivo
    FROM arrpart ap
    INNER JOIN luogoaeroporto la
        ON la.aeroporto = ap.arrivo
    GROUP BY la.citta
),
voli_media AS (
    SELECT AVG(n_voli_arrivo) media
    FROM voli_arrivo
)
SELECT la.citta, COUNT(ap.arrivo) n_voli_arrivo_citta
FROM luogoaeroporto la
INNER JOIN arrpart ap
    ON ap.arrivo = la.aeroporto
CROSS JOIN voli_media
GROUP BY la.citta, media
HAVING COUNT(ap.arrivo) > media;

"4. Quali sono le compagnie aeree che hanno voli in partenza da aeroporti in Italia con
una durata media inferiore alla durata media di tutti i voli in partenza da aeroporti
in Italia?"
-- In teoria è giusta ma il risultato non combacia.
--arrpart, luogoaeroporto, volo - AVG()
WITH durata_media_Italia AS (
    SELECT AVG(v.durataminuti) durataminuti_media_Italia
    FROM volo v
    INNER JOIN arrpart ap
        ON ap.comp = v.comp
            AND ap.codice = v.codice
    INNER JOIN luogoaeroporto la
        ON la.aeroporto = ap.partenza
    WHERE la.nazione = 'Italy'
)
SELECT v.comp, AVG(v.durataminuti) durataminuti_media_comp_Italia
FROM volo v
INNER JOIN arrpart ap
    ON ap.comp = v.comp
        AND ap.codice = v.codice
INNER JOIN luogoaeroporto la
    ON la.aeroporto = ap.partenza
CROSS JOIN durata_media_Italia
WHERE la.nazione = 'Italy'
GROUP BY v.comp, durataminuti_media_Italia
HAVING AVG(v.durataminuti) < durata_media_Italia.durataminuti_media_Italia;

"5. Quali sono le città i cui voli in arrivo hanno una durata media che differisce di più
di una deviazione standard dalla durata media di tutti i voli? Restituire città e
durate medie dei voli in arrivo."
--_______
WITH media_dev_totale AS (
    SELECT AVG(v.durataminuti) media_totale, STDDEV(v.durataminuti) dev_totale
    FROM volo v
    INNER JOIN arrpart ap
        ON ap.codice = v.codice
            AND ap.comp = v.comp
),
mc AS (
    SELECT la.citta, AVG(v.durataminuti) media_citta
    FROM volo v
    INNER JOIN arrpart ap
        ON ap.codice = v.codice
            AND ap.comp = v.comp
    INNER JOIN luogoaeroporto la
        ON la.aeroporto = ap.arrivo
    GROUP BY la.citta
)
SELECT mc.*
FROM mc
CROSS JOIN media_dev_totale
WHERE (media_dev_totale.media_totale - mc.media_citta) > media_dev_totale.dev_totale;

"6. Quali sono le nazioni che hanno il maggior numero di città dalle quali partono voli
diretti in altre nazioni?"
-- La query non è corretta in SQL standard, se eseguita su altri DBMS (MySQL, Oracle, SQL Server, ecc.)
-- dovrebbe dare errore. PostgreSQL tuttavia, consente alcune estensioni non standard di SQL,
-- quindi su pgAdmin NON da errore.
WITH nazioni_citta_partenze_altre_nazioni AS (
SELECT la1.nazione, la1.citta, COUNT(ap.partenza) n_partenze --COUNT(ap.partenza NON è obbligatorio)
FROM arrpart ap
INNER JOIN luogoaeroporto la1
    ON ap.partenza = la1.aeroporto
INNER JOIN luogoaeroporto la2
    ON ap.arrivo = la2.aeroporto
WHERE la1.nazione != la2.nazione
GROUP BY la1.nazione, la1.citta
HAVING COUNT(ap.partenza) >= 1
),
count_ncpan AS (
SELECT nazione, COUNT(nazione) n_citta
FROM nazioni_citta_partenze_altre_nazioni
GROUP BY nazione
)
SELECT nazione, n_citta
FROM count_ncpan
GROUP BY nazione, n_citta
HAVING n_citta = MAX(n_citta);

-- Questa è corretta in SQL standard.
--_______
WITH nazioni_citta_partenze_altre_nazioni AS (
    SELECT la1.nazione, la1.citta
    FROM arrpart ap
    INNER JOIN luogoaeroporto la1 ON ap.partenza = la1.aeroporto
    INNER JOIN luogoaeroporto la2 ON ap.arrivo = la2.aeroporto
    WHERE la1.nazione != la2.nazione
    GROUP BY la1.nazione, la1.citta
),
count_ncpan AS (
    SELECT nazione, COUNT(*) AS n_citta
    FROM nazioni_citta_partenze_altre_nazioni
    GROUP BY nazione
),
max_citta AS (
    SELECT MAX(n_citta) AS max_n_citta
    FROM count_ncpan
)
SELECT c.nazione, c.n_citta
FROM count_ncpan c
CROSS JOIN max_citta m
WHERE c.n_citta = m.max_n_citta;
