import sys
import pprint
import prettytable

# checa se a apresentacao esta em exatamente uma sessao
def check_constraint_only_one(presentations_sessions, presentations):

    for i in range(len(presentations)):
        found = False
        for j in range(len(presentations_sessions[i])):

            if presentations_sessions[i][j] == 1:
                # achou a apresentacao em mais de uma sessao
                if found:
                    return (False, str(presentations_sessions[i]) + " : apresentacao " + str(i) + " alocada mais de umas vez")
                # achou uma alocacao do trabalho
                else:
                    found = True
        
        if not found:
            return (False, str(presentations_sessions[i]) + " : apresentacao " + str(i) + " não foi alocada")
    
    return (True, "ok")

def check_max_themes_in_schedule(n_themes, sessions_by_date, limit_schedule):
    for date in sessions_by_date:
        for schedule in sessions_by_date[date]:
            sessions = sessions_by_date[date][schedule]
            text = ""
            text += str(schedule) + ":\n"
            for i in range(n_themes):
                count = 0

                for session in sessions:
                    for presentation in session["presentations"]:
                        if(i in presentation["themes"]):
                            count += 1

                text += "tema " + str(i) + ": " + str(count) + " repeticoes"

                if(count > limit_schedule):
                    return (False, text)

    return (True, "ok")


def check_max_themes_in_date(n_themes, sessions_by_date, limit_date):
    for date in sessions_by_date:
        text = ""
        text += str(date) + ":\n"
        for i in range(n_themes):
            count = 0
            for schedule in sessions_by_date[date]:
                sessions = sessions_by_date[date][schedule]
                for session in sessions:
                    for presentation in session["presentations"]:
                        if(i in presentation["themes"]):
                            count += 1
                    
            text += "tema " + str(i) + ": " + str(count) + " repeticoes\n"
            if(count > limit_date):
                return (False, text)

    return (True, "ok")


def check_max_presentations_in_session(sessions):
    for session in sessions:
        if(session["capacity"] < len(session["presentations"])):
            return (False, "sessao " + str(session["id"]) + " estourou capacidade")
    return (True, "ok")
    


def check_one_presentation_schedule_per_author(sessions_by_date):
    for date in sessions_by_date:
        for schedule in sessions_by_date[date]:
            sessions = sessions_by_date[date][schedule]
            text = ""
            text += str(schedule) + ":\n"
            present_authors = set()

            for session in sessions:
                for presentation in session["presentations"]:
                    new_set = set(presentation["authors"])
                    intersect = present_authors.intersection(new_set) 
                    if(len(intersect) > 0):
                        return (False, "authors " + str(intersect) + " repeated in " + str(schedule))
                    
                    else:
                        present_authors = present_authors.union(new_set)
                    
    return (True, "ok")


def check_author_disponibility(sessions, authors):
    for session in sessions:
        for presentation in session["presentations"]:
            for a in presentation["authors"]:
                if((session["id"] + 1) not in authors[a]):
                    return (False, "author " + str(a) 
                            + " without disponibility for session " 
                            + str(session["id"]) + " (" + str(authors[a]) + ")")

    return (True, "ok")

def check_local_disponibility(sessions):
    for session in sessions:
        for presentation in session["presentations"]:
            if presentation["type"] not in session["types"]:
                return (False, "Presentation with type " 
                        + str(presentation["type"]) 
                        + " not supported by session " + str(session["id"]) 
                        + " (" + str(session["types"]) + ")")

    return (True, "ok")

def read_results(file_name):
    with open(file_name, "r") as file:
        lines = file.read().splitlines()
        schedule_capacity = int(lines[0].strip().split(":")[1])
        date_capacity = int(lines[1].strip().split(":")[1])
        time = float(lines[2].strip().split(":")[1])
        objective_value = float(lines[-1].strip().split(":")[1])
        lines = lines[3:-1]


        presentations_sessions = []
        for line in lines:
            line = line.strip().split(" ")
            new_line = []
            for v in line:
                new_line.append(int(float(v)))

            presentations_sessions.append(new_line)

    # pprint.pprint(presentations_sessions)
    return (presentations_sessions, time, objective_value, schedule_capacity, date_capacity)

def read_input(file_name, presentations_sessions):
    with open(file_name, "r") as file:
        lines = file.read().splitlines()
        n_themes = int(lines[0])
        n_authors = int(lines[1])

        start = 2
        end = n_authors + 2
        authors = {}
        for i in range(start, end):
            line = lines[i].strip().split(" ")
            authors[i-2] = [int(x) for x in line[1:]]


        start = end
        n_presentations = int(lines[start])

        start = start + 1

        end = start + n_presentations

        presentations = []
        for i in range(start, end):
            presentation = {'authors': [], 'themes': []}

            line = lines[i].strip().split(" ")

            # numero de temas daquela apresentacao
            nt = int(line[0])

            # pega os temas
            for j in range(1, nt+1):
                presentation['themes'].append(int(line[j]))
            
            
            # numero de autores daquela apresentacao
            na = int(line[nt+1])
            # print(na)

            for j in range(nt+2, nt+na+2):
                presentation['authors'].append(int(line[j]))
            p_type = int(line[nt+na+2])
            
            presentation["type"] = p_type
            presentations.append(presentation)
        
        start = end
        n_sessions = int(lines[start])
        start += 1
        end = start + n_sessions
        

        # start = n_presentations + 4
        # end = start + n_sessions
        

        sessions = []
        sessions_by_date = {}
        for i in range(start, end):
            session = {}
            line = lines[i].strip().split(" ")

            session["id"] = i-start
            session["capacity"] = int(line[0])
            session["duration"] = int(line[1])
            date = line[2] + "-" + line[3] + "-" + line[4]
            session["date"] = date
            schedule = date + " " + line[5] + ":" + line[6]
            session["schedule"] = schedule
            
            session["types"] = []
            n_types = int(line[7])
            t_start = 8
            t_end = t_start + n_types
            
            for j in range(t_start, t_end):
                session["types"].append(int(line[j]))
            
            session["presentations"] = []
            for j in range(n_presentations):
                if(presentations_sessions[j][session["id"]] == 1):
                    session["presentations"].append(presentations[j])


            sessions.append(session)

            if(date in sessions_by_date):
                if(schedule in sessions_by_date[date]):
                    sessions_by_date[date][schedule].append(session)
                else:
                    sessions_by_date[date][schedule] = []
                    sessions_by_date[date][schedule].append(session)
            else:
                sessions_by_date[date] = {}
                sessions_by_date[date][schedule] = []
                sessions_by_date[date][schedule].append(session)

        # pprint.pprint(sessions_by_date)
        # pprint.pprint(presentations)

    return (n_presentations, n_themes, n_authors, n_sessions, presentations, sessions, sessions_by_date, authors) 



if(len(sys.argv) < 3):
    print("Exemplo de execucao:")
    # print("python3 results/verifier.py <arquivo de resultados> <arquivo de entrada> <capacidade de horario> <capacidade por dia>")
    print("python3 results/verifier.py <arquivo de resultados> <arquivo de entrada>")
    exit(0)

# arquivo de resultados
res_file_name = sys.argv[1]
# print(res_file_name)

# arquivo de entrada
in_file_name = sys.argv[2]
# print(in_file_name)

# maxima capacidade de temas por horario
schedule_capacity = -1
# print(schedule_capacity)

# maxima capacidade de temas por dia
date_capacity = -1
# print(date_capacity)

presentations_sessions, time, object_value, schedule_capacity, date_capacity = read_results(res_file_name)
n_presentations, n_themes, n_authors, n_sessions, presentations, sessions, sessions_by_date, authors = read_input(in_file_name, presentations_sessions)

checks_and_messages = []
checks_and_messages.append(check_constraint_only_one(presentations_sessions, presentations))
checks_and_messages.append(check_max_themes_in_schedule(n_themes, sessions_by_date, schedule_capacity))
checks_and_messages.append(check_max_themes_in_date(n_themes, sessions_by_date, date_capacity))
checks_and_messages.append(check_max_presentations_in_session(sessions))
checks_and_messages.append(check_one_presentation_schedule_per_author(sessions_by_date))
checks_and_messages.append(check_author_disponibility(sessions, authors))
checks_and_messages.append(check_local_disponibility(sessions))

# separa as tuplas e cria duas listas: mensagens e uma lista booleana indicando se o teste passou
checks, messages = (list(t) for t in zip(*checks_and_messages))


if(all(checks)):
    out_sessions = []
    
    for j in range(len(presentations_sessions[0])):
        out_sessions.append(([], sessions[j]["date"], sessions[j]["schedule"]))
        for i in range(len(presentations_sessions)):
            if(presentations_sessions[i][j] == 1):
                out_sessions[j][0].append(i)



    table = prettytable.PrettyTable()
    table.field_names = ["Sessão", "Trabalhos", "Dia", "Horario"]

    for i in range(len(out_sessions)):
        index = i + 1
        works, date, schedule = out_sessions[i]
        text_works = str(works)[1:-1]
        text_date = "/".join(date.strip().split("-"))
        text_schedule = schedule.strip().split(" ")[1]
        table.add_row([index, text_works, text_date, text_schedule])
    
    print(table)
else:
    print("INFACTIVEL")
    for message in messages:
        print(message)