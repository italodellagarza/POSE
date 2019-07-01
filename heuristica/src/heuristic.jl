include("Session.jl")
include("Presentation.jl")

function calculate_similarity(n_presentations, presentations, presentations_struct)
    presentations_similarity = zeros(n_presentations, n_presentations)
    for i in presentations
        for j in presentations
            if (i != j)
                themes_i = presentations_struct[i].themes
                themes_j = presentations_struct[j].themes
                intersection_size = size(findall(in(themes_i), themes_j))[1]

                number_themes_i = presentations_struct[i].nThemes
                number_themes_j = presentations_struct[j].nThemes
                total_number_of_themes = number_themes_i + number_themes_j
                
                presentations_similarity[i, j] = intersection_size * 2 / total_number_of_themes
            end
        end
    end
    return presentations_similarity
end

function is_possible_select(presentation, presentations_struct, session, sessions_struct, schedules_capacity, dates_capacity)
    is_possible = true
    
    #verifica o número máximo de temas por dia e horário e autor
    for theme in presentation.themes
        nThemes_date = 0
        nThemes_schedule = 0
        for session_ in sessions_struct
            if (session.date == session_.date)
                for presentation_id in session_.presentations
                    presentation_ = presentations_struct[presentation_id]
                    for theme_ in presentation_.themes
                        if (theme == theme_)
                            nThemes_date = nThemes_date + 1
                            if (session.schedule == session_.schedule)
                                nThemes_schedule = nThemes_schedule + 1
                            end
                        end
                    end
                end
            end
        end
        if (nThemes_date >= dates_capacity || nThemes_schedule >= schedules_capacity)
            return false
        end
    end

    #verifica se o autor já não está no horário
    for session_ in sessions_struct
        if (session.schedule == session_.schedule)
            for presentation_id in session_.presentations
                presentation_ = presentations_struct[presentation_id]
                for author in presentation.authors
                    for author_ in presentation_.authors
                        if (author == author_)
                            return false
                        end
                    end
                end
            end
        end
    end


    return true
end

function greedy_heuristic(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct, presentations_similarity)    
    # Sessoes definidas como vetor de indices
    sessions = collect(1:n_sessions)
    # Apresentacoes definidas como vetor de indices
    presentations = collect(1:n_presentations)
    # Temas definidos como vetor de indices
    themes = collect(1:n_themes)
    # Autores definidos como vetor de indices
    authors = collect(1:n_authors)

    
    # Capacidade de cada horario
    schedules_capacity = 3
    dates_capacity = 1000
    
    
    for session in sessions_struct
        nPresentation, = size(session.presentations)
        finished = false
        if (nPresentation >= session.capacity)
            finished = true
        end
        while(!finished)
            best_presentation = nothing
            best_similarity = -1
            added = false
            for presentation in presentations_struct
                if (presentation.session == -1)
                    similarity = 0
                    for presentation_2_id in session.presentations
                        presentation_2 = presentations_struct[presentation_2_id]
                        similarity = similarity + presentations_similarity[presentation_2.id, presentation.id]
                    end
                    
                    if (similarity > best_similarity &&
                        is_possible_select(presentation, presentations_struct, session, sessions_struct, schedules_capacity, dates_capacity))
                        best_presentation = presentation
                        best_similarity = similarity
                        added = true
                    end
                end
            end
            if (added)
                println(best_presentation)
                
                new_presentation = Presentation(best_presentation.id, best_presentation.nThemes,
                best_presentation.nAuthors, best_presentation.themes,
                best_presentation.authors, session.id)
                
                presentations_struct[best_presentation.id] = new_presentation
                append!(session.presentations, new_presentation.id)
            end
            if (added == false || size(session.presentations)[1] >= session.capacity)
                finished = true
            end
        end
    end
    
    return sessions_struct
    
end

function heuristic(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct)
    
    presentations = collect(1:n_presentations)
    sessions = collect(1:n_sessions)

    # Calcula os valores de similaridade para cada par de apresentacoes
    presentations_similarity = calculate_similarity(n_presentations, presentations, presentations_struct)
    
    t = @elapsed begin
        results_struct = greedy_heuristic(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct, presentations_similarity)
    end
    println(t)
    
    
    
    
    for session in sessions_struct
        println("Sessão: ", session.id)
        println("horario: ", session.schedule)
        println("n presentation", session.presentations)
    end
    
    presentation_sessions = zeros(n_presentations, n_sessions)
    for session in sessions_struct
        for presentation in session.presentations
            println(presentation, " ", n_presentations)
            presentation_sessions[presentation, session.id] = 1 
        end
    end
    
    output = ""
    output = string("time : ", t, "\n")
    for presentation in presentations
        for session in sessions
            output = string(
                output, 
                presentation_sessions[presentation, session], 
                " "
            ) 
        end
        output = string(output, "\n") 
    end
    function_value = 0
    
    for session in results_struct
        println(session)
        for presentation1 in session.presentations
            for presentation2 in session.presentations
                if (presentation2 > presentation1)
                    function_value = (
                        function_value + 
                        presentations_similarity[presentation1, presentation2]
                    )
                end
            end
        end
    end

        
    
    output = string(output, "objective_function_value : ", function_value)
    println(output)
    
    
    open("./results/temp.txt", "w") do f 
        write(f, output)
    end
    
end