SELECT * FROM persona;

SELECT * FROM progetto;

SELECT * FROM WP;

SELECT * FROM assenza;

SELECT * FROM attivitaprogetto;

SELECT * FROM attivitanonprogettuale;

"1. Qual è media e deviazione standard degli stipendi per ogni categoria di strutturati?"
SELECT persona.posizione, AVG(stipendio)::NUMERIC(10, 2) AS media, STDDEV(stipendio)::NUMERIC(10, 2) AS deviazione_standard FROM persona
GROUP BY persona.posizione;

"2. Quali sono i ricercatori (tutti gli attributi) con uno stipendio superiore alla media
della loro categoria?"
WITH ricercatori_media AS (
  SELECT (SUM(stipendio) / COUNT(stipendio)) AS media_ric FROM persona
  WHERE posizione = 'Ricercatore'
)
SELECT persona.* FROM persona
INNER JOIN ricercatori_media ON persona.posizione = persona.posizione
WHERE posizione = 'Ricercatore' AND persona.stipendio > ricercatori_media.media_ric;

WITH ricercatori_media AS (
  SELECT (SUM(stipendio) / COUNT(stipendio)) AS media_ric FROM persona
  WHERE posizione = 'Ricercatore'
)
SELECT persona.* FROM persona
CROSS JOIN ricercatori_media
WHERE posizione = 'Ricercatore' AND persona.stipendio > ricercatori_media.media_ric;

"3. Per ogni categoria di strutturati quante sono le persone con uno stipendio che
differisce di al massimo una deviazione standard dalla media della loro categoria?"
-- CG
WITH deviazione_standard_posizione AS (
  SELECT posizione, AVG(stipendio)::NUMERIC(10, 2) AS media_stipendio, STDDEV(stipendio)::NUMERIC(10, 2) AS deviazione_standard FROM persona
  GROUP BY posizione 
),
persone_deviazione_standard AS (
  SELECT persona.posizione, id, stipendio, deviazione_standard_posizione.media_stipendio, deviazione_standard_posizione.deviazione_standard,
  CASE
    WHEN stipendio BETWEEN (deviazione_standard_posizione.media_stipendio - deviazione_standard_posizione.deviazione_standard)
    AND (deviazione_standard_posizione.media_stipendio + deviazione_standard_posizione.deviazione_standard)
    THEN 1 ELSE 0 END AS persone_in_range
  FROM persona
  INNER JOIN deviazione_standard_posizione ON persona.posizione = deviazione_standard_posizione.posizione
)
SELECT posizione, COUNT(id) FROM persone_deviazione_standard
WHERE persone_in_range = 1
GROUP BY posizione;

"4. Chi sono gli strutturati che hanno lavorato almeno 20 ore complessive in attività
progettuali? Restituire tutti i loro dati e il numero di ore lavorate."
SELECT persona.id, persona.nome, persona.cognome, SUM(attivitaprogetto.oredurata) AS ore_complessive FROM attivitaprogetto
INNER JOIN persona ON persona.id = attivitaprogetto.persona
GROUP BY persona.id, persona.nome, persona.cognome
HAVING SUM(attivitaprogetto.oredurata) > 20;

"5. Quali sono i progetti la cui durata è superiore alla media delle durate di tutti i
progetti? Restituire nome dei progetti e loro durata in giorni."
WITH durata_media_progetti AS (
  SELECT (SUM(fine - inizio) / COUNT(fine)) AS media_progetti FROM progetto
)
SELECT progetto.id, progetto.nome, (fine - inizio) AS durata_in_giorni FROM progetto
CROSS JOIN durata_media_progetti 
WHERE (fine - inizio) > durata_media_progetti.media_progetti;

"6. Quali sono i progetti terminati in data odierna che hanno avuto attività di tipo
“Dimostrazione”? Restituire nome di ogni progetto e il numero complessivo delle
ore dedicate a tali attività nel progetto."
SELECT progetto.id, progetto.nome, SUM(oredurata) AS ore_dimostrazione FROM attivitaprogetto
INNER JOIN progetto ON progetto.id = attivitaprogetto.progetto
WHERE tipo = 'Dimostrazione'
GROUP BY progetto.id, progetto.nome;

"7. Quali sono i professori ordinari che hanno fatto più assenze per malattia del numero
di assenze medio per malattia dei professori associati? Restituire id, nome e
cognome del professore e il numero di giorni di assenza per malattia."
-- Le prime due forse non sono corette per come ho scritto assenza_media_malattia

-- Prima soluzione
WITH assenze_malattia_professori_associati AS (
  SELECT persona.posizione, (COUNT(giorno) / COUNT(persona.posizione)) AS assenza_media_malattia FROM assenza
  INNER JOIN persona ON persona.id = assenza.persona
  WHERE persona.posizione = 'Professore Associato' AND assenza.tipo = 'Malattia'
  GROUP BY persona.posizione
)
SELECT persona.id, persona.nome, persona.cognome, COUNT(giorno) AS assenza_per_id_malattia FROM assenza
INNER JOIN persona ON persona.id = assenza.persona
INNER JOIN assenze_malattia_professori_associati ON persona.posizione = persona.posizione
WHERE persona.posizione = 'Professore Ordinario' AND assenza.tipo = 'Malattia'
GROUP BY persona.posizione, persona.id, assenza_media_malattia
HAVING COUNT(giorno) > assenza_media_malattia;

-- Seconda soluzione con il CROSS JOIN (forse è anche meglio)
WITH assenze_malattia_professori_associati AS (
  SELECT persona.posizione, (COUNT(giorno) / COUNT(persona.posizione)) AS assenza_media_malattia FROM assenza
  INNER JOIN persona ON persona.id = assenza.persona
  WHERE persona.posizione = 'Professore Associato' AND assenza.tipo = 'Malattia'
  GROUP BY persona.posizione
)
SELECT persona.id, persona.nome, persona.cognome, COUNT(giorno) AS assenza_per_id_malattia FROM assenza
INNER JOIN persona ON persona.id = assenza.persona
CROSS JOIN assenze_malattia_professori_associati
WHERE persona.posizione = 'Professore Ordinario' AND assenza.tipo = 'Malattia'
GROUP BY persona.posizione, persona.id, assenza_media_malattia
HAVING COUNT(giorno) > assenza_media_malattia;

-- Terza soluzione con il CROSS JOIN e assenza_media_malattia modificato (in teoria dovrebbe essere coretto)
WITH assenze_malattia_professori_associati AS (
  SELECT persona.posizione, (COUNT(giorno) / COUNT(DISTINCT persona.id)) AS assenza_media_malattia FROM assenza
  INNER JOIN persona ON persona.id = assenza.persona
  WHERE persona.posizione = 'Professore Associato' AND assenza.tipo = 'Malattia'
  GROUP BY persona.posizione
)
SELECT persona.id, persona.nome, persona.cognome, COUNT(giorno) AS assenza_per_id_malattia FROM assenza
INNER JOIN persona ON persona.id = assenza.persona
CROSS JOIN assenze_malattia_professori_associati
WHERE persona.posizione = 'Professore Ordinario' AND assenza.tipo = 'Malattia'
GROUP BY persona.posizione, persona.id, assenza_media_malattia
HAVING COUNT(giorno) > assenza_media_malattia;