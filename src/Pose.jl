"""
# module Pose

Módulo principal do arquivo

"""
module Pose
    include("reader.jl")
    include("Session.jl")
    include("Presentation.jl")
    include("Model.jl")

    function __init__()

        # nThemes, nAuthors, nPresentations, nSessions, presentations, sessions = reader("./datafiles/problema1.txt")
        nThemes, nAuthors, nPresentations, nSessions, presentations, sessions = reader(ARGS[1])
        println("Numero de temas = ", nThemes)
        println("Numero de autores = ", nAuthors)
        println("Numero de trabalhos = ", nPresentations)
        println()

        for presentation in presentations
            println("Trabalho: ", presentation.id)
            println("Numero de temas ", presentation.nThemes)
            println("Temas: ", presentation.themes)
            println("Numero de Autores: ", presentation.nAuthors)
            println("Autores: ", presentation.authors)
            println()
        end
        println()
        for session in sessions
            println("Sessao: ", session.id)
            println("Capacidade: ", session.capacity)
            println("Tempo de apresentacao: ", session.presentationTime)
            println("Dia e hora da apresentacao: ", session.schedule)
            println("Dia da apresentacao: ", session.date)
            println()
        end
        println()
        println()
        println()
        println()
        println()
        println()

        createModel(nThemes, nAuthors, nPresentations, nSessions, presentations, sessions)

    end
end