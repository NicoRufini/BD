SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Qual è la durata media, per ogni compagnia, dei voli che partono da un aeroporto
situato in Italia?"
SELECT volo.comp, AVG(volo.durataminuti)::NUMERIC(10, 2) AS durata_media FROM volo
INNER JOIN arrpart ON arrpart.codice = volo.codice
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
WHERE luogoaeroporto.nazione = 'Italy'
GROUP BY volo.comp;

"2. Quali sono le compagnie che operano voli con durata media maggiore della durata
media di tutti i voli?"
WITH volo_durata_media AS (
    SELECT AVG(volo.durataminuti)::NUMERIC(10, 2) AS durata_media_generica FROM volo
)
SELECT volo.comp, AVG(volo.durataminuti)::NUMERIC(10, 2) AS durata_media FROM volo, volo_durata_media
GROUP BY volo.comp, volo_durata_media.durata_media_generica
HAVING AVG(volo.durataminuti) > volo_durata_media.durata_media_generica;

"3. Quali sono le città dove il numero totale di voli in arrivo è maggiore del numero
medio dei voli in arrivo per ogni città?" 
WITH voli_arrivo_query AS (
    SELECT luogoaeroporto.citta, COUNT(DISTINCT arrpart.codice) AS voli_arrivo FROM arrpart -- DISTINCT in questo caso non è necessario
    INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.arrivo
    GROUP BY luogoaeroporto.citta
),
media_voli_arrivo_query AS (
    SELECT AVG(voli_arrivo_query.voli_arrivo) AS media_voli_arrivo FROM arrpart, voli_arrivo_query
)
SELECT citta FROM voli_arrivo_query, media_voli_arrivo_query
WHERE voli_arrivo > media_voli_arrivo;

"4. Quali sono le compagnie aeree che hanno voli in partenza da aeroporti in Italia con
una durata media inferiore alla durata media di tutti i voli in partenza da aeroporti
in Italia?"
--- Prima soluzione
WITH voli_partenza_italia_durata_media_query AS (
    SELECT AVG(volo.durataminuti) AS voli_partenza_italia_durata_media FROM volo
    INNER JOIN arrpart ON arrpart.codice = volo.codice
    INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    WHERE luogoaeroporto.nazione = 'Italy'
)
SELECT arrpart.comp, voli_partenza_italia_durata_media_query.voli_partenza_italia_durata_media FROM arrpart
INNER JOIN volo ON arrpart.codice = volo.codice
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
WHERE luogoaeroporto.nazione = 'Italy'
GROUP BY arrpart.comp, voli_partenza_italia_durata_media_query.voli_partenza_italia_durata_media
HAVING AVG(volo.durataminuti) < (SELECT * FROM voli_partenza_italia_durata_media_query);

-- Seconda soluzione
WITH voli_partenza_italia_durata_media_query AS (
    SELECT AVG(volo.durataminuti) AS voli_partenza_italia_durata_media FROM volo
    INNER JOIN arrpart ON arrpart.codice = volo.codice
    INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    WHERE luogoaeroporto.nazione = 'Italy'
)
SELECT arrpart.comp, voli_partenza_italia_durata_media_query.voli_partenza_italia_durata_media AS durata_media FROM arrpart
CROSS JOIN voli_partenza_italia_durata_media_query -- ?
INNER JOIN volo ON arrpart.codice = volo.codice
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
WHERE luogoaeroporto.nazione = 'Italy'
GROUP BY arrpart.comp, voli_partenza_italia_durata_media_query.voli_partenza_italia_durata_media
HAVING AVG(volo.durataminuti) < voli_partenza_italia_durata_media_query.voli_partenza_italia_durata_media;








-- INNER JOIN luogoaeroporto ON arrpart.partenza = luogoaeroporto.aeroporto
-- INNER JOIN volo ON 


SELECT arrpart.comp FROM arrpart





























"5. Quali sono le città i cui voli in arrivo hanno una durata media che differisce di più
di una deviazione standard dalla durata media di tutti i voli? Restituire città e
durate medie dei voli in arrivo."

"6. Quali sono le nazioni che hanno il maggior numero di città dalle quali partono voli
diretti in altre nazioni?"

