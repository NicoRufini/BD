SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

-- |||

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
SELECT citta, voli_arrivo FROM voli_arrivo_query, media_voli_arrivo_query
WHERE voli_arrivo > media_voli_arrivo;

"4. Quali sono le compagnie aeree che hanno voli in partenza da aeroporti in Italia con
una durata media inferiore alla durata media di tutti i voli in partenza da aeroporti
in Italia?"
--- Prima soluzione - durata_media NON è quella del risultato
WITH voli_partenza_italia_durata_media_query AS (
    SELECT AVG(volo.durataminuti) AS voli_partenza_italia_durata_media FROM volo
    INNER JOIN arrpart ON arrpart.codice = volo.codice
    INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    WHERE luogoaeroporto.nazione = 'Italy'
)
SELECT arrpart.comp, AVG(volo.durataminuti) AS durata_media FROM arrpart
INNER JOIN volo ON arrpart.codice = volo.codice
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
WHERE luogoaeroporto.nazione = 'Italy'
GROUP BY arrpart.comp
HAVING AVG(volo.durataminuti) < (SELECT * FROM voli_partenza_italia_durata_media_query);

-- Seconda soluzione
WITH voli_partenza_italia_durata_media_query AS (
    SELECT AVG(volo.durataminuti) AS voli_partenza_italia_durata_media FROM volo
    INNER JOIN arrpart ON arrpart.codice = volo.codice
    INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    WHERE luogoaeroporto.nazione = 'Italy'
)
SELECT arrpart.comp, (SELECT * FROM voli_partenza_italia_durata_media_query) AS durata_media FROM arrpart
CROSS JOIN voli_partenza_italia_durata_media_query -- ?
INNER JOIN volo ON arrpart.codice = volo.codice
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
WHERE luogoaeroporto.nazione = 'Italy'
GROUP BY arrpart.comp, voli_partenza_italia_durata_media_query.voli_partenza_italia_durata_media
HAVING AVG(volo.durataminuti) < (SELECT * FROM voli_partenza_italia_durata_media_query);

"5. Quali sono le città i cui voli in arrivo hanno una durata media che differisce di più
di una deviazione standard dalla durata media di tutti i voli? Restituire città e
durate medie dei voli in arrivo."
WITH durata_media_deviazione_standard_generica_query AS (
    SELECT AVG(durataminuti) AS durata_media_generica, STDDEV(durataminuti) AS deviazione_standard_generica FROM volo
)   
SELECT luogoaeroporto.citta, AVG(volo.durataminuti)::NUMERIC(10, 2) AS durata_media_per_citta FROM luogoaeroporto
INNER JOIN arrpart ON luogoaeroporto.aeroporto = arrpart.arrivo
INNER JOIN volo ON arrpart.codice = volo.codice
GROUP BY luogoaeroporto.citta
HAVING AVG(volo.durataminuti) > ((SELECT durata_media_generica FROM durata_media_deviazione_standard_generica_query)
    + (SELECT deviazione_standard_generica FROM durata_media_deviazione_standard_generica_query))
    OR AVG(volo.durataminuti) < ((SELECT durata_media_generica FROM durata_media_deviazione_standard_generica_query) 
    - (SELECT deviazione_standard_generica FROM durata_media_deviazione_standard_generica_query));

"6. Quali sono le nazioni che hanno il maggior numero di città dalle quali partono voli
diretti in altre nazioni?"
--_______2
-- ?
WITH partenza_arrivo_stessa_nazione_query AS (
    SELECT  a_partenza.nazione, arrpart.partenza, a_arrivo.nazione, arrpart.arrivo FROM arrpart
    INNER JOIN luogoaeroporto AS a_partenza ON a_partenza.aeroporto = arrpart.partenza
    INNER JOIN luogoaeroporto AS a_arrivo ON a_arrivo.aeroporto = arrpart.arrivo
    WHERE a_partenza.nazione = a_arrivo.nazione
),
arrpart_condizione6_query AS (
    SELECT *, CASE
        WHEN arrpart.partenza IN (SELECT partenza_arrivo_stessa_nazione_query.partenza FROM partenza_arrivo_stessa_nazione_query)
            AND arrpart.arrivo IN (SELECT partenza_arrivo_stessa_nazione_query.arrivo FROM partenza_arrivo_stessa_nazione_query)
    THEN 0 ELSE 1 END AS condizione6
    FROM arrpart
),
numero_citta_partenze_query AS (
    SELECT luogoaeroporto.nazione, COUNT(DISTINCT luogoaeroporto.citta) AS numero_citta_partenze FROM luogoaeroporto
    INNER JOIN arrpart_condizione6_query ON luogoaeroporto.aeroporto = arrpart_condizione6_query.partenza
    WHERE condizione6 = 1
    GROUP BY luogoaeroporto.nazione
),
max_citta_partenze_query AS (
    SELECT MAX(numero_citta_partenze) AS max_citta_partenze FROM numero_citta_partenze_query
)
SELECT nazione, numero_citta_partenze FROM numero_citta_partenze_query, max_citta_partenze_query
WHERE max_citta_partenze = numero_citta_partenze;
