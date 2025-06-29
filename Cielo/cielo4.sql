SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Quali sono i voli di durata maggiore della durata media di tutti i voli della stessa
compagnia? Restituire il codice del volo, la compagnia e la durata."
-- volo - AVG() - WITH
WITH dm AS (
    SELECT comp, AVG(durataminuti) durata_media
    FROM volo
    GROUP BY comp
)
SELECT v.codice, v.comp, v.durataminuti
FROM volo v
INNER JOIN dm
    ON dm.comp = v.comp
WHERE v.durataminuti > dm.durata_media;

"2. Quali sono le città che hanno più di un aeroporto e dove almeno uno di questi ha
un volo operato da “Apitalia”?"
-- luogoaeroporto, arrpart - COUNT() - WITH, UNION
WITH ae_api AS (
    -- Voglio selezionare solo gli aeroporti di Apitalia, 
    -- per farlo WHERE lo devo applicare a tutti e due i SELECT,
    -- non basta a farlo con solo uno dei due SELECT.
    SELECT ap.partenza aeroporto
    FROM arrpart ap
    WHERE ap.comp = 'Apitalia'
    UNION
    SELECT ap.arrivo aeroporto
    FROM arrpart ap
    WHERE ap.comp = 'Apitalia'
)
SELECT la.citta -- Il DISTINCT è inutile visto che sto usando GROUP BY
FROM luogoaeroporto la
INNER JOIN ae_api
    ON ae_api.aeroporto = la.aeroporto
GROUP BY la.citta
HAVING COUNT(la.citta) > 1;

"3. Quali sono le coppie di aeroporti (A, B) tali che esistono voli tra A e B ed il numero
di voli da A a B è uguale al numero di voli da B ad A?"
-- In teoria è giusta, e il risultato che da combacia con la risposta.
-- Però non ne sono sicuro.
-- arrpart - COUNT() - WITH
WITH nc AS (
    SELECT ap.partenza, ap.arrivo, COUNT((ap.partenza, ap.arrivo)) n_coppie
    FROM arrpart ap
    GROUP BY ap.partenza, ap.arrivo
)
SELECT ab.partenza, ab.arrivo --DISTINCT
    FROM arrpart ab
    INNER JOIN arrpart ba
        ON ba.partenza = ab.arrivo
            AND ba.arrivo = ab.partenza
    INNER JOIN nc
        ON nc.partenza = ab.partenza
            AND nc.arrivo = ab.arrivo
GROUP BY ab.partenza, ab.arrivo, nc.n_coppie
HAVING COUNT((ab.partenza, ab.arrivo)) = nc.n_coppie;

"4. Quali sono le compagnie che hanno voli con durata media maggiore della durata
media di tutte le compagnie?"
-- In teoria è giusta, e il risultato che da combacia con la risposta.
-- Però non ne sono sicuro.
-- volo - AVG() - WITH
WITH dm AS (
    SELECT AVG(durataminuti) durata_media
    FROM volo
)
SELECT v.comp
FROM volo v
CROSS JOIN dm
GROUP BY v.comp, dm.durata_media
HAVING AVG(durataminuti) > dm.durata_media;

"5. Quali sono gli aeroporti da cui partono voli per almeno 2 nazioni diverse?"
-- arrpart, luogoaeroporto, aeroporto - COUNT() - WITH
WITH nv AS (
    SELECT partenza, COUNT(DISTINCT arrivo) n_voli
    FROM arrpart
    GROUP BY partenza
)
SELECT DISTINCT la1.aeroporto
FROM arrpart ap
INNER JOIN luogoaeroporto la1
    ON la1.aeroporto = ap.partenza
INNER JOIN luogoaeroporto la2
    ON la2.aeroporto = ap.arrivo
INNER JOIN nv
    ON nv.partenza = la1.aeroporto
WHERE la1.nazione != la2.nazione
    AND nv.n_voli > 1;

"6. Quali sono i voli che partono dalle città con un unico aeroporto? Restituire codice
dei voli, compagnie, e gli aeroporti di partenza e di arrivo."
-- volo, luogoaeroporto, arrpart - COUNT() - WITH
WITH n_ae AS (
    SELECT citta, COUNT(citta) n_aeroporti
    FROM luogoaeroporto
    GROUP BY citta
)
SELECT ap.codice, ap.comp, ap.partenza, ap.arrivo
FROM arrpart ap
INNER JOIN luogoaeroporto la
    ON la.aeroporto = ap.partenza
INNER JOIN n_ae
    ON n_ae.citta = la.citta
WHERE n_ae.n_aeroporti = 1;

"7. Quali sono gli aeroporti raggiungibili dall'aeroporto “JFK” tramite voli diretti e
indiretti?"
-- arrpart - UNION
SELECT DISTINCT ap2.arrivo
FROM arrpart ap1
INNER JOIN arrpart ap2
    ON ap2.partenza = ap1.arrivo
WHERE ap1.partenza = 'JFK'
UNION
SELECT DISTINCT arrivo
FROM arrpart
WHERE partenza = 'JFK';

"8. Quali sono le città raggiungibili con voli diretti e indiretti partendo da Roma?"
-- luogoaeroporto, arrpart - UNION
SELECT DISTINCT la2.citta
FROM arrpart ap1
INNER JOIN arrpart ap2
    ON ap2.partenza = ap1.arrivo
INNER JOIN luogoaeroporto la1
    ON la1.aeroporto = ap1.partenza
INNER JOIN luogoaeroporto la2
    ON la2.aeroporto = ap2.arrivo
WHERE la1.citta = 'Roma'
UNION
SELECT DISTINCT la2.citta
FROM luogoaeroporto la1
INNER JOIN arrpart ap
    ON ap.partenza = la1.aeroporto
INNER JOIN luogoaeroporto la2
    ON la2.aeroporto = ap.arrivo
WHERE la1.citta = 'Roma';

"9. Quali sono le città raggiungibili con esattamente uno scalo intermedo partendo
dall'aeroporto “JFK”?"
-- arrpart, luogoaeroporto
SELECT DISTINCT la.citta
FROM arrpart ap1
INNER JOIN arrpart ap2
    ON ap2.partenza = ap1.arrivo
INNER JOIN luogoaeroporto la
    ON la.aeroporto = ap2.arrivo
WHERE ap1.partenza = 'JFK';
