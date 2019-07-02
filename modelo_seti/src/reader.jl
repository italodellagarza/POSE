"""
    reader(nameFile)

Lê um arquivo da base de dados com o nome nameFile e retorna o número de temas,
o número de autores, o número de trabalhos, o número de sessões, os trabalhos e as sessões.

# Arguments

 - `nameFile::String`: Nome do arquivo a ser escrito

"""
function reader(nameFile::String)
    open(nameFile) do file
        nThemes = parse(Int, readline(file))
        nAuthors = parse(Int, readline(file))

        authors_struct = Array{Author}(undef, nAuthors)

        for count = 1:nAuthors
            line = split(readline(file))
            mapped = map(x->parse(Int, x), line)
            nAvailable = mapped[1]
            availableSessions = Array{Int}(undef, nAvailable)
            
            
            for session = 1:nAvailable
                availableSessions[session] = mapped[session + 1]
            end
            

            author = Author(count, nAvailable, availableSessions)
            authors_struct[count] = author
        end



        nPresentations = parse(Int, readline(file))

        presentations = Array{Presentation}(undef, nPresentations)

        for count = 1:nPresentations
            line = split(readline(file))
            mapped = map(x->parse(Int, x), line)
            nPresentationThemes = mapped[1]
            presentationThemes = Array{Int}(undef, nPresentationThemes)
            
            
            for theme = 1:nPresentationThemes
                presentationThemes[theme] = mapped[theme + 1]
            end
            
            
            nPresentationAuthors = mapped[nPresentationThemes + 2]
            presentationAuthors = Array{Int}(undef, nPresentationAuthors)
            
            for author = 1:nPresentationAuthors
                presentationAuthors[author] = mapped[author + nPresentationThemes + 2]
            end

            for i in collect(1:nPresentationThemes)
                presentationThemes[i] = presentationThemes[i] + 1
            end
            
            for i in collect(1:nPresentationAuthors)
                presentationAuthors[i] = presentationAuthors[i] + 1
            end
            
            type = mapped[nPresentationAuthors + nPresentationThemes + 2]


            presentation = Presentation(count, nPresentationThemes, nPresentationAuthors, presentationThemes, presentationAuthors, type)
            presentations[count] = presentation
        end
        
        nSessions = parse(Int, readline(file))
        sessions = Array{Session}(undef, nSessions)
        
        for count = 1:nSessions
            line = split(readline(file))
            mapped = map(x->parse(Int, x), line)

            nSessionTypes = mapped[8]
            sessionTypes = Array{Int}(undef, nSessionTypes)
            
            for st = 1:nSessionTypes
                sessionTypes[st] = mapped[8 + st]
            end


            session = constructorSession(count, mapped[1], mapped[2], mapped[3],  mapped[4], mapped[5],
            mapped[6], mapped[7], nSessionTypes, sessionTypes)
            sessions[count] = session
        end
        
        return nThemes, nAuthors, nPresentations, nSessions, presentations, sessions
        
    end

end
