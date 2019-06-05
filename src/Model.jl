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



    println(schedules_sessions)
    println(dates_schedules)
    println(presentations_authors)
end
