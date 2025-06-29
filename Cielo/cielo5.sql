SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Quali sono gli aeroporti raggiungibili da dall'aeroporto 'JFK' tramite voli diretti e
indiretti?"
-- La query è stata presa dall' esercizio 7 di Cielo 4
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

"2. Quali sono le città raggiungibili con voli diretti e indiretti partendo da Roma?"
-- La query è stata presa dall' esercizio 8 di Cielo 4
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

"3. Quali sono i piani di volo, con al più due scali intermedi, da 'FCO' a 'JFK'? Per
ogni piano di volo restituire la sequenza di voli previsti (con aeroporto di partenza,
compagnia, codice volo, aeroporto di arrivo) e la durata complessiva. Evitare di
restituire piani di volo 'degeneri', ovvero che facciano tappa intermedia a FCO o
due volte nello stesso aeroporto. Ordinare il risultato per durata complessiva del
piano di volo."
-- Parte della query è stata presa dall'esercizio 7 di Cielo 4
-- arrpart - WITH, ARRAY[ROW()]
--_______ WITH, ARRAY[ROW()]
WITH voli_diretti AS (
    SELECT ARRAY[
            ROW(ap.partenza, ap.comp, ap.codice, ap.arrivo)] piani_di_volo,
        v.durataminuti durata
    FROM arrpart ap
    INNER JOIN volo v
        ON v.codice = ap.codice
            AND v.comp = ap.comp
    WHERE partenza = 'FCO'
        AND arrivo = 'JFK'
),
voli_1_scalo AS (
    SELECT ARRAY[
            ROW(ap1.partenza, ap1.comp, ap1.codice, ap1.arrivo),
            ROW(ap2.partenza, ap2.comp, ap2.codice, ap2.arrivo)] piani_di_volo,
        (v1.durataminuti + v2.durataminuti) durata
    FROM arrpart ap1
    INNER JOIN arrpart ap2
        ON ap2.partenza = ap1.arrivo
    INNER JOIN volo v1
        ON v1.codice = ap1.codice
            AND v1.comp = ap1.comp
    INNER JOIN volo v2
        ON v2.codice = ap2.codice
            AND v2.comp = ap2.comp
    WHERE ap1.partenza = 'FCO'
        AND ap2.arrivo = 'JFK'
        AND ap2.partenza != 'JFK' --_______
        AND ap1.arrivo != 'FCO' --_______
        AND ap1.arrivo != ap2.arrivo -- niente tappe duplicate --_______
),
voli_2_scalo AS (
    SELECT ARRAY[
            ROW(ap1.partenza, ap1.comp, ap1.codice, ap1.arrivo),
            ROW(ap2.partenza, ap2.comp, ap2.codice, ap2.arrivo),
            ROW(ap3.partenza, ap3.comp, ap3.codice, ap3.arrivo)] piani_di_volo,
        (v1.durataminuti + v2.durataminuti + v3.durataminuti) durata
    FROM arrpart ap1
    INNER JOIN arrpart ap2
        ON ap2.partenza = ap1.arrivo
    INNER JOIN arrpart ap3
        ON ap3.partenza = ap2.arrivo
    INNER JOIN volo v1
        ON v1.codice = ap1.codice
            AND v1.comp = ap1.comp
    INNER JOIN volo v2
        ON v2.codice = ap2.codice
            AND v2.comp = ap2.comp
    INNER JOIN volo v3
        ON v3.codice = ap3.codice
            AND v3.comp = ap3.comp
    WHERE ap1.partenza = 'FCO'
        AND ap3.arrivo = 'JFK'
        AND ap2.partenza != 'JFK' --_______
        AND ap3.partenza != 'JFK' --_______
        AND ap1.arrivo != 'FCO' --_______
        AND ap2.arrivo != 'FCO' --_______
        AND ap2.arrivo != ap3.arrivo -- niente tappe duplicate --_______
)
SELECT *
FROM voli_diretti
UNION
SELECT * 
FROM voli_1_scalo
UNION
SELECT *
FROM voli_2_scalo
ORDER BY durata;
