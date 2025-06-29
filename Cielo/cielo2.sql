SELECT * FROM aeroporto;

SELECT * FROM arrpart;

SELECT * FROM compagnia;

SELECT * FROM luogoaeroporto;

SELECT * FROM volo;

"1. Quante sono le compagnie che operano (sia in arrivo che in partenza) nei diversi
aeroporti?"
--arrpart, luogoaeroporto - COUNT()
SELECT la.aeroporto, COUNT(DISTINCT ap.comp) n_compagnie
FROM arrpart ap
INNER JOIN luogoaeroporto la
    ON la.aeroporto = ap.partenza
        OR la.aeroporto = ap.arrivo
GROUP BY la.aeroporto;

"2. Quanti sono i voli che partono dall'aeroporto 'HTR' e hanno una durata di almeno
100 minuti?"
-- volo, arrpart - COUNT()
SELECT COUNT(v.codice) n_voli
FROM volo v
INNER JOIN arrpart ap
    ON ap.codice = v.codice
        AND ap.comp = v.comp
WHERE ap.partenza = 'HTR'
    AND v.durataminuti >= 100;

"3. Quanti sono gli aeroporti sui quali opera la compagnia 'Apitalia', per ogni nazione
nella quale opera?"
--luogoaeroporto, arrpart - COUNT()
SELECT la.nazione, COUNT(DISTINCT la.aeroporto)
FROM luogoaeroporto la
INNER JOIN arrpart ap
    ON ap.partenza = la.aeroporto
        OR ap.arrivo = la.aeroporto
WHERE ap.comp = 'Apitalia'
GROUP BY la.nazione;

"4. Qual è la media, il massimo e il minimo della durata dei voli effettuati dalla
compagnia 'MagicFly'?"
-- volo - AVG(), MAX(), MIN()
SELECT AVG(durataminuti), MAX(durataminuti), MIN(durataminuti)
FROM volo
WHERE comp = 'MagicFly';

"5. Qual è l'anno di fondazione della compagnia più vecchia che opera in ognuno degli
aeroporti?"
-- compagnia, arrpart - MIN()
WITH ae AS (
    SELECT ap.partenza aeroporti, ap.comp
    FROM arrpart ap
    UNION
    SELECT ap.arrivo aeroporti, ap.comp
    FROM arrpart ap
)
SELECT ae.aeroporti, MIN(annofondaz) anno_piu_vecchio
FROM ae
INNER JOIN compagnia co
    ON co.nome = ae.comp
GROUP BY ae.aeroporti;

"6. Quante sono le nazioni (diverse) raggiungibili da ogni nazione tramite uno o più
voli?"
-- luogoaeroporto, arrpart - COUNT()
SELECT la1.nazione, COUNT(DISTINCT la2.nazione) n_nazioni
FROM arrpart ap
INNER JOIN luogoaeroporto la1
    ON la1.aeroporto = ap.partenza
INNER JOIN luogoaeroporto la2
    ON la2.aeroporto = ap.arrivo
WHERE la1.nazione != la2.nazione
GROUP BY la1.nazione;

"7. Qual è la durata media dei voli che partono da ognuno degli aeroporti?"
-- volo, arrpart - AVG()
SELECT ap.partenza, AVG(v.durataminuti)
FROM arrpart ap
INNER JOIN volo v
    ON v.codice = ap.codice
GROUP BY ap.partenza;

"8. Qual è la durata complessiva dei voli operati da ognuna delle compagnie fondate
a partire dal 1950?"
-- compagnia, volo, arrpart - SUM()
SELECT co.nome, SUM(durataminuti) durata_complessiva
FROM compagnia co
INNER JOIN volo v
    ON v.comp = co.nome
WHERE co.annofondaz >= 1950
GROUP BY co.nome;

"9. Quali sono gli aeroporti nei quali operano esattamente due compagnie?"
--arrpart - COUNT()
SELECT aeroporto
FROM (
    SELECT partenza aeroporto, comp
    FROM arrpart
    UNION
    SELECT arrivo aeroporto, comp
    FROM arrpart
)
GROUP BY aeroporto
HAVING COUNT(DISTINCT comp) = 2;

"10. Quali sono le città con almeno due aeroporti?"
-- luogoaeroporto - COUNT()
SELECT citta
FROM luogoaeroporto
GROUP BY citta
HAVING COUNT(DISTINCT aeroporto) = 2;

"11. Qual è il nome delle compagnie i cui voli hanno una durata media maggiore di 6
ore?"
-- volo - AVG()
SELECT comp
FROM volo
GROUP BY comp
HAVING AVG(durataminuti) > 360;

"12. Qual è il nome delle compagnie i cui voli hanno tutti una durata maggiore di 100
minuti?"
-- volo
SELECT DISTINCT comp
FROM volo
GROUP BY comp
HAVING MIN(durataminuti) > 100;
