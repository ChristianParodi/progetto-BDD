-- dato un volontario (id = 1) otteniamo il numero di turni a cui e' assegnato
-- dopodiche', inseriamo un nuovo turno e lo assegnamo al dato volontario,
-- infine ricalcoliamo il dato
BEGIN
      SERIALIZABLE;

      SELECT v.id AS id_volontario, COUNT(*) AS n_turni
      FROM volontari v
      JOIN volontari_turni vt ON vt.volontario = v.id
      GROUP BY v.id;
 
      -- Assegnamo un nuovo turno al volontario
      INSERT INTO volontari_turni(volontario, turno) VALUES
                  (1, 1000);

      SELECT v.id AS id_volontario, COUNT(*) AS n_turni
      FROM volontari v
      JOIN volontari_turni vt ON vt.volontario = v.id
      GROUP BY v.id;
END;