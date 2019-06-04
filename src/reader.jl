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
            presentation = Presentation(count, nPresentationThemes, nPresentationAuthors, presentationThemes, presentationAuthors)
            presentations[count] = presentation
        end

        nSessions = parse(Int, readline(file))
        sessions = Array{Session}(undef, nSessions)

        for count = 1:nSessions
            line = split(readline(file))
            mapped = map(x->parse(Int, x), line)
            session = constructorSession(count, mapped[1], mapped[2], mapped[3],  mapped[4], mapped[5],
                              mapped[6], mapped[7])
            sessions[count] = session
        end

        return nThemes, nAuthors, nPresentations, nSessions, presentations, sessions

    end

end
