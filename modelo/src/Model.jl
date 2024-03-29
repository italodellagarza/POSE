"""
# module Pose

Módulo para criação do modelo

"""

using Gurobi
using JuMP

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


function createModel(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct, sc, dc, output_file_name)
    # model = Model(with_optimizer(Gurobi.Optimizer))
    
    #### DADOS ####
    
    
    # Sessoes definidas como vetor de indices
    sessions = collect(1:n_sessions)
    # Apresentacoes definidas como vetor de indices
    presentations = collect(1:n_presentations)
    # Temas definidos como vetor de indices
    themes = collect(1:n_themes)
    # Autores definidos como vetor de indices
    authors = collect(1:n_authors)
    
    # Calcula os valores de similaridade para cada par de apresentacoes
    presentations_similarity = calculate_similarity(n_presentations, presentations, presentations_struct)

    # Capacidade de cada horario
    schedules_capacity = sc
    dates_capacity = dc

    # Cria um vetor de capacidades minimas e maximas de cada sessao
    max_capacity = []
    min_capacity = []
    for session in sessions
        append!(max_capacity, sessions_struct[session].capacity)
        append!(min_capacity, 0)
    end

    
    # Cria uma matriz binaria que relaciona apresentacoes com temas
    ## presentations_themes[i, j]:
    ##       1, se a aparesetacao i tem tema j
    ##       0, caso contrario
    presentations_themes = zeros(n_presentations, n_themes)
    for i in presentations, j in themes
        if (j in presentations_struct[i].themes)
            presentations_themes[i, j] = 1
        end
    end


    # Cria dicionario que relaciona um horario com uma lista de sessoes
    ## schedules_sessions[h] = [s1, s2, s3]
    ##       as sessoes s1, s2, s3 estao alocadas no horario h
    schedules_sessions = Dict()
    # Cria dicionario que relaciona um dia com uma lista de horarios
    ## dates_schedules[d] = [h1, h2, h3]
    ##       ha apresentacoes alocadas somente nos horarios h1, h2, h3 no dia d
    dates_schedules = Dict()
    for session in sessions_struct
        if session.schedule in keys(schedules_sessions)
            append!(schedules_sessions[session.schedule], session.id)
        else
            schedules_sessions[session.schedule] = [session.id]
        end

        if session.date in keys(dates_schedules)
            if !(session.schedule in dates_schedules[session.date])
                push!(dates_schedules[session.date], session.schedule)
            end
        else
            dates_schedules[session.date] = [session.schedule]
        end
    end
    

    # Cria uma matriz binaria que relaciona as apresentacoes com seus autores
    ## presentations_authors[i, j]:
    ##       1, se a apresetacao i tem autor j
    ##       0, caso contrario
    presentations_authors = zeros(n_presentations, n_authors)
    for i in presentations, j in authors
        if (j in presentations_struct[i].authors)
            presentations_authors[i,j] = 1
        end
    end

    
    ########### MODELO ###########
    
    # Instancia modelo
    model = Model(with_optimizer(Gurobi.Optimizer))
    
    #### VARIAVEIS ####
    
    
    # Cria uma matriz de variaveis que indicam se uma apresentacao foi alocada a uma sessao
    ## presentations_session[i, j]:
    ##       1, caso a apresentacao i esteja alocada na sessao j
    ##       0, caso contrario
    @variable(
                model, 
                1 >= presentations_session[1:n_presentations, 1:n_sessions] >= 0, 
                Int
             )


    # Cria uma matriz de variaveis que indicam se duas apresentacoes estao no mesmo horario
    # Seu objetivo é fazer um operador "AND" linear
    ## presentations_are_in_same_session[i, j]:
    ##       1, se as apresentacoes i e j foram alocadas na mesma sessao
    ##       0, caso contrario
    @variable(
                model, 
                1 >= presentations_are_in_same_session[1:n_sessions ,1:n_presentations, 1:n_presentations] >= 0, 
                Int
             )



    #### FUNCAO OBJETIVO ####


    @objective(
                model, 
                Max, 
                sum(
                    sum(
                        sum(
                            presentations_similarity[i, j] * presentations_are_in_same_session[s, i, j]
                            # presentations_are_in_same_session[s, i, j]
                            for i in presentations
                        )
                        for j in presentations
                    )
                    for s in sessions
                )
    )

    #### RESTRICOES ####


    for i in presentations
        # Cria restricao
        ## Cada apresentacao deve ser alocada a exatamente uma sessao
        @constraint(model, sum(presentations_session[i,se] for se in sessions) == 1)

        # Cria restricoes
        ## Define o valor da variavel presentations_are_in_same_session 
        ## formulado como um "AND"
        for j in presentations
            for s in sessions
                if (j > i)
                    @constraints(model, 
                        begin
                            (
                                presentations_are_in_same_session[s,i,j] 
                                <= presentations_session[i,s]
                            )

                            (
                                presentations_are_in_same_session[s,i,j] 
                                <= presentations_session[j,s]
                            )

                            (
                                presentations_are_in_same_session[s,i,j] 
                                >= presentations_session[i,s] 
                                + presentations_session[j,s] 
                                - 1
                            )
                        end
                    )
                else
                    @constraint(model, presentations_are_in_same_session[s,i,j] == 0)
                end
            end
        end
    end

    # Cria restricoes
    ## Limita a quantidade de temas por horarios
    for t in themes
        for s in keys(schedules_sessions)
            @constraints(model, 
                begin
                    (
                        sum(
                            sum(
                                presentations_session[p, session_i] 
                                * presentations_themes[p, t] 
                                for session_i in schedules_sessions[s]
                            )  
                            for p in presentations
                        ) 
                        <= schedules_capacity
                    )
                end
            )
        end
    end

    # Cria restricoes
    ## Limita a quantidade de temas por dia

    for t in themes
        for d in keys(dates_schedules)

            @constraints(model, 
                begin
                    (
                        sum(
                            sum(
                                sum( 
                                    presentations_session[p, s] * presentations_themes[p,t] for p in presentations
                                ) 
                                for s in schedules_sessions[schedule_i]
                            ) 
                            for schedule_i in dates_schedules[d]
                        ) 
                        <= dates_capacity
                    )
                end
            )
        end
    end

    # Cria restricoes
    ## Limita a quantidade de apresentacoes por sessao 
    ## de acordo com capacidades minimas e maximas

    for s in sessions
        @constraints(model,
            begin
                (
                    sum(
                        presentations_session[p, s] 
                        for p in presentations
                    ) 
                    <= max_capacity[s] 
                )
                
                (
                    sum(
                        presentations_session[p, s] 
                        for p in presentations
                    ) 
                    >= min_capacity[s] 
                )
            end
        )
    end

    # Cria restricoes
    ## Impede que o mesmo autor esteja em mais de uma sessao por horario
    
    for schedule in keys(schedules_sessions)
        for a in authors
            @constraint(
                model,
                sum(
                   sum(
                        presentations_session[i, s] * presentations_authors[i, a]
                        for i in presentations
                    )
                    for s in schedules_sessions[schedule]
                )
                <= 1
            )
        end
    end



    # println(model)
    # println("presentations_themes")
    # for i in presentations
    #     print(i, " ")
    #     for j in themes
    #         print(presentations_themes[i, j], " ")
    #     end
    #     println()
    # end
    # println("schedules_sessions")
    # println(schedules_sessions)
    # println("dates_schedules")
    # println(dates_schedules)
    # println("presentations_authors")
    # for i in presentations
    #     print(i, " ")
    #     for j in authors
    #         print(presentations_authors[i, j], " ")
    #     end
    #     println()
    # end
    # println("presentations_similarity")
    # for i in presentations
    #     for j in presentations
    #         print(presentations_similarity[i, j], " ")
    #     end
    #     println()
    # end

    # println("----------------------------------------------------------")
    t = @elapsed begin
        optimize!(model)
    end
    # println(t)
    if (has_values(model))
        open(output_file_name, "w") do f
            text = ""
            text = string(text, "schedule_capacity : ", schedules_capacity, "\n")
            text = string(text, "date_capacity : ", dates_capacity, "\n")
            text = string(text, "time : ", t, "\n")
            for i in presentations
                for s in sessions
                    if (JuMP.value(presentations_session[i,s]) == 0)
                        # print(0.0, " ")
                        text = string(text, 0.0, " ")
                    else
                        # print(JuMP.value(presentations_session[i,s]), " ")
                        text = string(text,JuMP.value(presentations_session[i,s]), " ")
                    end
                end
                # println()
                text = string(text, "\n")
            end

            text = string(text, "objective_function_value : ", objective_value(model))


            for s in sessions
                # println("Sessão: ", s)
                for i in presentations
                    for j in presentations
                        if (JuMP.value(presentations_are_in_same_session[s,i,j]) == 0)
                            # print(0.0, " ")
                        else
                            # print(JuMP.value(presentations_are_in_same_session[s,i,j]), " ")
                        end
                    end
                    # println()
                end
            end
            write(f, text)
        end
    else
        println("infeasible")
    end
    
end
