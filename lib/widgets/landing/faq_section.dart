import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../glass_container.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _FaqItem(
        q: 'Come funziona Efallmò?',
        a:
            'Scegli un bonus, apri la guida e segui i passaggi. Al termine riceverai il bonus (e potrai tracciarne l’avanzamento nella tua Dashboard).',
      ),
      _FaqItem(
        q: 'Perché vedo “Email non confermata” quando provo ad accedere?',
        a:
            'Devi confermare la registrazione via email. Se non trovi la mail controlla lo spam. Dalla schermata di login puoi inviare di nuovo il link di conferma.',
      ),
      _FaqItem(
        q: 'Come risolvo “Credenziali non valide”?',
        a:
            'Verifica che email e password siano corrette. In caso di password dimenticata, usa la funzione di reset dalla pagina di login (se abilitata) o registrati nuovamente se non hai mai completato l’iscrizione.',
      ),
      _FaqItem(
        q: 'Devo versare un deposito?',
        a:
            'Dipende dal bonus. Alcuni richiedono un deposito minimo, spesso recuperabile al 100%. Usa il filtro “Senza deposito” nella Dashboard per trovarli rapidamente.',
      ),
      _FaqItem(
        q: 'Cosa significa “Scade il …” sui bonus?',
        a:
            'Indica la data di scadenza della promo. Se presente, è mostrata in modo evidente sulla card del bonus. Dopo la scadenza il bonus potrebbe non essere più disponibile.',
      ),
      _FaqItem(
        q: 'Posso vedere a che punto sono arrivato?',
        a:
            'Sì. Quando chiudi una guida ti chiediamo a che step ti sei fermato o se hai completato. In Dashboard vedrai il progresso e lo stato del bonus.',
      ),
      _FaqItem(
        q: 'Come funziona il bonus “Invito”?',
        a:
            'Ogni bonus può prevedere un guadagno aggiuntivo invitando amici. Trovi l’importo nella card (“Invito”) e in alto nella guida un pulsante per copiare il codice/link.',
      ),
      _FaqItem(
        q: 'Sono un admin: posso vedere l’attività degli utenti?',
        a:
            'Sì. La sezione Admin mostra chi ha iniziato un bonus, quando e se lo ha completato, con timestamp e ultimo step aggiornato.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          const Text(
            'Domande frequenti',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tutto quello che devi sapere per iniziare subito.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtleGray),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final it in items) _FaqTile(it: it),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem it;
  const _FaqTile({required this.it});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 16,
        blur: 16,
        backgroundColor: Colors.white.withOpacity(0.06),
        borderGradient: const LinearGradient(
          colors: [AppColors.brandOrange, AppColors.brandBlue],
        ),
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.it.q,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more, color: Colors.white),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      widget.it.a,
                      style: const TextStyle(
                        color: AppColors.subtleGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState:
                      _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}