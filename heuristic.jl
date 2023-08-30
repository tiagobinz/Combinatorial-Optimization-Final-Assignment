using JuMP
using GLPK
using Formatting
using BenchmarkTools
using StatsBase

# Read file (passed as command line argument)
println("Reading file...")
file_contents = readlines(ARGS[1])

# Read the number of teams
println("Parsing file...")
n = parse(Int32, file_contents[1])
splice!(file_contents, 1)   # Remove it from the array

# Read the costs
C = zeros(Float64, n-1, n, n)
for l in file_contents

    # Match regular expression to file line
    line_regex = r" *(\d+) *(\d+) *(\d+) *(\d+\.\d+)"
    regex_match = match(line_regex, l)

    # Read file line components (add 1 to indices, since they are 1-based)
    i = parse(Int32, regex_match[1]) + 1
    j = parse(Int32, regex_match[2]) + 1
    r = parse(Int32, regex_match[3]) + 1
    c = parse(Float64, regex_match[4])

    # Fill the matrix symmetrically
    C[r, i, j] = c
    C[r, j, i] = c
end

# Eliminate the part below the main diagonal (otherwise the result would be doubled)
for r in 1:n-1
    for i in 1:n
        for j in 1:i
            C[r, i, j] = 0.0
        end
    end
end

# Declare variables x_rij
println("Declaring variables...")
x = zeros(Int, n-1, n, n)

# Declare objective: minimize cost
println("Declaring objective...")
function z(x)
    sum(x[r, i, j]*C[r, i, j] for r in 1:n-1, i in 1:n, j in 1:n)
end

# Declare the greedy algorithm for local search
println("Declaring greedy algorithm...")
function greedy()
    can_continue = true
    while (can_continue)

        # Indices of the best local neighbor
        min_c = typemax(Int)   # Value
        min_r = 0   # Round index
        min_i = 0   # Team A index
        min_j = 0   # Team B index
        global can_continue = false    # Will be set to true if a neighbor is found

        # Loop through every coefficient in the upper part of the matrix
        for r in 1:n-1
            for i in 1:n
                for j in (i+1):n
                    # Is this the smallest coefficient for a variable that is not set?
                    if (C[r, i, j] < min_c) & x[r, i, j] == 0
                        # 1st restriction: Play against every other team exactly once
                        if sum(x[:,i,j]) == 0
                            # 2nd restriction: Every line should add to 1
                            if sum(x[r, i, :]) == 0
                                min_c = C[r, i, j]
                                min_r = r
                                min_i = i
                                min_j = j
                                global can_continue = true
                            end
                        end
                    end
                end
            end
        end

        # Found a new variable to switch
        if can_continue
            x[min_r, min_i, min_j] = 1
            x[min_r, min_j, min_i] = 1
        else
            return
        end
    end
end;

# Declare the method of destruction
println("Declaring destruction algorithm...")
destruction_size = 3
function destroy()
    
    available_numbers = Set(1:n)
    random_teams = Int[]
    
    while length(available_numbers) > 0 & length(random_teams) < destruction_size
        selected_number = rand(available_numbers)
        push!(random_teams, selected_number)
        delete!(available_numbers, selected_number)
        if length(random_teams) >= destruction_size
            break
        end
    end

    #println("Elements of the integer array:")
    for element in random_teams
        #println(element)
    end

    for i in random_teams
        for r in 1:n-1
            for j in 1:n
                x[r, i, j] = 0
                x[r, j, i] = 0
            end
        end
    end
end

# Generate the initial solution
println("Finding the initial solution...")
greedy()

# Store the initial solution
best_z = z(x)
best_x = copy(x)
printfmt("Initial best: {:.2f}.\n", best_z)

for i in 1:100
    destroy()
    greedy()
    new_z = z(x)
    if (new_z < best_z)
        global best_z = new_z
        best_x = copy(x)
    end
    printfmt("New z: {:.2f}.\n", new_z)
end

for r in 1:n-1
    printfmt("Round {1:d}.\n", r)
    for i in 1:n
        for j in 1:n
            print(x[r, i, j])
            print(" ")
        end
        print("\n")
    end
    print("\n")
end