include("Session.jl")
include("Presentation.jl")

#calcula a similaridade 
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

#verifica se é possível adicionar uma apresentação em uma dada sessão
function is_possible_select(presentation, presentations_struct, session, sessions_struct, schedules_capacity, dates_capacity)
    is_possible = true
    
    #verifica o número máximo de temas por dia e por horário e autor
    for theme in presentation.themes
        nThemes_date = 0
        nThemes_schedule = 0
        for session_ in sessions_struct
            if (session.date == session_.date)
                for presentation_id in session_.presentations
                    if (presentation.id != presentation_id)
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
        end
        if (nThemes_date >= dates_capacity || nThemes_schedule >= schedules_capacity)
            return false
        end
    end

    # verifica se o autor já foi alocado no horario da sessão
    for session_ in sessions_struct
        if (session.schedule == session_.schedule)
            for presentation_id in session_.presentations
                # if (presentation_id != presentation.id)
                    presentation_ = presentations_struct[presentation_id]
                    for author in presentation.authors
                        for author_ in presentation_.authors
                            if (author == author_)
                                return false
                            end
                        end
                    end
                # end
            end
        end
    end


    return true
end


function greedy_heuristic(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct, presentations_similarity, schedules_capacity, dates_capacity)    
    # Sessoes definidas como vetor de indices
    sessions = collect(1:n_sessions)
    # Apresentacoes definidas como vetor de indices
    presentations = collect(1:n_presentations)
    # Temas definidos como vetor de indices
    themes = collect(1:n_themes)
    # Autores definidos como vetor de indices
    authors = collect(1:n_authors)

    #sorteia as primeiras apresentações para cada sessão
    x = 0
    presentations_ids = []
    while (x < n_sessions)
        presentations_ids = unique(append!(presentations_ids, trunc(Int, (rand()*100000) % n_presentations) + 1))
        x, = size(presentations_ids)
    end
    
    #aloca as apresentações sorteadas nas sessões
    for i in collect(1:n_sessions)
        presentation_id = presentations_ids[i]

        pf = presentations_struct[presentation_id]
        new_presentation = Presentation(pf.id, pf.nThemes,
                pf.nAuthors, pf.themes,
                pf.authors, i)

        #se não for possível adicionar a apresentação na sessão, a sessão continua vazia e é preenchida na construção gulosa
        if (is_possible_select(pf, presentations_struct, sessions_struct[i], sessions_struct, schedules_capacity, dates_capacity))
            presentations_struct[new_presentation.id] = new_presentation
            append!(sessions_struct[i].presentations, presentation_id)
        end
    end
    
    # aloca apresentações nas sessões com critério guloso
    for session in sessions_struct
        nPresentation, = size(session.presentations)
        finished = false
        if (nPresentation >= session.capacity)
            finished = true
        end
        while (!finished)
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

    # verifica se há apresentação sem sessão e tenta alocar em alguma sessão
    feasible = true
    for presentation in presentations_struct
        if (presentation.session == -1)
            feasible = false
            # # println(presentation.id)
            # # cria um array de sessões disponíveis
            # sessions_available = []
            # for session in sessions_struct
            #     nPresentations, = size(session.presentations)
            #     if (nPresentations < session.capacity)
            #         append!(sessions_available, session.id)
            #     end
            # end
            # presentation_added = false

            # # para cada apresentação de cada sessão
            # # verifica se essa apresentação pode ser alocada em uma sessão disponível
            # # se sim, essa apresentação é retirada da sessão atual e colocada na sessão disponível
            # # a apresentação que estava sem sessão é colocada no lugar se for possível
            # for session in sessions_struct
            #     if (presentation_added)
            #         break
            #     end
            #     for presentation_ in session.presentations
            #         if (presentation_added)
            #             break
            #         end
            #         for session_ in sessions_available
            #             if (is_possible_select(presentations_struct[presentation_], presentations_struct, sessions_struct[session_], sessions_struct, schedules_capacity, dates_capacity))
            #                 println(session.presentations)
            #                 filter!(e -> e != presentation_, session.presentations)
                            
            #                 if (is_possible_select(presentation, presentations_struct, session, sessions_struct, schedules_capacity, dates_capacity))
            #                     new_presentation = Presentation(presentation.id, presentation.nThemes,
            #                     presentation.nAuthors, presentation.themes,
            #                     presentation.authors, session.id)
                                
            #                     println(new_presentation)
            #                     println(presentations_struct[presentation_])
            #                     println(session)
            #                     println(sessions_struct[session_])
            #                     presentations_struct[presentation.id] = new_presentation
            #                     append!(session.presentations, new_presentation.id)
                                
            #                     new_presentation = Presentation(presentations_struct[presentation_].id, presentations_struct[presentation_].nThemes,
            #                     presentations_struct[presentation_].nAuthors, presentations_struct[presentation_].themes,
            #                     presentations_struct[presentation_].authors, sessions_struct[session_].id)
                                
            #                     presentations_struct[presentation_] = new_presentation
            #                     append!(sessions_struct[session_].presentations, new_presentation.id)
            #                     presentation_added = true
            #                     feasible = true
            #                     break
            #                 else
            #                     append!( session.presentations, presentation_)
            #                     println(session.presentations)
            #                 end
            #                 println("=============================")
            #             end
            #         end
            #         println("******************************************")
            #     end
            # end
            # if (!presentation_added)
            #     return false, sessions_struct
            # end
        end
    end

    # for s in sessions_struct
    #     println(s)
    # end

    # for presentation in presentations_struct
    #     println(presentation)
    # end

    # println(sessions_struct[1])
    return feasible, sessions_struct 
    
end

function calc_value_session(presentation_id, session, presentations_similarity)
    value = 0
    if (presentation_id != -1)
        for presentation in session.presentations
            value = value + presentations_similarity[presentation_id, presentation]
        end
    end
    for presentation1 in session.presentations
        for presentation2 in session.presentations
            if (presentation2 > presentation1)
                value = value + presentations_similarity[presentation1, presentation2]
            end
        end
    end
    return value
end

function local_search(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct, presentations_similarity, schedule_capacity, date_capacity, function_value)
    for presentation in presentations_struct
        for presentation_ in presentations_struct
            session = sessions_struct[presentation.session]
            session_ = sessions_struct[presentation_.session]
            if ( (presentation.id != presentation_.id) && (session.id != session_.id) )

                value_before = calc_value_session(-1, session, presentations_similarity) + calc_value_session(-1, session_, presentations_similarity)

                id_session = presentation.session
                pos = findall(x -> x == presentation.id, session.presentations)[1]
                deleteat!(session.presentations, pos)
                # new_presentation = Presentation(presentation.id, presentation.nThemes, presentation.nAuthors, presentation.themes, presentation.authors, -1) 
                # presentation.session = -1
                # setfield!(presentation, :session, -1)
                
                
                id_session_ = presentation_.session
                pos_ = findall(x -> x == presentation_.id, session_.presentations)[1]
                deleteat!(session_.presentations, pos_)
                # new_presentation_ = Presentation(presentation_.id, presentation_.nThemes, presentation_.nAuthors, presentation_.themes, presentation_.authors, -1) 

                # presentation_.session = -1

                switched = false

                if (is_possible_select(presentation, presentations_struct, sessions_struct[id_session], sessions_struct, schedule_capacity, date_capacity))
                    if (is_possible_select(presentation_, presentations_struct, sessions_struct[id_session_], sessions_struct, schedule_capacity, date_capacity))
                        
                        value_after = calc_value_session(presentation.id, session_, presentations_similarity) + calc_value_session(presentation_.id, session, presentations_similarity)

                        if (value_after > value_before)
                            new_presentation = Presentation(presentation.id, presentation.nThemes,
                            presentation.nAuthors, presentation.themes,
                            presentation.authors, session_.id)
                            
                            presentations_struct[presentation.id] = new_presentation
                            append!(session_.presentations, new_presentation.id)
                            
                            new_presentation = Presentation(presentation_.id, presentation_.nThemes,
                            presentation_.nAuthors, presentation_.themes,
                            presentation_.authors, session.id)
                            
                            presentations_struct[presentation_.id] = new_presentation
                            append!(session.presentations, new_presentation.id)

                            return true, sessions_struct
                        end
                    end
                end

                if (switched)
                    println("ALU")
                else
                    insert!(session.presentations, pos, presentation.id)
                    insert!(session_.presentations, pos_, presentation_.id)

                end
            end
        end
    end
    return false, sessions_struct
end


function heuristic(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct, schedule_capacity, date_capacity, n_iteration)
    
    #indices das apresentações
    presentations = collect(1:n_presentations)
    #indices das sessões
    sessions = collect(1:n_sessions)

    # Calcula os valores de similaridade para cada par de apresentacoes
    presentations_similarity = calculate_similarity(n_presentations, presentations, presentations_struct)
    
    number_of_times = n_iteration
    percentage_of_errors = 0
    best_function_value = -1
    best_session_struct = []

    # calcula o tempo gasto pela heurística
    time_heuristic = @elapsed begin

        # executa a heurística n vezes
        for i in collect(1:number_of_times)

            #cria cópias para as sessões e apresentações
            par_sessions_struct = deepcopy(sessions_struct)
            par_presentations_struct = deepcopy(presentations_struct)
            
            #executa a heurística e recebe a factibilidade o resultado  das sessões
            feasible, results_struct = greedy_heuristic(n_themes, n_authors, n_presentations, n_sessions, par_presentations_struct, par_sessions_struct, presentations_similarity, schedule_capacity, date_capacity)
            
            function_value = 0
    
            #se for factível, executa busca local x vezes
            if (feasible)
                for i in collect(1:50)
                    result, results_struct = local_search(n_themes, n_authors, n_presentations, n_sessions, par_presentations_struct, 
                                    results_struct, presentations_similarity, schedule_capacity, date_capacity, function_value)

                    # se não houve melhoria, para o iterador
                    if (result == false )
                        i = 50
                    end
                end

                #calcula o valor da função após a busca local
                function_value = 0
                for session in results_struct
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

            end
            
            # se não for factível, aumenta o número de respostas infactíveis
            # se for factível e se o valor da função for melhor que a melhor solução encontrada até o momento
            # a melhor solução recebe a solução atual
            if (!feasible)
                percentage_of_errors = percentage_of_errors + 1
            elseif (function_value > best_function_value)
                best_session_struct = deepcopy(results_struct)
                best_function_value = function_value
            end
        end
        percentage_of_errors = (percentage_of_errors / number_of_times) * 100
    end



    # println(results_struct[1])
    # print("tempo de processamento: ")
    # println(t)
    
    
    # for session in sessions_struct
    #     println("Sessão: ", session.id)
    #     println("horario: ", session.schedule)
    #     println("n presentation", session.presentations)
    # end
    
    #constrói a matriz saída (não precisa colocar no relatório)
    presentation_sessions = zeros(n_presentations, n_sessions)
    for session in best_session_struct
        for presentation in session.presentations
            # println(presentation, " ", n_presentations)
            presentation_sessions[presentation, session.id] = 1 
        end
    end
    
    output = ""
    output = string(output, "schedule_capacity : ", schedule_capacity, "\n")
    output = string(output, "date_capacity : ", date_capacity, "\n")
    output = string(output, "time : ", time_heuristic, "\n")
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
    

        
    
    output = string(output, "objective_function_value : ", best_function_value, "\n")

    return  best_function_value, output, time_heuristic, percentage_of_errors 
end