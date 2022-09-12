import random
import string


def gen_code():
    result = ""
    letters = [ch for ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    digits = [ch for ch in "0123456789"]

    for _ in range(6):
        result += random.choice(letters)
    for _ in range(2):
        result += random.choice(digits)
    result += random.choice(letters)
    for _ in range(2):
        result += random.choice(digits)
    result += random.choice(letters)
    for _ in range(3):
        result += random.choice(digits)
    result += random.choice(letters)

    return result


def gen_fiscal_code(unique=False, n=1):
    result = []
    for i in range(n):
        result.append(gen_code())
        if unique:
            while result.count(result[i]) > 1:
                result[i] = gen_code()

    return result[0] if len(result) == 1 else result


def gen_phone_number():
    digits = "0123456789"
    result = "+39"
    for _ in range(10):
        result += random.choice(digits)
    return result


def gen_phone_numbers(unique=True, n=1):
    result = []
    for _ in range(n):
        result.append(gen_phone_number())
        if unique:
            while result.count(result[i]) > 1:
                result[i] = gen_phone_number()


def gen_p_iva():
    digits = [ch for ch in '0123456789']
    result = ""
    for _ in range(16):
        result += random.choice(digits)
    return result


def gen_email(n=1, unique=True):
    chars = [ch for ch in string.ascii_uppercase + string.ascii_lowercase]
    result = []
    for _ in range(n):
        mail = ""
        for _ in range(random.randint(3, 60)):
            mail += random.choice(chars)
        mail += random.choice(["@gmail.com", "@yahoo.it",
                               "@hotmail.it", "@libero.it"])
        result.append(mail)
    return result if n > 1 else result[0]


if __name__ == "__main__":
    # creo una lista con 800 codici fiscali
    cf = [gen_fiscal_code() for _ in range(10_000)]

    with open("codici_fiscali.txt", "w") as file:
        for i in cf:
            file.write(i + "\n")
