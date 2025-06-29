SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Quali sono i cognomi distinti di tutti gli strutturati?"
SELECT DISTINCT cognome FROM persona;

"2. Quali sono i Ricercatori (con nome e cognome)?"
SELECT nome, cognome FROM persona p
WHERE posizione = 'Ricercatore';

"3. Quali sono i Professori Associati il cui cognome comincia con la lettera 'V'?"
SELECT * FROM persona
WHERE posizione = 'Professore Associato'
    AND cognome LIKE 'V%';

"4. Quali sono i Professori (sia Associati che Ordinari) il cui cognome comincia con la
lettera 'V'?"
SELECT * FROM persona
WHERE posizione IN ('Professore Associato', 'Professore Ordinario')
    AND cognome LIKE 'V%';

"5. Quali sono i Progetti già terminati alla data odierna?"
--In teoria è cosi, ma non combacia con il risultato
SELECT * FROM progetto
WHERE fine = CURRENT_DATE; --CURRENT_DATE = Data odierna 

"6. Quali sono i nomi di tutti i Progetti ordinati in ordine crescente di data di inizio?"
SELECT nome FROM progetto
ORDER BY inizio;

"7. Quali sono i nomi dei WP ordinati in ordine crescente (per nome)?"
SELECT nome FROM WP
ORDER BY nome;

"8. Quali sono (distinte) le cause di assenza di tutti gli strutturati?"
SELECT DISTINCT tipo FROM assenza;

"9. Quali sono (distinte) le tipologie di attività di progetto di tutti gli strutturati?"
SELECT DISTINCT tipo FROM attivitaprogetto;

"10. Quali sono i giorni distinti nei quali del personale ha effettuato attività non progettuali
di tipo 'Didattica'? Dare il risultato in ordine crescente."
SELECT DISTINCT giorno FROM attivitanonprogettuale
WHERE tipo = 'Didattica';
