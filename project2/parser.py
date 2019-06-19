import networkx as nx
import numpy as np

def parseInstanceFile(instanceFilePath):
	"""
		Reads a Pace instance file containing an instance of the Vertex cover problem.
		The file format is described here: https://pacechallenge.org/2019/vc/vc_format/
		The instance is converted into a networkx Digraph instance

		Arguments
		---------

		instanceFilePath : str
			Path of the instance file to parse.

		Returns
		-------

		instance : nx.Graph
			Networkx Graph structure containing the graph
	"""
	file = open(instanceFilePath,"r")

	graph = nx.DiGraph()

	# parse info about edges and vertices
	line = file.readline()
	numVertices = 0
	numEdges = 0
	if line.startswith("p td "):
		dat = line[len("p td "):-1].split()
		numVertices = int(dat[0])
		numEdges = int(dat[1])
	else:
		raise Exception('{} is not a proper STP file: does not contain proper first line identifier.'.format(instanceFilePath))
	
	# create nodes
	graph.add_nodes_from(range(numVertices))

	# parse edges
	line = file.readline()
	edges = np.empty((numEdges, 2), dtype=int)
	i=0
	while line:
		dat = line.split()
		edges[i][0]=int(dat[0])
		edges[i][1]=int(dat[1])
		i+=1
		line = file.readline()

	# add edges to the graph
	graph.add_edges_from([(data[0], data[1]) for data in edges])

	return graph