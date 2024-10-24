SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Quali sono i voli (codice e nome della compagnia) la cui durata supera le 3 ore?"
SELECT codice, comp FROM volo
WHERE durataminuti > 180;

"2. Quali sono le compagnie che hanno voli che superano le 3 ore?"
SELECT DISTINCT volo.comp FROM volo
INNER JOIN compagnia ON compagnia.nome = volo.comp
WHERE durataminuti > 180;

"3. Quali sono i voli (codice e nome della compagnia) che partono dall'aeroporto con
codice 'CIA'?"
SELECT volo.codice, volo.comp FROM volo
INNER JOIN arrpart ON arrpart.codice = volo.codice
WHERE arrpart.partenza = 'CIA';

"4. Quali sono le compagnie che hanno voli che arrivano al''aeroporto con codice
'FCO'?"
SELECT DISTINCT compagnia.nome FROM compagnia
INNER JOIN arrpart ON arrpart.comp = compagnia.nome
WHERE arrpart.arrivo = 'FCO';

"5. Quali sono i voli (codice e nome della compagnia) che partono dall'aeroporto 'FCO'
e arrivano all'aeroporto 'JFK'?"
SELECT volo.codice, volo.comp FROM volo
INNER JOIN arrpart ON arrpart.codice = volo.codice
WHERE arrpart.partenza = 'FCO' AND arrpart.arrivo = 'JFK';

"6. Quali sono le compagnie che hanno voli che partono dall'aeroporto 'FCO' e atterrano
all'aeroporto 'JFK'?"
SELECT DISTINCT compagnia.nome FROM compagnia
INNER JOIN arrpart ON arrpart.comp = compagnia.nome
WHERE arrpart.partenza = 'FCO' AND arrpart.arrivo = 'JFK';

"7. Quali sono i nomi delle compagnie che hanno voli diretti dalla città di 'Roma' alla
città di 'New York'?" --
SELECT DISTINCT compagnia.nome FROM arrpart
INNER JOIN compagnia ON arrpart.comp = compagnia.nome
INNER JOIN luogoaeroporto ON arrpart.partenza = luogoaeroporto.aeroporto 
    OR arrpart.arrivo = luogoaeroporto.aeroporto
WHERE luogoaeroporto.citta IN ('Roma', 'New York');

"8. Quali sono gli aeroporti (con codice IATA, nome e luogo) nei quali partono voli
della compagnia di nome 'MagicFly'?"
SELECT aeroporto.codice, aeroporto.nome, luogoaeroporto.citta FROM aeroporto
INNER JOIN luogoaeroporto ON aeroporto.codice = luogoaeroporto.aeroporto
INNER JOIN arrpart ON arrpart.partenza = aeroporto.codice
WHERE arrpart.comp = 'MagicFly';

"9. Quali sono i voli che partono da un qualunque aeroporto della città di 'Roma' e
atterrano ad un qualunque aeroporto della città di 'New York'? Restituire: codice
del volo, nome della compagnia, e aeroporti di partenza e arrivo."
SELECT arrpart.* FROM arrpart
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    OR luogoaeroporto.aeroporto = arrpart.arrivo
WHERE luogoaeroporto.citta = 'New York' AND arrpart.partenza IN ('FCO', 'CIA')
    AND arrpart.arrivo = 'JFK';

"10. Quali sono i possibili piani di volo con esattamente un cambio (utilizzando solo
voli della stessa compagnia) da un qualunque aeroporto della città di 'Roma' ad un
qualunque aeroporto della città di 'New York'? Restituire: nome della compagnia,
codici dei voli, e aeroporti di partenza, scalo e arrivo."
WITH volo1_tabella AS (
    SELECT DISTINCT arrpart.comp, arrpart.partenza, arrpart.codice, arrpart.arrivo FROM arrpart
    INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    OR luogoaeroporto.aeroporto = arrpart.arrivo
    WHERE arrpart.partenza IN ('FCO', 'CIA') AND arrpart.arrivo IN ('FCO', 'CIA')
)
SELECT DISTINCT arrpart.comp, volo1_tabella.codice AS codice_volo_1, volo1_tabella.partenza, volo1_tabella.arrivo AS scalo, arrpart.codice AS codice_volo_2, arrpart.arrivo FROM arrpart
INNER JOIN volo1_tabella ON volo1_tabella.arrivo = arrpart.partenza AND volo1_tabella.comp = arrpart.comp
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza 
    OR luogoaeroporto.aeroporto = arrpart.arrivo
WHERE arrpart.arrivo = 'JFK';

"11. Quali sono le compagnie che hanno voli che partono dall'aeroporto 'FCO', atterrano
all'aeroporto 'JFK', e di cui si conosce l'anno di fondazione?"
SELECT arrpart.comp FROM arrpart
INNER JOIN compagnia ON compagnia.nome = arrpart.comp
WHERE arrpart.partenza = 'FCO' AND arrpart.arrivo = 'JFK'
    AND annofondaz IS NOT NULL;

