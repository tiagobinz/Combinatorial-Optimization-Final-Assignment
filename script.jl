using JuMP
using GLPK
using Formatting
using BenchmarkTools

# Read file (passed as command line argument)
file_contents = readlines(ARGS[1])

# Read the number of teams
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

# Create model
m = Model()
set_optimizer(m, GLPK.Optimizer)

# Declare variables x_rij
@variable(
    m,
    0 <= x[r=1:n-1, i=1:n, j=1:n] <= 1,
    #x[r=1:n-1, i=1:n, j=1:n],
    Int
)

# Declare objective: minimize cost
@objective(
    m,
    Min,

    # It's divided by two because the matrix is redundant, symmetrical
    sum(x[r, i, j]*C[r, i, j] for r in 1:n-1, i in 1:n, j in 1:n) / 2
)

# Teams don't play against themselves
@constraint(m, sum(x[r, i, i] for r in 1:n-1, i in 1:n) == 0) 

# Play against every other team exactly once
for i in 1:n
    for j in 1:n
        if i != j
            @constraint(m, sum(x[:,i,j]) == 1)
        end
    end
end

# Every line should sum to 1
for r in 1:n-1
    for i in 1:n
        @constraint(m, sum(x[r, i, :]) == 1)
    end
end

# Every column should sum to 1
for r in 1:n-1
    for j in 1:n
        @constraint(m, sum(x[r,:,j]) == 1)
    end
end

# The variables should be symmetrical
for r in 1:n-1
    for i in 1:n
        for j in 1:n
            @constraint(m, x[r, i, j] == x[r, j, i])
        end
    end
end

#println(m)
@btime optimize!(m)
printfmt("O custo mínimo é {:.2f}.\n",objective_value(m))