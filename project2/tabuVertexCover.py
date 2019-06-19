def tabuSearch(graph, max_tabu_size, stopping_condition, nr=0):
	'''
		graph contains the graph
		max_tabu_size contains the maximum size of the tabu stack
		stopping_condition is a variable to select the stopping condition:
			can be: time, iterations_number, empty_neighborhood, no_improvement (we dont have to do all of them but im just setting them up)
		nr is an auxiliary variable for	stopping_condition (e.g. no_improvement after nr)

		A solution is an array of 1s and 0s with length=nr of vertices where 1 means "picked for the vertex cover"
	'''
	#create a random solution (can be all ones)
	rs= createRandomSolution(graph)

	current_best = rs
	best_candidate = rs
	tabulist = []
	tabulist.push(rs)

	while (not stoppingCondition(stopping_condition)):

		neighborhood = getNeighbors(best_candidate)

		for (candidate in neighborhood)
			if ( (not tabulist.contains(candidate)) and (fitness(candidate) > fitness(best_candidate)) ):
				best_candidate = candidate

		if (fitness(best_candidate) > fitness(current_best)):
			current_best = best_candidate


		if (tabulist.size = max_tabu_size):
			tabulist.removeFirst()

		tabulist.push(best_candidate)

	return current_best

def createRandomSolution(graph):
	'''
		does what you expect it to do
	'''
	#TODO

def stoppingCondition(stopping_condition, nr, probablyotherstufftopassfromtabuSearch):
	'''
		returns a boolean, true if the stopping condition is reached, false otherwise
	'''
	#TODO

def getNeighbours(solution):
	'''
		returns a vector of neighbours
		one neighbour per vertex, swaps each vertex
	'''

def fitness(solution):
