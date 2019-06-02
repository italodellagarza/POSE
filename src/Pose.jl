"""
# module Pose

- Julia version: 1.1.0
- Author: Ítalo Della Garza Silva
- Date: 2019-06-01

Módulo principal do arquivo

# Examples
```terminal
julia src/Pose.jl
```

"""
module Pose
    include("reader.jl")
    include("Session.jl")
    include("Work.jl")

    function __init__()
        nThemes, nAuthors, nWorks, nSessions, works, sessions = reader("./datafiles/problema1.txt")
        println("Numero de temas = ", nThemes)
        println("Numero de autores = ", nAuthors)
        println("Numero de trabalhos = ", nWorks)
        println()

        for work in works
            println("Trabalho: ", work.id)
            println("Numero de temas ", work.nThemes)
            println("Temas: ", work.themes)
            println("Numero de Autores: ", work.nAuthors)
            println("Autores: ", work.authors)
            println()
        end
        println()
        for session in sessions
            println("Sessao: ", session.id)
            println("Capacidade: ", session.capacity)
            println("Tempo de apresentacao: ", session.presentationTime)
            print("Dia e hora da apresentacao: ", session.day, "/", session.month, "/")
            println(session.year, " - ", session.hour, ":", session.minute)
            println()
        end
    end
end