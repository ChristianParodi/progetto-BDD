from datetime import date
from nis import match
from faker import Faker
from faker.providers import person, date_time, lorem, company
import random
from dateutil.relativedelta import relativedelta
from datetime import datetime

# MANCA LA FASCIA D'ETA'

from codice_fiscale.main import gen_fiscal_code, gen_p_iva, gen_phone_number, gen_email

fake = Faker('it_IT')
fake.add_provider(person)
fake.add_provider(date_time)
fake.add_provider(lorem)
fake.add_provider(company)

enti = ["Servizi sociali", "centro ascolto"]
cf = []
with open("codice_fiscale/codici_fiscali.txt", "r") as cf_file:
    for line in cf_file:
        cf.append(line[:-1])  # togliendo lo \n

N = 800
'''
    L'idea dietro questo script e' di creare un file SQL in cui, per ogni
    tabella, ci sara' la corrispettiva INSERT con i vari dati fake
'''

with open("generation.sql", "w") as file:
    file.write("SET search_path TO 'social_market';\n\n")
    file.write('''
    BEGIN;
    -- clienti
    INSERT INTO clienti VALUES\n\t''')

    # Clienti
    clienti = []
    for i in range(N):
        current_cf = cf.pop()
        date_auth = fake.date_between('-6M', 'today')
        scad_auth = date_auth + relativedelta(months=6)

        date_auth = str(date_auth)
        scad_auth = str(scad_auth)

        punti_mensili = random.choice([i for i in range(30, 61)])
        saldo_punti = random.choice([i for i in range(0, punti_mensili + 1)])

        clienti.append(
            (i + 1, fake.first_name(), fake.last_name(), str(fake.date_of_birth(
                minimum_age=18, maximum_age=60)), random.choice(enti), date_auth, scad_auth,
             punti_mensili, saldo_punti, current_cf, random.randint(1, 10), 'true')
        )

    for i in range(len(clienti)):
        if i != len(clienti) - 1:
            file.write(str(clienti[i]) + ',\n\t')
        else:
            file.write(str(clienti[i]) + ";\n\n")

    # Familiari
    # NOTA: e' necessario andare a prendere tutti i clienti inseriti e controllare il loro numero di familiari prima di inserirli
    file.write('''
    -- familiari
    INSERT INTO familiari VALUES\n\t''')
    familiari = []
    cf = gen_fiscal_code(unique=True, n=N)
    fasce_eta = [
        "0-5 anni",
        "6-10 anni",
        "11-15 anni",
        "16-20 anni",
        "21-30 anni",
        "31-40 anni",
        "41-50 anni",
        "51-60 anni",
        "60+ anni"
    ]

    for i in range(N):
        for parent in range(clienti[i][-2]):  # n_componenti_nucleo
            date_of_birth = fake.date_of_birth(maximum_age=60)
            today = date.today()
            age = today.year - date_of_birth.year - \
                ((today.month, today.day) < (date_of_birth.month, date_of_birth.day))

            if 0 < age < 5:
                current_fascia = fasce_eta[0]
            elif 6 < age < 10:
                current_fascia = fasce_eta[1]
            elif 11 < age < 15:
                current_fascia = fasce_eta[2]
            elif 16 < age < 20:
                current_fascia = fasce_eta[3]
            elif 21 < age < 30:
                current_fascia = fasce_eta[4]
            elif 31 < age < 40:
                current_fascia = fasce_eta[5]
            elif 41 < age < 50:
                current_fascia = fasce_eta[6]
            elif 51 < age < 60:
                current_fascia = fasce_eta[7]
            else:
                current_fascia = fasce_eta[8]

            familiari.append(
                (gen_fiscal_code(), fake.first_name(), fake.last_name(),
                 str(date_of_birth), current_fascia, 'true' if age > 16 else 'false', fake.word(), clienti[i][0])
            )

    for i in range(len(familiari)):
        if i != len(familiari) - 1:
            file.write(str(familiari[i]) + ',\n\t')
        else:
            file.write(str(familiari[i]) + ";\n\n")

    # Telefoni
    file.write('''
    -- telefoni
    INSERT INTO telefoni VALUES\n\t''')
    telefoni = []
    for i in range(N):
        telefoni.append((gen_phone_number(), clienti[i][0]))

    for _ in range(N):
        telefoni.append((gen_phone_number(), random.choice(clienti)[0]))

    for i in range(len(telefoni)):
        if i != len(telefoni) - 1:
            file.write(str(telefoni[i]) + ',\n\t')
        else:
            file.write(str(telefoni[i]) + ";\n\n")

    # email
    file.write('''
    -- email
    INSERT INTO email VALUES\n\t''')
    email = []
    for i in range(N):
        current = gen_email()
        email.append((current, clienti[i][0]))

    # aggiungiamo qualche mail a caso
    for _ in range(N):
        current = gen_email()
        email.append((current, random.choice(clienti)[0]))

    for i in range(len(email)):
        if i != len(email) - 1:
            file.write(str(email[i]) + ',\n\t')
        else:
            file.write(str(email[i]) + ";\n\n")

    # volontari
    file.write('''
    -- volontari
    INSERT INTO volontari VALUES\n\t''')
    volontari = []
    for i in range(N):
        volontari.append(
            (i + 1, fake.first_name(), fake.last_name(), str(fake.date_of_birth(maximum_age=70)),
             gen_phone_number(), gen_email())
        )

    for i in range(len(volontari)):
        if i != len(volontari) - 1:
            file.write(str(volontari[i]) + ',\n\t')
        else:
            file.write(str(volontari[i]) + ";\n\n")

    # fasce orarie
    file.write('''
    -- fasce orarie
    INSERT INTO fasce_orarie VALUES\n\t''')
    disponibilita = [
        ("lunedì", "08:00:00", "12:00:00"),
        ("lunedì", "12:00:00", "18:00:00"),
        ("martedì", "08:00:00", "12:00:00"),
        ("martedì", "12:00:00", "18:00:00"),
        ("mercoledì", "08:00:00", "12:00:00"),
        ("mercoledì", "12:00:00", "18:00:00"),
        ("giovedì", "08:00:00", "12:00:00"),
        ("giovedì", "12:00:00", "18:00:00"),
        ("venerdì", "08:00:00", "12:00:00"),
        ("venerdì", "12:00:00", "18:00:00"),
        ("sabato", "08:00:00", "12:00:00"),
        ("sabato", "12:00:00", "18:00:00"),
        ("domenica", "08:00:00", "12:00:00"),
        ("domenica", "12:00:00", "18:00:00"),
    ]
    fasce_orarie = []

    for i in range(len(disponibilita)):
        fasce_orarie.append(
            (i + 1, disponibilita[i][0],
             disponibilita[i][1], disponibilita[i][2])
        )

    for i in range(len(fasce_orarie)):
        if i != len(fasce_orarie) - 1:
            file.write(str(fasce_orarie[i]) + ',\n\t')
        else:
            file.write(str(fasce_orarie[i]) + ";\n\n")

    # appuntamenti
    file.write('''
    -- appuntamenti
    INSERT INTO appuntamenti VALUES\n\t''')
    appuntamenti = []
    # si differenziano di 15 minuti e durano 5 minuti
    date_times = [fake.future_datetime()]

    for i in range(N):
        date_times.append(date_times[i] + relativedelta(minutes=20))

    # 'YYYY-mm-aa hh:mm:ss -> ['YYYY-mm-aa', 'hh:mm:ss']
    for i in date_times:
        i = str(i)
        i = (i.split()[0], i.split()[1])

    for i in range(N):
        while date_times.count(date_times[i]) > 1:
            date_times[i] = (str(fake.future_date()), fake.time())

    for i in range(N):
        saldo_iniziale = random.choice([i for i in range(30, 61)])
        saldo_finale = random.choice([i for i in range(saldo_iniziale)])
        cliente = random.choice(clienti)[0]
        current_familiari = [j[0]
                             for j in familiari if familiari[-1] == cliente]
        current_familiari.append("NULL")
        familiare = random.choice(current_familiari)

        appuntamenti.append(
            (i + 1, str(date_times[i]).split()[0], str(date_times[i]).split()[1], fake.word(), saldo_iniziale,
             saldo_finale, cliente, random.choice(volontari)[0], familiare)
        )

    for i in range(len(appuntamenti)):
        if i != len(appuntamenti) - 1:
            file.write(str(appuntamenti[i]) + ',\n\t')
        else:
            file.write(str(appuntamenti[i]) + ";\n\n")

    # scorte
    file.write('''
    -- scorte
    INSERT INTO scorte VALUES\n\t''')
    scorte = [
        (1, 'Tonno', 'Rio Mare', 6, random.randint(50, 600)),
        (2, 'Tonno', 'Insuperabile', 3, random.randint(50, 600)),
        (3, 'Tonno', 'Nostromo', 5, random.randint(50, 600)),
        (4, 'Shampoo', 'Garnier', 6, random.randint(50, 600)),
        (5, 'Shampoo', 'Testanera', 1, random.randint(50, 600)),
        (6, 'Shampoo', 'L Oreal', 4, random.randint(50, 600)),
        (7, 'Pasta', 'De Cecco', 0.89, random.randint(50, 600)),
        (8, 'Pasta', 'Barilla', 0.89, random.randint(50, 600)),
        (9, 'Pasta', 'Italiamo', 1.24, random.randint(50, 600)),
        (10, 'Pollo', 'petto', 5, random.randint(50, 600)),
        (11, 'Vitello', 'fettina', 5, random.randint(50, 600)),
        (12, 'Maiale', 'braciole', 7, random.randint(50, 600)),
        (13, 'Maiale', 'coppa', 8, random.randint(50, 600)),
        (14, 'Maiale', 'Salsicce', 3, random.randint(50, 600)),
        (15, 'Vitello', 'Salsicce', 4, random.randint(50, 600)),
        (16, 'Biscotti', 'Batticuori', 3, random.randint(50, 600)),
        (17, 'Biscotti', 'Pan di stelle', 3, random.randint(50, 600)),
        (18, 'Biscotti', 'Gocciole', 2, random.randint(50, 600)),
        (19, 'Deodorante', 'Nivea', 3, random.randint(50, 600)),
        (20, 'Deodorante', 'Borotalco', 6, random.randint(50, 600))
    ]

    for i in range(len(scorte)):
        if i != len(scorte) - 1:
            file.write(str(scorte[i]) + ',\n\t')
        else:
            file.write(str(scorte[i]) + ";\n\n")

    # scarichi
    file.write('''
    -- scarichi
    INSERT INTO scarichi VALUES\n\t''')
    scarichi = []
    dates = [fake.future_datetime() for _ in range(N)]

    for i in range(N):
        while dates.count(dates[i]) > 1:
            dates[i] = fake.future_datetime()

    for i in range(N):
        scarichi.append(
            (str(dates[i]).split()[0],
             str(dates[i]).split()[1], random.choice(volontari)[0])
        )

    for i in range(len(scarichi)):
        if i != len(scarichi) - 1:
            file.write(str(scarichi[i]) + ',\n\t')
        else:
            file.write(str(scarichi[i]) + ";\n\n")

    # ingresso_prodotti
    file.write('''
    -- ingresso_prodotti
    INSERT INTO ingresso_prodotti VALUES\n\t''')
    ingresso_prodotti = []
    dates = [fake.future_datetime() for _ in range(N)]

    for i in range(N):
        while dates.count(dates[i]) > 1:
            dates[i] = fake.future_datetime()
    for i in range(N):
        scelte = ['NULL', random.randint(1, 200) + random.random()]
        ingresso_prodotti.append(
            (i + 1, str(dates[i]).split()[0], str(dates[i]).split()
             [1], random.choice(scelte))
        )
    for i in range(len(ingresso_prodotti)):
        if i != len(ingresso_prodotti) - 1:
            file.write(str(ingresso_prodotti[i]) + ',\n\t')
        else:
            file.write(str(ingresso_prodotti[i]) + ";\n\n")

    # prodotti
    file.write('''
    -- prodotti
    INSERT INTO prodotti VALUES\n\t''')
    prodotti = []
    k = 1
    for i in range(len(scorte)):
        for j in range(scorte[i][-1]):
            scad = fake.future_date()
            real_scad = scad + relativedelta(months=10)
            scarico = random.choice(scarichi)
            prodotti.append(
                (k, str(scad), str(real_scad), scorte[i][0],
                 random.choice(ingresso_prodotti)[0], scarico[0], scarico[1],
                 'true' if datetime.strptime(scarico[0], "%Y-%m-%d").date() <= date.today() else 'false')
            )
            k += 1

    for i in range(len(prodotti)):
        if i != len(prodotti) - 1:
            file.write(str(prodotti[i]) + ',\n\t')
        else:
            file.write(str(prodotti[i]) + ";\n\n")
    # associazioni
    file.write('''
    -- associazioni
    INSERT INTO associazioni VALUES\n\t''')
    associazioni = []
    for i in range(30):
        associazioni.append(
            fake.company()
        )

    for i in range(len(associazioni)):
        if i != len(associazioni) - 1:
            file.write(f"('{associazioni[i]}')" + ',\n\t')
        else:
            file.write(f"('{associazioni[i]}')" + ";\n\n")

    # servizi
    file.write('''
    -- servizi
    INSERT INTO servizi VALUES\n\t''')
    servizi = []
    names = [
        'Riordino prodotti',
        'Accoglienza clienti',
        'Stoccaggio prodotti magazzino',
        'Trasporto donazioni'
    ]

    for i in range(len(names) - 1):
        servizi.append(
            (i + 1, names[i])
        )

    for i in range(len(servizi)):
        if i != len(servizi) - 1:
            file.write(str(servizi[i]) + ',\n\t')
        else:
            file.write(str(servizi[i]) + ";\n\n")
    # turni
    file.write('''
    -- turni
    INSERT INTO turni VALUES\n\t''')
    turni = []
    for i in range(N):
        ora_inizio = fake.time()
        ora_fine = datetime.strptime(
            ora_inizio, '%H:%M:%S') + relativedelta(hours=5)

        turni.append(
            (i + 1, str(fake.future_date()),
             str(ora_inizio), str(ora_fine).split()[1])
        )

    for i in range(len(turni)):
        if i != len(turni) - 1:
            file.write(str(turni[i]) + ',\n\t')
        else:
            file.write(str(turni[i]) + ";\n\n")
    # turno_trasporti
    file.write('''
    -- turni_trasporti
    INSERT INTO turni_trasporti VALUES\n\t''')
    turni_trasporti = []
    id_turni = [i[0] for i in turni]

    for i in range(N):
        while id_turni.count(id_turni[i]) > 1:
            id_turni[i] = random.choice(turni_trasporti)[0]

    veicoli = [
        "Furgone",
        "Automobile",
        "Camion",
    ]

    for i in range(N):
        ora = fake.time()

        turni_trasporti.append(
            (id_turni[i], random.choice(volontari)[
             0], str(ora), random.randint(1, 10), fake.company(), random.choice(veicoli))
        )

    for i in range(len(turni_trasporti)):
        if i != len(turni_trasporti) - 1:
            file.write(str(turni_trasporti[i]) + ',\n\t')
        else:
            file.write(str(turni_trasporti[i]) + ";\n\n")
    # donatori
    file.write('''
    -- donatori
    INSERT INTO donatori VALUES\n\t''')
    donatori = []
    tipologia = [
        "privato",
        "negozio",
        "associazione"
    ]
    for i in range(N):
        donatori.append(
            (i + 1, gen_phone_number(), gen_email(), random.choice(tipologia))
        )

    for i in range(len(donatori)):
        if i != len(donatori) - 1:
            file.write(str(donatori[i]) + ',\n\t')
        else:
            file.write(str(donatori[i]) + ";\n\n")
    # donatori privati
    file.write('''
    -- donatori_privati
    INSERT INTO donatori_privati VALUES\n\t''')
    donatori_privati = []
    id_privati = [i[0] for i in donatori if i[-1] == 'privato']

    for i in range(len(id_privati)):
        donatori_privati.append(
            (id_privati[i], fake.first_name(),
             fake.last_name(), str(fake.date_of_birth()), gen_fiscal_code())
        )

    for i in range(len(donatori_privati)):
        if i != len(donatori_privati) - 1:
            file.write(str(donatori_privati[i]) + ',\n\t')
        else:
            file.write(str(donatori_privati[i]) + ";\n\n")
    # donatori negozi
    file.write('''
    -- donatori_negozi
    INSERT INTO donatori_negozi VALUES\n\t''')
    donatori_negozi = []
    id_negozi = [i[0] for i in donatori if i[-1] == 'negozio']

    for i in range(len(id_negozi)):
        donatori_negozi.append(
            (id_negozi[i], fake.company(), gen_p_iva())
        )

    for i in range(len(donatori_negozi)):
        if i != len(donatori_negozi) - 1:
            file.write(str(donatori_negozi[i]) + ',\n\t')
        else:
            file.write(str(donatori_negozi[i]) + ";\n\n")
    # donatori associazioni
    file.write('''
    -- donatori_associazioni
    INSERT INTO donatori_associazioni VALUES\n\t''')
    donatori_associazioni = []
    id_associazioni = [i[0] for i in donatori if i[-1] == 'associazione']

    for i in range(len(id_associazioni)):
        donatori_associazioni.append(
            (id_associazioni[i], fake.company(), gen_p_iva())
        )

    for i in range(len(donatori_associazioni)):
        if i != len(donatori_associazioni) - 1:
            file.write(str(donatori_associazioni[i]) + ',\n\t')
        else:
            file.write(str(donatori_associazioni[i]) + ";\n\n")
    # donazioni
    file.write('''
    -- donazioni
    INSERT INTO donazioni VALUES\n\t''')
    donazioni = []
    tipologia = [
        "denaro",
        "prodotti"
    ]
    for i in range(N):
        current_tipologia = random.choice(tipologia)

        donazioni.append(
            (i + 1, current_tipologia, str(fake.date()), str(fake.time()), random.randint(1,
             2000) if current_tipologia == 'denaro' else 'NULL', random.choice(donatori)[0])
        )

    for i in range(len(donazioni)):
        if i != len(donazioni) - 1:
            file.write(str(donazioni[i]) + ',\n\t')
        else:
            file.write(str(donazioni[i]) + ";\n\n")
    # donazioni_prodotti
    file.write('''
    -- donazioni_prodotti
    INSERT INTO donazioni_prodotti VALUES\n\t''')
    donazioni_prodotti = []
    id_donazioni = [i[0] for i in donazioni if i[1] == 'prodotti']
    id_ingressi_donazioni = [i[0]
                             for i in ingresso_prodotti if i[-1] == 'NULL']

    for i in range(len(id_donazioni) // 2):
        donazioni_prodotti.append(
            (id_donazioni[i], random.choice(donatori_privati)
             [0], 'NULL', id_ingressi_donazioni[i])
        )

    for i in range(len(id_donazioni) // 2, len(id_donazioni)):
        donazioni_prodotti.append(
            (id_donazioni[i], 'NULL', random.choice(turni_trasporti)[
             0], random.choice(ingresso_prodotti)[0])
        )
    for i in range(len(donazioni_prodotti)):
        if i != len(donazioni_prodotti) - 1:
            file.write(str(donazioni_prodotti[i]) + ',\n\t')
        else:
            file.write(str(donazioni_prodotti[i]) + ";\n\n")

    # associazioni (n, n)
    # prodotti_appuntamenti
    file.write('''
    -- appuntamenti_prodotti
    INSERT INTO appuntamenti_prodotti VALUES\n\t''')
    appuntamenti_prodotti = []
    id_prodotto = [prodotti[i][0] for i in range(len(prodotti)//2)]
    for i in range(N):
        appuntamenti_prodotti.append(
            (id_prodotto[i], random.choice(appuntamenti)[0])
        )

    for i in range(N):
        while appuntamenti_prodotti.count(appuntamenti_prodotti[i]) > 1:
            appuntamenti_prodotti[i] = (random.choice(
                prodotti)[0], random.choice(appuntamenti)[0])

    for i in range(len(appuntamenti_prodotti)):
        if i != len(appuntamenti_prodotti) - 1:
            file.write(str(appuntamenti_prodotti[i]) + ',\n\t')
        else:
            file.write(str(appuntamenti_prodotti[i]) + ";\n\n")
    # volontari_associazioni
    file.write('''
    -- volontari_associazioni
    INSERT INTO volontari_associazioni VALUES\n\t''')
    volontari_associazioni = []
    for i in range(N):
        volontari_associazioni.append(
            (random.choice(volontari)[0], random.choice(associazioni))
        )

    for i in range(N):
        while volontari_associazioni.count(volontari_associazioni[i]) > 1:
            volontari_associazioni[i] = (random.choice(
                volontari)[0], random.choice(associazioni))

    for i in range(len(volontari_associazioni)):
        if i != len(volontari_associazioni) - 1:
            file.write(str(volontari_associazioni[i]) + ',\n\t')
        else:
            file.write(str(volontari_associazioni[i]) + ";\n\n")
    # volontari_turni
    file.write('''
    -- volontari_turni
    INSERT INTO volontari_turni VALUES\n\t''')
    volontari_turni = []
    for i in range(N):
        volontari_turni.append(
            (random.choice(volontari)[0], random.choice(turni)[0])
        )

    for i in range(N):
        while volontari_turni.count(volontari_turni[i]) > 1:
            volontari_turni[i] = (random.choice(
                volontari)[0], random.choice(turni)[0])

    for i in range(len(volontari_turni)):
        if i != len(volontari_turni) - 1:
            file.write(str(volontari_turni[i]) + ',\n\t')
        else:
            file.write(str(volontari_turni[i]) + ";\n\n")

    # volontari_servizi
    file.write('''
    -- volontari_servizi
    INSERT INTO volontari_servizi VALUES\n\t''')
    volontari_servizi = []
    for i in range(N):
        volontari_servizi.append(
            (random.choice(volontari)[0], random.choice(servizi)[0])
        )

    for i in range(N):
        while volontari_servizi.count(volontari_servizi[i]) > 1:
            volontari_servizi[i] = (random.choice(
                volontari)[0], random.choice(servizi)[0])

    for i in range(len(volontari_servizi)):
        if i != len(volontari_servizi) - 1:
            file.write(str(volontari_servizi[i]) + ',\n\t')
        else:
            file.write(str(volontari_servizi[i]) + ";\n\n")

    # volontari_fasce_orarie
    # volontari_servizi
    file.write('''
    -- volontari_fasce_orarie
    INSERT INTO volontari_fasce_orarie VALUES\n\t''')
    volontari_fasce_orarie = []
    for i in range(N):
        volontari_fasce_orarie.append(
            (random.choice(volontari)[0], random.choice(fasce_orarie)[0])
        )

    for i in range(N):
        while volontari_fasce_orarie.count(volontari_fasce_orarie[i]) > 1:
            volontari_fasce_orarie[i] = (random.choice(
                volontari)[0], random.choice(fasce_orarie)[0])

    for i in range(len(volontari_fasce_orarie)):
        if i != len(volontari_fasce_orarie) - 1:
            file.write(str(volontari_fasce_orarie[i]) + ',\n\t')
        else:
            file.write(str(volontari_fasce_orarie[i]) + ";\n\n")

    file.write("END;\n")
if __name__ == "__main__":
    pass
