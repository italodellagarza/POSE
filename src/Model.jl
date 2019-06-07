"""
# module Pose

Módulo para criação do modelo

"""

using Gurobi
using JuMP

include("Session.jl")
include("Presentation.jl")

function createModel(n_themes, n_authors, n_presentations, n_sessions, presentations_struct, sessions_struct)
    model = Model(with_optimizer(Gurobi.Optimizer))
    
    sessions = collect(1:n_sessions)
    presentations = collect(1:n_presentations)
    themes = collect(1:n_themes)
    authors = collect(1:n_authors)
    
    
    
    schedules_capacity = 5
    max_capacity = []
    min_capacity = []

    for session in sessions
        append!(max_capacity, sessions_struct[session].capacity)
        append!(min_capacity, 0)
    end

    
    presentations_themes = zeros(n_presentations, n_themes)
    for i in presentations, j in themes
        if (j in presentations_struct[i].themes)
            presentations_themes[i, j] = 1
        end
    end

    schedules_sessions = Dict()
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
    

    presentations_authors = zeros(n_presentations, n_authors)
    for i in presentations, j in authors
        if (j in presentations_struct[i].authors)
            presentations_authors[i,j] = 1
        end
    end


    
    model = Model(with_optimizer(Gurobi.Optimizer))

    @variable(model, 1 >= presentations_session[1:n_presentations, 1:n_sessions] >= 0, Int)
    @variable(model, 1 >= presentations_are_in_same_session[1:n_presentations, 1:n_presentations] >= 0, Int)

    for i in presentations
        # CADA APRESENTAÇÃO TEM QUE ESTAR EM EXATAMENTE UMA SESSÃO
        @constraint(model, sum(presentations_session[i,se] for se in sessions) == 1)
        for j in presentations
            for s in sessions
                # SE DUAS SESSÕES ESTÃO NO MESMO HORÁRIO, presentations_are_in_same_session[i,j] = 1
                @constraints(model, 
                    begin
                        presentations_are_in_same_session[i,j] <= presentations_session[i,s]
                        presentations_are_in_same_session[i,j] <= presentations_session[j,s]
                        presentations_are_in_same_session[i,j] >= presentations_session[i,s] + presentations_session[j,s] - 1
                    end
                )
            end
        end
    end


    # LIMITE TEMA X HORÁRIO
    for t in themes
        for s in keys(schedules_sessions)
            @constraints(model, 
                begin
                    sum(sum(presentations_session[p, session_i] * presentations_themes[p, t] for session_i in schedules_sessions[s])  for p in presentations) <= 10
                end
            )
        end
    end

    # LIMITE TEMA X DIA
    for t in themes
        for d in keys(dates_schedules)

            @constraints(model, 
                begin
                    sum(
                        sum(
                            sum( 
                                presentations_session[p, s] * presentations_themes[p,t] for p in presentations
                            )  for s in schedules_sessions[schedule_i]
                        ) for schedule_i in dates_schedules[d]) <= 10
                end
            )
        end
    end

    for s in sessions
        @constraints(model,
            begin
                sum(presentations_session[p, s] for p in presentations) <= max_capacity[s] 
                sum(presentations_session[p, s] for p in presentations) >= min_capacity[s] 
            end
        )
    end



    print(model)
    println(schedules_sessions)
    println(dates_schedules)
    # println(presentations_authors)
end
