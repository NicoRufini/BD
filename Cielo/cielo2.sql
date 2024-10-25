SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Quante sono le compagnie che operano (sia in arrivo che in partenza) nei diversi
aeroporti?"
--- questo va bene |||
SELECT aeroporto.codice, aeroporto.nome, COUNT(DISTINCT arrpart.comp) AS num_compagnie FROM arrpart
INNER JOIN aeroporto ON aeroporto.codice = arrpart.partenza OR aeroporto.codice = arrpart.arrivo
GROUP BY  aeroporto.codice, aeroporto.nome;


"2. Quanti sono i voli che partono dall'aeroporto 'HTR' e hanno una durata di almeno
100 minuti?"
SELECT COUNT(volo.codice) AS num_voli FROM volo
INNER JOIN arrpart ON volo.codice = arrpart.codice
WHERE arrpart.partenza = 'HTR' AND volo.durataminuti >= 100;

"3. Quanti sono gli aeroporti sui quali opera la compagnia 'Apitalia', per ogni nazione
nella quale opera?"
SELECT DISTINCT COUNT(DISTINCT luogoaeroporto.aeroporto) AS num_aeroporti, luogoaeroporto.nazione FROM arrpart
INNER JOIN luogoaeroporto ON luogoaeroporto.aeroporto = arrpart.partenza
    OR luogoaeroporto.aeroporto = arrpart.arrivo
WHERE arrpart.comp = 'Apitalia'
GROUP BY luogoaeroporto.nazione
ORDER BY num_aeroporti DESC;

"4. Qual è la media, il massimo e il minimo della durata dei voli effettuati dalla
compagnia 'MagicFly'?"
SELECT DISTINCT MAX(durataminuti) AS massimo_MagicFly, MIN(durataminuti) AS minimo_MagicFly, AVG(durataminuti)::NUMERIC(10,2) AS media_MagicFly FROM volo
WHERE comp = 'MagicFly';

"5. Qual è l'anno di fondazione della compagnia più vecchia che opera in ognuno degli
aeroporti?"
--- Funziona ma forse lo puoi migliorare
WITH arrpart_volo AS (
    SELECT arrpart.partenza AS arr_volo FROM arrpart
    UNION
    SELECT arrpart.arrivo FROM arrpart
)
SELECT arrpart_volo.arr_volo, aeroporto.nome, MIN(compagnia.annofondaz) AS anno FROM arrpart
INNER JOIN arrpart_volo ON arrpart_volo.arr_volo = arrpart.partenza OR arrpart_volo.arr_volo = arrpart.arrivo
INNER JOIN volo ON volo.codice = arrpart.codice
INNER JOIN compagnia ON volo.comp = compagnia.nome
INNER JOIN aeroporto ON aeroporto.codice = arrpart_volo.arr_volo
GROUP BY arrpart_volo.arr_volo, aeroporto.nome;

"6. Quante sono le nazioni (diverse) raggiungibili da ogni nazione tramite uno o più
voli?"
--- \
SELECT luogoaeroporto.nazione, COUNT(DISTINCT arrpart.arrivo) AS raggiungibili FROM luogoaeroporto
INNER JOIN arrpart ON luogoaeroporto.aeroporto = arrpart.arrivo
GROUP BY luogoaeroporto.nazione;

"7. Qual è la durata media dei voli che partono da ognuno degli aeroporti?"


"8. Qual è la durata complessiva dei voli operati da ognuna delle compagnie fondate
a partire dal 1950?"


"9. Quali sono gli aeroporti nei quali operano esattamente due compagnie?"


"10. Quali sono le città con almeno due aeroporti?"


"11. Qual è il nome delle compagnie i cui voli hanno una durata media maggiore di 6
ore?"


"12. Qual è il nome delle compagnie i cui voli hanno tutti una durata maggiore di 100
minuti?"

