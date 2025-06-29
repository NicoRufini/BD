SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quanti sono gli strutturati di ogni fascia?"
SELECT posizione, COUNT(id) strutturati FROM persona
GROUP BY posizione;

"2. Quanti sono gli strutturati con stipendio ≥ 40000?"
SELECT COUNT(stipendio) strutturati FROM persona
WHERE stipendio > 40000;

"3. Quanti sono i progetti già finiti che superano il budget di 50000?"
SELECT COUNT(id) FROM progetto
WHERE budget > 50000;

"4. Qual è la media, il massimo e il minimo delle ore delle attività relative al progetto
'Pegasus'?"
SELECT AVG(ap.oredurata) media, MIN(ap.oredurata) minimo, MAX(ap.oredurata) massimo FROM progetto pr
INNER JOIN attivitaprogetto ap ON ap.progetto = pr.id
WHERE nome = 'Pegasus';

"5. Quali sono le medie, i massimi e i minimi delle ore giornaliere dedicate al progetto
'Pegasus' da ogni singolo docente?" 
SELECT pe.id, pe.nome, pe.cognome, AVG(ap.oredurata) media, MIN(ap.oredurata) minimo, MAX(ap.oredurata) massimo
FROM progetto pr
INNER JOIN attivitaprogetto ap ON ap.progetto = pr.id
INNER JOIN persona pe ON pe.id = ap.persona
WHERE pr.nome = 'Pegasus' 
GROUP BY pe.id, pe.nome, pe.cognome;

"6. Qual è il numero totale di ore dedicate alla didattica da ogni docente?"
SELECT pe.id, pe.nome, pe.cognome, SUM(anp.oredurata) ore
FROM persona pe
INNER JOIN attivitanonprogettuale anp ON anp.persona = pe.id
WHERE anp.tipo = 'Didattica'
GROUP BY pe.id, pe.nome, pe.cognome;

"7. Qual è la media, il massimo e il minimo degli stipendi dei ricercatori?"
SELECT AVG(stipendio) media, MIN(stipendio) minimo, MAX(stipendio)
FROM persona
WHERE posizione = 'Ricercatore';

"8. Quali sono le medie, i massimi e i minimi degli stipendi dei ricercatori, dei professori
associati e dei professori ordinari?"
SELECT posizione, AVG(stipendio) media, MIN(stipendio) minimo, MAX(stipendio)
FROM persona
GROUP BY posizione;

"9. Quante ore 'Ginevra Riva' ha dedicato ad ogni progetto nel quale ha lavorato?"
-- persona, progetto, attivitaprogetto - SUM()
SELECT pr.id, pr.nome, SUM(ap.oredurata) ore_progetto
FROM persona pe
INNER JOIN attivitaprogetto ap ON ap.persona = pe.id
INNER JOIN progetto pr ON ap.progetto = pr.id
WHERE pe.nome = 'Ginevra' AND pe.cognome = 'Riva'
GROUP BY pr.id, pr.nome;

"10. Qual è il nome dei progetti su cui lavorano più di due strutturati?"
-- progetto, attivitaprogetto
SELECT pr.id, pr.nome
FROM progetto pr
INNER JOIN attivitaprogetto ap ON ap.progetto = pr.id
GROUP BY pr.id, pr.nome
HAVING COUNT(ap.persona) > 1;

"11. Quali sono i professori associati che hanno lavorato su più di un progetto?"
-- persona, attivitaprogetto - COUNT(ap.progetto)
SELECT pe.id, pe.nome, pe.cognome
FROM persona pe
INNER JOIN attivitaprogetto ap ON ap.persona = pe.id
WHERE pe.posizione = 'Professore Associato'
GROUP BY pe.id, pe.nome, pe.cognome
HAVING COUNT(ap.progetto) > 1;
