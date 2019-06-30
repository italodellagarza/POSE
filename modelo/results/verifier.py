import pprint
import sys

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


with open("./results/temp.txt", "r") as file:
    lines = file.read().splitlines()
    presentations_sessions = []
    for line in lines:
        line = line.strip().split(" ")
        new_line = []
        for v in line:
            new_line.append(int(float(v)))

        presentations_sessions.append(new_line)

pprint.pprint(presentations_sessions)

with open("./datafiles/problema1.txt", "r") as file:
    lines = file.read().splitlines()
    n_themes = int(lines[0])
    n_authors = int(lines[1])
    n_presentations = int(lines[2])

    presentations = []
    for i in range(3, n_presentations+3):
        presentation = {'authors': [], 'themes': []}

        line = lines[i].strip().split(" ")

        # numero de temas daquela apresentacao
        nt = int(line[0])

        # pega os temas
        for j in range(1, nt+1):
            presentation['themes'].append(int(line[j]))

        # numero de autores daquela apresentacao
        na = int(line[nt+1])
        for j in range(nt+2, len(line)):
            presentation['authors'].append(int(line[j]))
        
        presentations.append(presentation)

    n_sessions = int(lines[n_presentations+3])
    print("aquiuii", n_sessions)

    start = n_presentations + 4
    end = start + n_sessions

    sessions = []
    sessions_by_date = {}
    for i in range(start, end):
        session = {}
        line = lines[i].strip().split(" ")
        print("line", line)

        session["id"] = i-start
        session["capacity"] = int(line[0])
        session["duration"] = int(line[1])
        date = line[2] + "-" + line[3] + "-" + line[4]
        session["date"] = date
        schedule = date + " " + line[5] + ":" + line[6]
        session["schedule"] = schedule
        session["presentations"] = []
        for i in range(n_presentations):
            if(presentations_sessions[i][session["id"]] == 1):
                session["presentations"].append(presentations[i])

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

        

    pprint.pprint(sessions_by_date)



    pprint.pprint(presentations)



if(len(sys.argv) < 3):
    print("Exemplo de execucao:")
    print("python3 results/verifier.py <capacidade de horario> <capacidade por dia>")
    exit(0)


# maxima capacidade de temas por horario
schedule_capacity = int(sys.argv[1])
print(schedule_capacity)

# maxima capacidade de temas por dia
date_capacity = int(sys.argv[2])
print(date_capacity)


print(check_constraint_only_one(presentations_sessions, presentations))
print(check_max_themes_in_schedule(n_themes, sessions_by_date, schedule_capacity))
print(check_max_themes_in_date(n_themes, sessions_by_date, date_capacity))
print(check_max_presentations_in_session(sessions))
print(check_one_presentation_schedule_per_author(sessions_by_date))