Istruzioni semplici (copia e incolla) per creare le tabelle su Supabase

1) Apri il tuo progetto Supabase
   - URL: https://xpinibmjluzxnbovwgeq.supabase.co
   - (Hai già la chiave anon, non serve qui)

2) Vai su SQL
   - Clicca su SQL > New Query

3) Incolla lo schema
   - Apri il file supabase/schema.sql di questo progetto
   - Copia tutto il contenuto e incollalo nell’editor SQL di Supabase

4) Esegui
   - Premi “RUN”
   - Vedrai create le tabelle: public.bonuses e public.user_bonus_progress con le relative policy RLS

5) (Opzionale) Dati di esempio
   - Lo script inserisce 2 bonus di esempio. Puoi modificarli/eliminarli.

6) Verifica
   - Table Editor > bonuses: dovresti vedere i record
   - Table Editor > user_bonus_progress: inizialmente vuoto (si riempirà quando l’utente farà progressi)

7) Collegamento app
   - In lib/main.dart abbiamo già impostato:
     - url: https://xpinibmjluzxnbovwgeq.supabase.co
     - anonKey: la tua anon key
   - Avvia l’app e accedi/registrati:
     - Registrazione: invierà email di conferma (dipende dalle impostazioni di autenticazione del progetto)
     - Una volta autenticato, la Dashboard leggerà i bonus e salverà i progressi su user_bonus_progress

Note
- Le policy RLS permettono di vedere/aggiornare solo i progressi del proprio utente.
- I bonus sono leggibili solo dagli utenti autenticati (policy “authenticated”). Se vuoi mostrarli anche senza login, crea una policy “to anon” per SELECT.