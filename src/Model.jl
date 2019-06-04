"""
# module Pose

Módulo para criação do modelo

"""

using Gurobi
using JuMP

include("Session.jl")
include("Presentation.jl")

function createModel(nThemes, nAuthors, nPresentations, nSessions, presentationsStruct, sessionsStruct)
    model = Model(with_optimizer(Gurobi.Optimizer))
    
    sessions = collect(1:nSessions)
    presentations = collect(1:nPresentations)
    themes = collect(1:nThemes)
    authors = collect(1:nAuthors)

    max_capacity = []
    min_capacity = []
    for session in sessions
        append!(max_capacity, sessionsStruct[session].capacity)
        append!(min_capacity, 0)
    end

    presentations_themes = []
    for presentation in presentations
        for theme in themes
            # TODO
        end
    end
    print(presentations_themes)
end
