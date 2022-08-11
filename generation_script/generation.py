from datetime import date
from faker import Faker
from faker.providers import person, date_time, lorem
import random
from dateutil.relativedelta import relativedelta

from codice_fiscale.main import gen_fiscal_code, gen_phone_number

fake = Faker('it_IT')
fake.add_provider(person)
fake.add_provider(date_time)
fake.add_provider(lorem)

enti = ["Servizi sociali", "centro d'ascolto"]
cf = []
with open("codice_fiscale/codici_fiscali.txt", "r") as cf_file:
    for line in cf_file:
        cf.append(line[:-1])  # togliendo lo \n
N = 3
'''
    L'idea dietro questo script e' di creare un file SQL in cui, per ogni
    tabella, ci sara' la corrispettiva INSERT con i vari dati fake
'''

with open("generation.sql", "w") as file:
    file.write("SET search_path TO 'social_market';\n\n")
    file.write('''
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

        clienti.append(
            (i + 1, fake.first_name(), fake.last_name(), str(fake.date_of_birth(
                minimum_age=18, maximum_age=60)), random.choice(enti), date_auth, scad_auth,
             random.choice([i for i in range(30, 61)]), random.choice(
                [i for i in range(30, 61)]), current_cf, random.randint(0, 10), 1)
        )

    for i in range(len(clienti)):
        if i != len(clienti) - 1:
            file.write(str(clienti[i]) + ',\n\t')
        else:
            file.write(str(clienti[i]) + "\n\n")

    # Familiari
    # NOTA: e' necessario andare a prendere tutti i clienti inseriti e controllare il loro numero di familiari prima di inserirli
    file.write('''
    -- familiari
    INSERT INTO familiari VALUES\n\t''')
    familiari = []
    cf = gen_fiscal_code(unique=True, n=N)

    for i in range(N):
        for parent in range(clienti[i][-2]):  # n_componenti_nucleo
            familiari.append(
                (gen_fiscal_code(), fake.first_name(), fake.last_name(),
                 str(fake.date_of_birth(maximum_age=60)), fake.word(), clienti[i][0])
            )

    for i in range(len(familiari)):
        if i != len(familiari) - 1:
            file.write(str(familiari[i]) + ',\n\t')
        else:
            file.write(str(familiari[i]) + "\n\n")

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
            file.write(str(telefoni[i]) + "\n\n")

    # email
    file.write('''
    -- email
    INSERT INTO email VALUES\n\t''')
    email = []
    for i in range(N):
        current = fake.word() + "@gmail.com"
        email.append((current, clienti[i][0]))

    # aggiungiamo qualche mail a caso
    for _ in range(N):
        current = fake.word() + "@gmail.com"
        email.append((current, random.choice(clienti)[0]))

    for i in range(len(email)):
        if i != len(email) - 1:
            file.write(str(email[i]) + ',\n\t')
        else:
            file.write(str(email[i]) + "\n\n")

    # volontari
    file.write('''
    -- volontari
    INSERT INTO volontari VALUES\n\t''')
    volontari = []
    disponibilita = [
        "lunedi' dalle 9 alle 21",
        "lunedi' dalle 10 alle 15",
        "lunedi' dalle 17 alle 21",
        "lunedi' dalle 15 alle 17",
        "martedi' dalle 9 alle 21",
        "martedi' dalle 10 alle 15",
        "martedi' dalle 17 alle 21",
        "martedi' dalle 15 alle 17",
        "mercoledi' dalle 9 alle 21",
        "mercoledi' dalle 10 alle 15",
        "mercoledi' dalle 17 alle 21",
        "mercoledi' dalle 15 alle 17",
        "giovedi' dalle 9 alle 21",
        "giovedi' dalle 10 alle 15",
        "giovedi' dalle 17 alle 21",
        "giovedi' dalle 15 alle 17",
        "venerdi' dalle 9 alle 21",
        "venerdi' dalle 10 alle 15",
        "venerdi' dalle 17 alle 21",
        "venerdi' dalle 15 alle 17",
        "sabato' dalle 9 alle 21",
        "sabato dalle 10 alle 15",
        "sabato dalle 17 alle 21",
        "sabato dalle 15 alle 17",
        "domenica dalle 9 alle 21",
        "domenica dalle 10 alle 15",
        "domenica dalle 17 alle 21",
        "domenica dalle 15 alle 17",
    ]
    for i in range(N):
        volontari.append(
            (i + 1, fake.first_name(), fake.last_name(), str(fake.date_of_birth(maximum_age=70)),
             gen_phone_number(), fake.word() + "@gmail.com", random.choice(disponibilita))
        )

    for i in range(len(volontari)):
        if i != len(volontari) - 1:
            file.write(str(volontari[i]) + ',\n\t')
        else:
            file.write(str(volontari[i]) + "\n\n")

    # appuntamenti
    # prodotti
    # scorte
    # ingresso_prodotti
    # associazioni
    # acquisto
    # servizi
    # turni
    # turno_trasporti
    # donazioni
    # donazioni_prodotti
    # donatori
    # donatori privati
    # donatori negozi
    # donatori associazioni

    # associazioni (n, n)
if __name__ == "__main__":
    pass
