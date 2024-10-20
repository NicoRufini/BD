SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quanti sono gli strutturati di ogni fascia?"
SELECT posizione, COUNT(posizione) AS numero FROM persona
GROUP BY posizione;

"2. Quanti sono gli strutturati con stipendio ≥ 40000?"
SELECT COUNT(stipendio) AS numero FROM persona
WHERE stipendio >= 40000;

"3. Quanti sono i progetti già finiti che superano il budget di 50000?"
SELECT COUNT(budget) AS numero FROM progetto
WHERE budget >= 50000;

"4. Qual è la media, il massimo e il minimo delle ore delle attività relative al progetto
'Pegasus'?"
SELECT AVG(oredurata)::NUMERIC(10, 2) as media, MAX(oredurata) as massimo, min(oredurata) as minimo FROM attivitaprogetto
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
WHERE progetto.nome = 'Pegasus';

"5. Quali sono le medie, i massimi e i minimi delle ore giornaliere dedicate al progetto
'Pegasus' da ogni singolo docente?" 
SELECT persona.id, persona.nome, persona.cognome, persona.posizione, AVG(oredurata)::NUMERIC(10, 2) as media, MAX(oredurata) as massimo, min(oredurata) as minimo FROM attivitaprogetto
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
INNER JOIN persona ON persona.id = attivitaprogetto.persona
WHERE progetto.nome = 'Pegasus' "Questa parte non so se serve'AND persona.posizione IN ('Professore Ordinario', 'Ricercatore')'"
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione;

"6. Qual è il numero totale di ore dedicate alla didattica da ogni docente?"
SELECT SUM(oredurata) AS oreDidattica, persona.id, persona.nome, persona.cognome, persona.posizione FROM attivitanonprogettuale
INNER JOIN persona ON persona.id = attivitanonprogettuale.persona
WHERE attivitanonprogettuale.tipo = 'Didattica'
GROUP BY persona.id, persona.nome, persona.cognome, persona.posizione;

"7. Qual è la media, il massimo e il minimo degli stipendi dei ricercatori?"
SELECT AVG(stipendio)::NUMERIC(10, 2) as media, MAX(stipendio) as massimo, min(stipendio) as minimo FROM persona
WHERE posizione = 'Ricercatore';

"8. Quali sono le medie, i massimi e i minimi degli stipendi dei ricercatori, dei professori
associati e dei professori ordinari?"
SELECT posizione, AVG(stipendio)::NUMERIC(10, 2) as media, MAX(stipendio) as massimo, min(stipendio) as minimo FROM persona
GROUP BY posizione;

"9. Quante ore 'Ginevra Riva' ha dedicato ad ogni progetto nel quale ha lavorato?"
SELECT progetto.id, progetto.nome, SUM(attivitaprogetto.oredurata) AS oreDedicate FROM persona
INNER JOIN attivitaprogetto ON attivitaprogetto.persona = persona.id
INNER JOIN progetto ON attivitaprogetto.progetto = progetto.id
WHERE persona.nome = 'Ginevra' AND persona.cognome = 'Riva'
GROUP BY progetto.id, progetto.nome;

"10. Qual è il nome dei progetti su cui lavorano più di due strutturati?"
SELECT progetto.id, progetto.nome FROM attivitaprogetto
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
GROUP BY progetto.id, progetto.nome
HAVING COUNT(attivitaprogetto.persona) >= 2;

"11. Quali sono i professori associati che hanno lavorato su più di un progetto?"
SELECT persona.id, persona.nome, persona.cognome, COUNT(attivitaprogetto.persona) AS numeroProgetti FROM persona
INNER JOIN attivitaprogetto ON attivitaprogetto.persona = persona.id
WHERE persona.posizione = 'Professore Associato'
GROUP BY persona.id, persona.nome, persona.cognome;
