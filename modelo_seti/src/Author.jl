"""
# struct Author

Estrutura para armazenar os dados de cada autor

"""
struct Author
    id::Int
    nSessions::Int
    sessions::Array{Int64,1}
end