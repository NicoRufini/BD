SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Quali sono i voli (codice e nome della compagnia) la cui durata supera le 3 ore?"
SELECT codice, comp FROM volo
WHERE durataminuti > 180;

"2. Quali sono le compagnie che hanno voli che superano le 3 ore?"
SELECT DISTINCT comp FROM volo
WHERE durataminuti > 180;

"3. Quali sono i voli (codice e nome della compagnia) che partono dall'aeroporto con
codice 'CIA'?"
SELECT codice, comp FROM arrpart
WHERE partenza = 'CIA';

"4. Quali sono le compagnie che hanno voli che arrivano al''aeroporto con codice
'FCO'?"
SELECT DISTINCT comp FROM arrpart
WHERE arrivo = 'FCO';

"5. Quali sono i voli (codice e nome della compagnia) che partono dall'aeroporto 'FCO'
e arrivano all'aeroporto 'JFK'?"
SELECT codice, comp FROM arrpart
WHERE partenza = 'FCO'
    AND arrivo = 'JFK';

"6. Quali sono le compagnie che hanno voli che partono dall'aeroporto 'FCO' e atterrano
all'aeroporto 'JFK'?"
SELECT DISTINCT comp FROM arrpart
WHERE partenza = 'FCO'
    AND arrivo = 'JFK';

"7. Quali sono i nomi delle compagnie che hanno voli diretti dalla città di 'Roma' alla
città di 'New York'?" 
-- arrpart, luogoaeroporto
SELECT DISTINCT ap.comp FROM arrpart ap
INNER JOIN luogoaeroporto la_pa ON la_pa.aeroporto = ap.partenza
INNER JOIN luogoaeroporto la_ar ON la_ar.aeroporto = ap.arrivo
WHERE la_pa.citta = 'Roma'
    AND la_ar.citta = 'New York';

"8. Quali sono gli aeroporti (con codice IATA, nome e luogo) nei quali partono voli
della compagnia di nome 'MagicFly'?"
-- arrpart, luogoaeroporto, aeroporto
SELECT ae.codice, ae.nome, la.citta FROM arrpart ap
INNER JOIN luogoaeroporto la ON la.aeroporto = ap.partenza
INNER JOIN aeroporto ae ON ae.codice = ap.partenza
WHERE ap.comp = 'MagicFly';

"9. Quali sono i voli che partono da un qualunque aeroporto della città di 'Roma' e
atterrano ad un qualunque aeroporto della città di 'New York'? Restituire: codice
del volo, nome della compagnia, e aeroporti di partenza e arrivo."
-- arrpart, luogoaeroporto
SELECT ap.codice, ap.comp, ap.partenza, ap.arrivo FROM arrpart ap
INNER JOIN luogoaeroporto la_pa ON la_pa.aeroporto = ap.partenza
INNER JOIN luogoaeroporto la_ar ON la_ar.aeroporto = ap.arrivo
WHERE la_pa.citta = 'Roma'
    AND la_ar.citta = 'New York';

"10. Quali sono i possibili piani di volo con esattamente un cambio (utilizzando solo
voli della stessa compagnia) da un qualunque aeroporto della città di 'Roma' ad un
qualunque aeroporto della città di 'New York'? Restituire: nome della compagnia,
codici dei voli, e aeroporti di partenza, scalo e arrivo."
-- arrpart, luogoaeroporto
WITH volo1 AS (
    SELECT ap.comp, ap.codice codice_volo1, ap.partenza, ap.arrivo scalo FROM arrpart ap
    INNER JOIN luogoaeroporto la_pa ON la_pa.aeroporto = ap.partenza
    WHERE la_pa.citta = 'Roma'
),
volo2 AS (
    SELECT ap.comp, ap.codice codice_volo2, ap.partenza, ap.arrivo FROM arrpart ap
    INNER JOIN luogoaeroporto la_ar ON la_ar.aeroporto = ap.arrivo
    WHERE la_ar.citta = 'New York'
)
SELECT volo1.*, volo2.codice_volo2, volo2.arrivo FROM volo1
INNER JOIN volo2 ON volo2.partenza = volo1.scalo
WHERE volo1.comp = volo2. comp;

"11. Quali sono le compagnie che hanno voli che partono dall'aeroporto 'FCO', atterrano
all'aeroporto 'JFK', e di cui si conosce l'anno di fondazione?"
-- arrpart, compagnie
SELECT ap.comp FROM arrpart ap
INNER JOIN compagnia co ON co.nome = ap.comp
WHERE ap.partenza = 'FCO'
    AND ap.arrivo = 'JFK'
    AND co.annofondaz IS NOT NULL;
