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
            println("Comando incorreto!")
            println("Exemplo de entrada: ")
            println("julia src/Pose.jl <arquivo de teste> <arquivo saida> <capacidade de horario> <capacidade por dia>")
            return
        end

        # nThemes, nAuthors, nPresentations, nSessions, presentations, sessions = reader("./datafiles/problema1.txt")
        nThemes, nAuthors, nPresentations, nSessions, presentations, sessions = reader(ARGS[1])
        output_file_name = ARGS[2]
        schedule_capacity = parse(Int, ARGS[3])
        date_capacity = parse(Int, ARGS[4])

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
        results = heuristic(nThemes, nAuthors, nPresentations, nSessions,
                            presentations, sessions, schedule_capacity, 
                            date_capacity, n_iteration)

        function_value, output, time_heuristic, percentage_of_errors, sessions_struct = results
     
        open(output_file_name, "w") do f 
            write(f, output)
        end
            
        println("Taxa de erro: ", percentage_of_errors)
        println("Time: ", time_heuristic)
        println("Best funtion value: ", function_value)
        println()
        # for session in sessions_struct
        #     println("Sessão: ", session.id)
        #     println("horario: ", session.schedule)
        #     println("presentation: ", session.presentations)
        #     println()
        # end
    end
end