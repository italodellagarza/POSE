"""
# struct Session

- Julia version: 1.1.0
- Author: italo
- Date: 2019-06-01

Estrutura para armazenar os dados de cada sessão


"""
struct Session
    id::Int
    capacity::Int
    presentationTime::Int
    day::Int
    month::Int
    year::Int
    hour::Int
    minute::Int
end