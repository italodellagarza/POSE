"""
# struct Session

Estrutura para armazenar os dados de cada sessão

"""
function constructorSession(id, capacity, presentationTime, day, month, year, hour, minute, nTypes, types)
    schedule =  string(year, "-",  month, "-",  day, " ",  hour, ":",  minute)
    date =  string(year, "-",  month, "-",  day)
    return Session(id, capacity, presentationTime, schedule, date, nTypes, types)
end

struct Session
    id::Int
    capacity::Int
    presentationTime::Int
    schedule::String
    date::String
    nTypes::Int
    types::Array{Int64,1}
end