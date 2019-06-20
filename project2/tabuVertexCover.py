from parser import *
import numpy as np
import time



def tabuSearch(graph, max_tabu_size, stopping_condition, nr=0):
	'''
		graph contains the graph
		max_tabu_size contains the maximum size of the tabu stack
		stopping_condition is a variable to select the stopping condition:
			can be: time_out, iterations_number, empty_neighborhood, no_improvement (we dont have to do all of them but im just setting them up)
		nr is an auxiliary variable for	stopping_condition (e.g. no_improvement after nr)

		A solution is an array of bools with length=nr of vertices where true means "picked for the vertex cover"
	'''
	#create a random solution (can be all ones)
	fs= createSolution(graph)

	current_best = fs
	best_candidate = fs
	tabulist = []
	tabulist.append(fs)
	curr_iteration_number = 0
	neighborhood_is_empty = False
	no_improvement_counter = 0

	while not stoppingCondition(stopping_condition, nr, curr_iteration_number, neighborhood_is_empty, no_improvement_counter):
		curr_iteration_number += 1

		if neighborhood_is_empty == True:
			tabulist.pop()
			neighborhood_is_empty = False

		neighborhood = getNeighbours(best_candidate)
		if len(neighborhood) == 0:
			neighborhood_is_empty = True

		if neighborhood_is_empty == False:
			for candidate in neighborhood:
				if not contains(tabulist, candidate) and (fitness(candidate) > fitness(best_candidate)):
					if isVertexCover(graph, candidate):
						best_candidate = candidate

			if fitness(best_candidate) > fitness(current_best):
				current_best = best_candidate



				no_improvement_counter = 0
			else:
				no_improvement_counter += 1

			if len(tabulist) == max_tabu_size:
				tabulist.pop()

			tabulist.append(best_candidate)

	return current_best


def createSolution(graph):
	'''
		create a solution with all true (always a valid VC)
	'''
	return np.ones(len(graph.nodes()),dtype=bool)


def stoppingCondition(stopping_condition, nr, curr_iteration_number, neighborhood_is_empty, no_improvement_counter):
	'''
		returns a boolean, true if the stopping condition is reached, false otherwise
	'''
	if stopping_condition == "time_out":
		if nr == 0:
			print('Care: your time_out time is ZERO')

		global firstRun
		timeFirstRun=0
		if firstRun:
			timeFirstRun=time.time()
		else:
			now = time.time()
			if now-time > time_out:
				return True
			else:
				return False



	elif stopping_condition == "iterations_number":

		if nr == 0:
			print('Care: you set 0 iterations')

		if curr_iteration_number == nr:
			return True
		else:
			return False


	elif stopping_condition == "empty_neighborhood":
		if neighborhood_is_empty == True:
			return True
		else:
			return False

	elif stopping_condition == "no_improvement":

		if nr == 0:
			print('Care: your counter is set to zero')

		if no_improvement_counter == nr:
			return True
		else:
			return False


def getNeighbours(solution):
	'''
		returns a vector of neighbours
		one neighbour per vertex, swaps each vertex
	'''
	neighbours = []

	for i in range(len(solution)):
		el = np.copy(solution)
		el[i]=not el[i]
		neighbours.append(el)

	return neighbours


def fitness(solution):
	'''
		for now just wants to maximize the Falses in the solution but still being a Vertex Cover
	'''
	count = 0
	for el in solution:
		if el == False:
			count += 1
	return count


def contains(tabulist, candidate):
	'''
		ŕeturns true if a candidate is in the tabulist
	'''
	for element in tabulist:
		if np.array_equal(element, candidate):
			return True
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



filename = "./instancesPace/vc-exact_031.gr"
graph = parseInstanceFile(filename)
result = tabuSearch(graph, 100, "iterations_number", 10)
print(result)

