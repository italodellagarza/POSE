"""
# module Pose

Módulo principal do arquivo

"""
module Pose
    include("reader.jl")
    include("Session.jl")
    include("Presentation.jl")
    include("heuristic.jl")

    function __init__()

        if size(ARGS)[1] < 1
            println("É necessário passar um arquivo de entrada")
            return
        end

        # nThemes, nAuthors, nPresentations, nSessions, presentations, sessions = reader("./datafiles/problema1.txt")
        nThemes, nAuthors, nPresentations, nSessions, presentations, sessions = reader(ARGS[1])
        schedule_capacity = parse(Int, ARGS[2])
        date_capacity = parse(Int, ARGS[3])

        # println("Numero de temas = ", nThemes)
        # println("Numero de autores = ", nAuthors)
        # println("Numero de trabalhos = ", nPresentations)
        # println()

        # for presentation in presentations
        #     println("Trabalho: ", presentation.id)
        #     # println("Numero de temas ", presentation.nThemes)
        #     println("Temas: ", presentation.themes)
        #     # println("Numero de Autores: ", presentation.nAuthors)
        #     println("Autores: ", presentation.authors)
        #     println()
        # end
        # println()
        # for session in sessions
        #     println("Sessao: ", session.id)
        #     println("Capacidade: ", session.capacity)
        #     # println("Tempo de apresentacao: ", session.presentationTime)
        #     println("Dia e hora da apresentacao: ", session.schedule)
        #     # println("Dia da apresentacao: ", session.date)
        #     println()
        # end
        # println()

        # Numero de iterações da heuristica
        n_iteration = 100
        function_value, output, time_heuristic, percentage_of_errors = heuristic(nThemes, nAuthors, nPresentations, nSessions,
                                                                                presentations, sessions, schedule_capacity, 
                                                                                date_capacity, n_iteration)
     
        open("./results/temp.txt", "w") do f 
            write(f, output)
        end
            
        println("Taxa de erro: ", percentage_of_errors)
        println("Time: ", time_heuristic)
        println("Best funtion value: ", function_value)
    end
end