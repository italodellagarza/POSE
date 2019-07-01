"""
# struct Presentation

Estrutura para armazenar os dados de cada trabalho

"""
struct Presentation
    id::Int
    nThemes::Int
    nAuthors::Int
    themes::Array{Int64,1}
    authors::Array{Int64,1}
    type::Int
end