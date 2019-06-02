"""
    reader(nameFile)

- Julia version: 1.1.0
- Author: Ítalo Della Garza Silva
- Date: 2019-06-01

Lê um arquivo da base de dados com o nome nameFile e retorna o número de temas,
o número de autores, o número de trabalhos, o número de sessões, os trabalhos e as sessões.

# Arguments

 - `nameFile::String`: Nome do arquivo a ser escrito

# Examples
```julia-repl
julia> reader("problema1.txt")
```

"""
function reader(nameFile::String)
    open(nameFile) do file
        nThemes = parse(Int, readline(file))
        nAuthors = parse(Int, readline(file))
        nWorks = parse(Int, readline(file))

        works = Array{Work}(undef, nWorks)

        for count = 1:nWorks
            line = split(readline(file))
            mapped = map(x->parse(Int, x), line)
            nWorkThemes = mapped[1]
            workThemes = Array{Int}(undef, nWorkThemes)

            for theme = 1:nWorkThemes
                workThemes[theme] = mapped[theme + 1]
            end

            nWorkAuthors = mapped[nWorkThemes + 2]
            workAuthors = Array{Int}(undef, nWorkAuthors)

            for author = 1:nWorkAuthors
                workAuthors[author] = mapped[author + nWorkThemes + 2]
            end
            work = Work(count, nWorkThemes, nWorkAuthors, workThemes, workAuthors)
            works[count] = work
        end

        nSessions = parse(Int, readline(file))
        sessions = Array{Session}(undef, nSessions)

        for count = 1:nSessions
            line = split(readline(file))
            mapped = map(x->parse(Int, x), line)
            session = Session(count, mapped[1], mapped[2], mapped[3],  mapped[4], mapped[5],
                              mapped[6], mapped[7])
            sessions[count] = session
        end

        return nThemes, nAuthors, nWorks, nSessions, works, sessions

    end

end
