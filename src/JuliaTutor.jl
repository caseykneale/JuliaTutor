module JuliaTutor
    using Crayons, Logging, ReplMaker
    #Handle lesson plans
    global LESSON_PATH = Base.joinpath( @__DIR__ ,  "Lessons" )
    lessons_available = readdir( LESSON_PATH )
    numbered_lessons = enumerate( lessons_available )

    #See if our user is trying to exit julia.
    strip_whitespace(ui) = filter(x -> !isspace(x), ui)

    function exit_attempt(ui)
        ui = strip_whitespace(ui)
        str_length = min(4, length(ui)) 
        return lowercase(ui[1:str_length]) == "exit"
    end

    #Internal to JuliaTutor
    include("CrayonBox.jl")
    include("CaptureAndEvaluate.jl")
    #External to JuliaTutor IE user facing
    include("Prompts.jl")

    export greet, inform, request_read_evaluate, evaluate

    #Construct main menu.
    """
        menu()

    Greets an end user, but then prompts them to select a lesson plan from /Lessons/
    Once a lesson is selected(by entering a numerical value) it will load that lesson and begin.
    """
    function menu()
        greet()
        menu_statement = """Please enter the numeral for lesson plan you want to do.
        Note: you can type \"exit\" and press enter at any time to exit this Julia session and JuliaTutor."""
        println( red_bold(), "> ", white_bold(), menu_statement )
        println.( "\t" .* join.( numbered_lessons, ") " ) )
        lesson_to_load = Dict( first.( numbered_lessons ) .=> last.( numbered_lessons ) )
        valid = false
        input = 0
        while !valid
            print( Crayon( foreground = :green, italics = false ), "> " )
            userinput = readline()
            userinput = strip_whitespace( userinput )
            exit_attempt(userinput) && exit()
            numeral = tryparse(Int, userinput)
            if ( ( numeral == "" ) || !haskey( lesson_to_load, numeral ) )
                println( red_italics(), "🔧 Sorry it appears the requested lesson is invalid.")
            else
                valid = true
                input = numeral
                break
            end
        end
        include( Base.joinpath( LESSON_PATH, lessons_available[ input ] ) )
    end
    export menu

end # module
