from parser import *
import numpy as np
import time
import random
import sys


def tabuSearch(graph, max_tabu_size, time_out, max_iterations, no_improvement):
	'''
		graph contains the graph
		max_tabu_size contains the maximum size of the tabu stack
		stopping_condition is a variable to select the stopping condition:
			can be: time_out, iterations_number, empty_neighborhood, no_improvement (we dont have to do all of them but im just setting them up)
		nr is an auxiliary variable for	stopping_condition (e.g. no_improvement after nr)

		A solution is an array of bools with length=nr of vertices where true means "picked for the vertex cover"
	'''
	#create a random solution (can be all ones)
	fs = createSolution(graph)
	print('Starting soltion: %s' % fs)
	starting_time = time.time()

	current_best = fs
	best_candidate = fs
	tabulist = []
	tabulist.append(fs)


	curr_iteration_number = 0
	neighborhood_is_empty = False
	no_improvement_counter = 0

	while stoppingCondition(time_out, max_iterations, no_improvement, curr_iteration_number, neighborhood_is_empty, no_improvement_counter, starting_time) == 0 :
		curr_iteration_number += 1
		if neighborhood_is_empty == True:
			tabulist.pop(0)
			neighborhood_is_empty = False

		neighborhood, fitnesses = getNeighbours(best_candidate)
		if len(neighborhood) == 0:
			neighborhood_is_empty = True
			print("Neighborhood is empty!")

		if neighborhood_is_empty == False:
			cur_best_candidate = createSolutionOfTrues(graph)
			bestfitness = 0
			for candidate, curfitness in zip(neighborhood, fitnesses):
				if (curfitness > bestfitness) and not contains(tabulist, candidate):
					#print('Iteration nr %s and current best candidate is %s.' % (curr_iteration_number, best_candidate))
					if isVertexCover(graph, candidate):
						bestfitness = curfitness
						cur_best_candidate = candidate

			best_candidate = cur_best_candidate

			if fitness(best_candidate) > fitness(current_best):
				current_best = best_candidate
				no_improvement_counter = 0

				print('Iteration nr %s and current best is %s.' % (curr_iteration_number, current_best))

			else:
				no_improvement_counter += 1
				print("Result not improved for %s iterations. explored: %s" % (no_improvement_counter, best_candidate))

			if len(tabulist) == max_tabu_size:
				tabulist.pop(0)

			tabulist.append(best_candidate)

	running_time = time.time() - starting_time
	print("Total running time: %s" % (running_time))
	print("Total iterations: %s" % curr_iteration_number)

	#printing stopping condition
	stopping_condition = stoppingCondition(time_out, max_iterations, no_improvement, curr_iteration_number, neighborhood_is_empty, no_improvement_counter, starting_time)
	if stopping_condition == 1:
		print("Stopped by time out")

	elif stopping_condition == 2:
		print("Stopped after %s iterations" % curr_iteration_number)

	elif stopping_condition == 3:
		print("Stopped because of empty neighborhood")

	elif stopping_condition == 4:
		print("Stopped because there was no improvement for %s iterations." % no_improvement_counter)

	return current_best

def random_bool_generator(percent=50):
    return random.randrange(100) < percent

def createSolutionOfTrues(graph):
	'''
		create a solution with all true (always a valid VC)
	'''
	return np.ones(len(graph.nodes()),dtype=bool)


def createSolution(graph):
	'''
		tries to create a random solution. if he doesnt manage to find one that is a vertex cover in 10 attempts, returns a solution of trues
	'''
	starting_time = time.time()
	starting_percent = 82
	for j in range(1,5):
		for i in range(1,20):
			solution = np.empty(len(graph.nodes()),dtype=bool)
			for it in range(len(solution)):
				solution[it] = random_bool_generator(starting_percent + (j*3))

			if isVertexCover(graph, solution):
				curr_time = time.time() - starting_time
				print('Time to create a starting solution is %s and you found a random solution in %s attempts (percentage = %s)' % (curr_time, i*j, starting_percent + (j*3)))
				return solution

	curr_time = time.time() - starting_time
	print('Time to create a starting solution is %s and you have a solution of trues' % curr_time)
	return createSolutionOfTrues(graph)


def stoppingCondition(time_out, max_iterations, no_improvement, curr_iteration_number, neighborhood_is_empty, no_improvement_counter, starting_time):
	'''
		returns 0 if no stop, 1 if it stops for timeout, 2 for iteration numbers, 3 empty_neighborhood, 4 no_improvement

	'''
	now = time.time()
	if now - starting_time > time_out:
		return 1

	if curr_iteration_number >= max_iterations:
		return 2

	if neighborhood_is_empty == True:
		return 3

	#this is probably never reached (at least in our examples)

	if no_improvement_counter >= no_improvement:
		return 4

	return 0


def getNeighbours(solution):
	'''
		returns a vector of neighbours
		one neighbour per vertex, swaps each vertex
	'''
	neighbours = []

	base_fitness = fitness(solution)

	fitnesses = []

	for i in range(len(solution)):
		el = np.copy(solution)
		el[i]=not el[i]
		if el[i] == False:
			fitnesses.append(base_fitness+1)
		else:
			fitnesses.append(base_fitness-1)
		neighbours.append(el)

	return neighbours, fitnesses


def fitness(solution):
	'''
		one point for each False in the solution (for now)
	'''
	count = 0
	for el in solution:
		if el == False:
			count += 1
	return count


def contains(tabulist, candidate):
	'''
		returns true if a candidate is in the tabulist
	'''
	for element in tabulist:
		if (element==candidate).all():
			return True
		#print(t2-t1)
		#input("wefipwjefpowjefpowjefpoj")
	return False


def isVertexCover(graph, solution):
	'''
		returns true if the solution is a vertex cover for the graph
	'''
	#check for every edge: if none of the two vertices is marked as True in the solution we return false. If we never return false it means that every edge is covered so i return true
	for edge in graph.edges:
		a, b = map(list,zip(edge))
		if solution[a] == False and solution[b] == False:
			return False

	return True


# default params
filename = "./instancesPace/vc-exact_007.gr"
tabulistLength = 200
timeout = 60
max_iter = 1000
no_improvement = 500
helpMsg = """Parameters:
-f [str] : filename
-t [int] : timeout (seconds)
-i [int] : max number of iterations 
-n [int] : max number of iterations without improvement
-h       : print this help message
"""


# param parsing 
params = sys.argv[1:]
while(len(params)>0):
	param = params.pop(0)
	if len(params)>0 and param=="-f":
		filename = params.pop(0)
	elif len(params)>0 and param=="-t":
		timeout = int(params.pop(0))
	elif len(params)>0 and param=="-i":
		max_iter = int(params.pop(0))
	elif len(params)>0 and param=="-n":
		no_improvement = int(params.pop(0))
	elif param=="-h":
		print(helpMsg)
		sys.exit(0)

# processing
graph = parseInstanceFile(filename)
print('Graph created successfully')
result = tabuSearch(graph, tabulistLength, timeout, max_iter, no_improvement) #parameters are tabu size, time_out, iterations, no improvement
fitness = fitness(result)

print("The best result is %s, with a fitness of %s " % (result, fitness))
