import sys
import re
import random
import time

NO_IMPROVEMENT_LIMIT = 100


# Circle Method (https://en.wikipedia.org/wiki/Round-robin_tournament)
def generate_first_solution():
    upper_line = [i for i in range(int(n/2))]
    lower_line = [i for i in range(int(n/2), n)]
    lower_line = lower_line[::-1]

    for r in range(n-1):
        # Record this in the solution matrix
        for pair in range(int(n/2)):
            x[r][upper_line[pair]][lower_line[pair]] = 1
            x[r][lower_line[pair]][upper_line[pair]] = 1

        # Save the last element of the upper line, since we'll lose it
        upper_last_element_temp = upper_line[int(n / 2) - 1]

        # Shift the upper line elements to the right
        for i in range(int(n / 2) - 1, 0, -1):
            upper_line[i] = upper_line[i - 1]

        # Pull up the first element from the lower list
        upper_line[1] = lower_line[0]

        # Shift the lower line elements to the left
        for i in range(0, int(n / 2) - 1):
            lower_line[i] = lower_line[i + 1]

        # Push down the last element of the upper line
        lower_line[int(n / 2) - 1] = upper_last_element_temp


def objective_function(solution):
    # Calculate the current total cost
    cost = 0.0
    for r in range(n-1):
        for i in range(n):
            for j in range(i+1,n):
                cost += C[r][i][j] * x[r][i][j]

    return cost


def local_search(current_best_value):
    improved = True
    while improved:
        pairs_copy = possible_pairs[:]
        improved = False
        while not improved and len(pairs_copy) > 0:
            random_element_index = random.randint(0, len(pairs_copy)-1)
            chosen_pair = pairs_copy.pop(random_element_index)
            swap_teams(chosen_pair[0], chosen_pair[1])
            new_value = objective_function(x)
            if new_value < current_best_value:
                current_best_value = new_value
                improved = True
            else:
                swap_teams(chosen_pair[0], chosen_pair[1])
    return current_best_value


def agitate_solution():
    pairs_copy = possible_pairs[:]
    for _ in range(min(len(possible_pairs), agitation)):
        random_element_index = random.randint(0, len(pairs_copy)-1)
        chosen_pair = pairs_copy.pop(random_element_index)
        swap_teams(chosen_pair[0], chosen_pair[1])


def swap_teams(team_a, team_b):
    for r in range(n-1):
        if x[r][team_a][team_b] == 0:
            for j in range(n):
                team_a_value = x[r][team_a][j]
                team_b_value = x[r][team_b][j]
                x[r][team_a][j] = team_b_value
                x[r][j][team_a] = team_b_value
                x[r][team_b][j] = team_a_value
                x[r][j][team_b] = team_a_value


def print_solution():
    for r in range(n-1):
        print(f"Round {r}")
        for i in range(n):
            for j in range(n):
                print(f"{x[r][i][j]} ", end="")
            print("")


if __name__ == '__main__':
    # Read file (passed as command line argument)
    print("Reading file...")
    f = open(sys.argv[1], "r")
    file_contents = f.readlines()

    # Read the number of teams
    print("Parsing file...")
    n = int(file_contents[0])
    del file_contents[0]    # Remove it from the array

    # Read the costs
    C = [[[0.0 for _ in range(n)] for _ in range(n)] for _ in range(n - 1)]
    for line in file_contents:
        # Match regular expressions to file line
        regex_match_integers = re.findall(r'\d+', line)
        regex_match_floats = re.findall(r'\d+\.\d+', line)

        # Read file line components
        i = int(regex_match_integers[0])
        j = int(regex_match_integers[1])
        r = int(regex_match_integers[2])
        c = float(regex_match_floats[0])

        # Fill the matrix symmetrically
        C[r][i][j] = c
        C[r][j][i] = c

    # Eliminate the part below the main diagonal (otherwise the result would be doubled)
    for r in range(n-1):
        for i in range(n):
            for j in range(i):
                C[r][i][j] = 0.0

    # Declare variables x_rij
    x = [[[0 for _ in range(n)] for _ in range(n)] for _ in range(n - 1)]

    # Generate all the possible pairs
    possible_pairs = []
    for i in range(n):
        for j in range(i + 1, n):
            possible_pairs.append((i, j))

    # Initialize the counter of "no improvements"
    no_improvements = 0

    # Initial number of steps in an agitation of the solution
    agitation = n

    # Generate the initial solution
    print("Generating first solution...")
    generate_first_solution()

    # Get the first solution value
    s = objective_function(x)
    best_s = s

    # Do iterated local search
    print("Executing heuristic...")
    start = time.time()
    while no_improvements < NO_IMPROVEMENT_LIMIT:
        new_s = local_search(s)
        no_improvements += 1
        if new_s < best_s:
            best_s = new_s
            no_improvements = 0
        else:
            agitation += 1
        agitate_solution()
        s = objective_function(x)
    end = time.time()
    print(end - start)
    print(f"Best solution: {best_s}")