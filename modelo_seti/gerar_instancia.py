import sys
import csv
import pprint
import random

def get_tipo(name):
    if name == "Palestra":
        return 0
    elif name == "Minicurso":
        return 1
    return -1
        

input_schedule = "./datafiles/seti_for_real.txt"
input_name = sys.argv[1]
output_data = sys.argv[2]
output_instance = sys.argv[3]

input_file = csv.DictReader(open(input_name))

apresentacoes = []
for row in input_file:
    apresentacoes.append(dict(row))

# pprint.pprint(apresentacoes)

count = 1
schedules_dict = {}
with open(input_schedule) as file_schedules:
    linhas = file_schedules.readlines()
    print(linhas)
    for i in range(len(linhas)):
        linhas[i] = linhas[i].strip().split(" ")
        data = linhas[i][2] + "/" + linhas[i][3] + "/" + linhas[i][4] + " " + linhas[i][5] + ":" + linhas[i][6]
        tipo = linhas[i][-1]
        print(tipo)
        if (data, int(tipo)) not in schedules_dict:
            schedules_dict[(data, int(tipo))] = count
            count += 1
    # print(linhas)

print(schedules_dict)


palestras = set()
palestrantes = set()
horarios_palestrante = {}
temas = set()
tipos = set()
for i, apresentacao in enumerate(apresentacoes):
    palestras.add(apresentacao["Titulo"])
    

    ps = apresentacao["Palestrante"].split("-")
    print(apresentacao)
    print(ps)
    for p in ps:
        print(p)
        palestrantes.add(p)
        tipo_id = get_tipo(apresentacao["Tipo"])
        if(p in horarios_palestrante):
            horarios_palestrante[p].append(schedules_dict[(apresentacao["Dia"] + " " + apresentacao["Hora"], tipo_id)])
        else:
            horarios_palestrante[p] = [schedules_dict[(apresentacao["Dia"] + " " + apresentacao["Hora"], tipo_id)]]
    ts = apresentacao["Temas"].split("-")
    for t in ts:
        temas.add(t)
    tipos.add(apresentacao["Tipo"])
    

# print(palestrantes)
# for p in palestrantes:
#     print(p)
# print(len(palestrantes))
# print(palestrantes)
# print(temas)
text_data = ""

dict_palestrantes = {}
text_data += str(len(palestrantes)) + "\n"
for i, palestrante in enumerate(palestrantes):
    text_data += str(i) + " " + palestrante + "\n"
    dict_palestrantes[palestrante] = (i, horarios_palestrante[palestrante])

text_data += str(len(temas)) + "\n"
dict_temas = {}
for i, tema in enumerate(temas):
    text_data += str(i) + " " + tema + "\n"
    dict_temas[tema] = i

text_data += str(len(palestras)) + "\n"
dict_palestras = {}
for i, palestra in enumerate(palestras):
    text_data += str(i) + " " + palestra + "\n"
    dict_palestras[palestra] = i

text_data += str(len(tipos)) + "\n"
dict_tipos = {}
for tipo in tipos:
    if(tipo == "Palestra"):
        dict_tipos["Palestra"] = 0
        text_data += str(0) + " " + tipo + "\n"
    if(tipo == "Minicurso"):
        dict_tipos["Minicurso"] = 1
        text_data += str(1) + " " + tipo + "\n"

print("\n\n\n")

print("\n\n\n")

print(schedules_dict)

print("\n\n\n")

# print(text_data)
with open(output_data, "w") as out:
    out.write(text_data)

text_instance = ""

text_instance += str(len(dict_temas)) + "\n"
text_instance += str(len(dict_palestrantes)) + "\n"

for index, palestrante in enumerate(dict_palestrantes):

    horarios = dict_palestrantes[palestrante][1]
    for i in range(10):
        r = random.randint(0,len(schedules_dict)-1)
        if(r not in horarios):
            horarios.append(r)
    # print(horarios)
    text_instance += str(len(horarios))
    for h in horarios:
        text_instance += " " + str(h)
    text_instance += "\n"

text_instance += str(len(dict_palestras)) + "\n"

for index, palestra in enumerate(dict_palestras):
    temas_palestra = apresentacoes[index]["Temas"].split("-")
    text_instance += str(len(temas_palestra)) + " "
    for tema in temas_palestra:
        t_index = dict_temas[tema]
        text_instance += str(t_index) + " "
    
    palestrantes_palestra = apresentacoes[index]["Palestrante"].split("-")
    # print(palestrantes_palestra)
    text_instance += str(len(palestrantes_palestra)) + " "
    for palestrante in palestrantes_palestra:
        p_index = dict_palestrantes[palestrante][0]
        text_instance += str(p_index) + " "
    
    
    text_instance += str(dict_tipos[apresentacoes[index]["Tipo"]])
    text_instance += "\n"

with open(input_schedule, "r") as in_file:
    data = in_file.read()
    n_linhas = len(data.splitlines())
    text_instance += str(n_linhas) + "\n" + data + "\n"

print(text_instance)
with open(output_instance, "w") as out:
    out.write(text_instance)