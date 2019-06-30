"""
# struct Session

Estrutura para armazenar os dados de cada sessão

"""
function constructorSession(id, capacity, presentationTime, day, month, year, hour, minute)
    schedule =  string(year, "-",  month, "-",  day, " ",  hour, ":",  minute)
    date =  string(year, "-",  month, "-",  day)
    return Session(id, capacity, presentationTime, schedule, date)
end

struct Session
    id::Int
    capacity::Int
    presentationTime::Int
    schedule::String
    date::String
end