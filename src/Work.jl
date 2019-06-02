"""
# struct Work

- Julia version: 1.1.0
- Author: Ítalo Della Garza Silva
- Date: 2019-06-01

Estrutura para armazenar os dados de cada trabalho

"""
struct Work
    id::Int
    nThemes::Int
    nAuthors::Int
    themes::Array{Int64,1}
    authors::Array{Int64,1}
end