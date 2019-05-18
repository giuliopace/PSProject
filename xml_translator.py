import json
import re
from lxml import etree as ET
import itertools
import sys
from array import *

base_file = """
nrDays = {};
nrWeeks = {};
slotsPerDay = {};

nrClasses = {};
nrStudents = {};
nrRooms = {};
nrCourses = {};

% array giving the number of possible time options for each class
classes_options = {};

% array giving the index of each class in the class_week array
classes_idx = {};

% possible weeks
classes_weeks_input = {};

% possible days
classes_days_input = {};

% start and duration of the class
classes_slots_input = {};

% options penalty
classes_penalties_input = {};

% array giving the number of room options for each class
classes_rooms_cnt = {};

% array giving the index of each class in the class_room array
classes_rooms_idx = {};

% options penalty (first value is the class index, second is the associated penalty)
classes_rooms_input = {};

% array giving the number of unavailabilities per room
rooms_unav_cnt = {};

% array giving the index of each room in the unavailabilities array
rooms_unav_idx = {};

room_capacities_input = {};

% possible weeks
rooms_unav_weeks_input = {};

% possible days
rooms_unav_days_input = {};

% start and duration of the class
rooms_unav_slots_input = {};

% traveltime adjacency matrix
travel_adj_mat_input = {};

%students_pref_idx
student_pref_idx = {};

%students_pref_cnt
student_pref_cnt = {};

%students_pref (first value is a course, second value is the student id of the student that wants to attend it)
student_pref_input = {};

%class_hierarchy_input(index->class: parent|subpart|config|course)
class_hierarchy_input = {};

%class_limit_input
class_limit_input = {};

%number of configurations
nrConfigs = {};

%configs_cnt_s
configs_cnt = {};

%configs_idx_s
configs_idx = {};



%%% Distribution data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{}

"""


distributionConstraints = [
	["SameStart",0],
	["SameTime",0],
	["DifferentTime",0],
	["SameDays",0],
	["DifferentDays",0],
	["SameWeeks",0],
	["DifferentWeeks",0],
	["SameRoom",0],
	["DifferentRoom",0],
	["Overlap",0],
	["NotOverlap",0],
	["SameAttendees",0],
	["Precedence",0],
	["WorkDay",1],
	["MinGap",1],
	["MaxDays",1],
	["MaxBreaks",2],
	["MaxBlock",2]
]

def convert_xml_to_dzn(xml_string):
	"""
		returns a conversion of the xml instance to the dzn format

		Note: as of now, only the time constraints are translated

		Arguments
		---------

		xml_string : str
			string containing the xml data to convert

		Returns
		---------

		dzn_string : str
			string contaning the converted instance in the dzn format
	"""
	# convert string to xml tree object
	problem = ET.fromstring(xml_string)

	## parse information into a python dict from the xml tree

	# problem info
	nr_weeks = int(problem.attrib['nrWeeks'])
	nr_days = int(problem.attrib['nrDays'])
	slots_per_day = int(problem.attrib['slotsPerDay'])


	# room info
	rooms = {}
	rooms_node = problem.find('rooms')
	for room in rooms_node:
		id = room.attrib['id']
		rooms[id] = {}
		rooms[id]['capacity'] = int(room.attrib['capacity'])
		rooms[id]['unavailabilities'] = []
		for unav in room.findall("unavailable"):
			u = {}
			u['days'] = unav.attrib['days']
			u['weeks'] = unav.attrib['weeks']
			u['start'] = int(unav.attrib['start'])
			u['length'] = int(unav.attrib['length'])
			rooms[id]['unavailabilities'].append(u)

	students = {}
	students_node = problem.find('students')
	for student in students_node:
		id = student.attrib['id']
		students[id] = []
		for course in student:
			students[id].append(int(course.attrib['id']))


	# init traveltime adjacency matrix

	traveltime = [[0 for x in range(len(rooms))] for y in range(len(rooms))]

	for room in rooms_node:
		id = int(room.attrib['id'])
		for travel in room.findall("travel"):
			oid = int(travel.attrib['room'])
			dist = int(travel.attrib['value'])
			traveltime[id-1][oid-1] = dist
			traveltime[oid-1][id-1] = dist

	# classes info
	classes = {}
	courses = problem.find('courses')
	for course in courses:
		for config in course:
			for subpart in config:
				for class_ in subpart:
					id = class_.attrib['id']
					classes[id] = {}
					classes[id]['limit'] = class_.attrib['limit']

					classes[id]['time_options'] = []
					for time_option in class_.findall('time'):
						opt = {}
						opt['days'] = time_option.attrib['days']
						opt['weeks'] = time_option.attrib['weeks']
						opt['start'] = int(time_option.attrib['start'])
						opt['length'] = int(time_option.attrib['length'])
						opt['penalty'] = int(time_option.attrib['penalty'])
						classes[id]['time_options'].append(opt)

					classes[id]['rooms'] = []
					for room in class_.findall("room"):
						r = {}
						r['id'] = room.attrib['id']
						r['penalty'] = room.attrib['penalty']
						classes[id]['rooms'].append(r)

	# distribution constraint
	distributions = {}
	distribs_node = problem.find("distributions")
	for distrib_node in distribs_node:

		# Parsing distribution informations
		distrib = {}
		required = True
		penalty = 0
		if "penalty" in distrib_node.attrib:
			required = False
			penalty = int(distrib_node.attrib["penalty"])

		# distrib name
		d_type = distrib_node.attrib["type"]

		# if some info is stored in the name, retrieve it
		if re.match("MaxBreaks\((.*),(.*)\)", d_type):
			matchres = re.search("MaxBreaks\((.*),(.*)\)", d_type)
			nr1 = matchres.group(1)
			nr2 = matchres.group(2)
			d_type = "MaxBreaks"
			distrib["nr1"] = nr1
			distrib["nr2"] = nr2

		# if some info is stored in the name, retrieve it
		if re.match("MaxBlock\((.*),(.*)\)", d_type):
			matchres = re.search("MaxBlock\((.*),(.*)\)", d_type)
			nr1 = matchres.group(1)
			nr2 = matchres.group(2)
			d_type = "MaxBlock"
			distrib["nr1"] = nr1
			distrib["nr2"] = nr2	

		# if some info is stored in the name, retrieve it
		if re.match("MaxDays\((.*)\)", d_type):
			matchres = re.search("MaxDays\((.*)\)", d_type)
			nr1 = matchres.group(1)
			d_type = "MaxDays"
			distrib["nr1"] = nr1

		# if some info is stored in the name, retrieve it
		if re.match("WorkDay\((.*)\)", d_type):
			matchres = re.search("WorkDay\((.*)\)", d_type)
			nr1 = matchres.group(1)
			d_type = "WorkDay"
			distrib["nr1"] = nr1

		# if some info is stored in the name, retrieve it
		if re.match("MinGap\((.*)\)", d_type):
			matchres = re.search("MinGap\((.*)\)", d_type)
			nr1 = matchres.group(1)
			d_type = "MinGap"
			distrib["nr1"] = nr1

		# if some info is stored in the name, retrieve it
		if re.match("MaxDayLoad\((.*)\)", d_type):
			matchres = re.search("MaxDayLoad\((.*)\)", d_type)
			nr1 = matchres.group(1)
			d_type = "MaxDayLoad"
			distrib["nr1"] = nr1
		
		if d_type not in distributions:
			distributions[d_type] = []

		distrib["required"] = required
		distrib["penalty"] = penalty
		distrib["classes"] = []
		for class_ in distrib_node:
			id = int(class_.attrib["id"])
			distrib["classes"].append(id)

		distributions[d_type].append(distrib)

	## create dzn string from python dict

	classes_courses = {}
	configs = {}
	courses = problem.find('courses')
	for course in courses:
		for config in course:
			configs[config.attrib['id']] = []
			for subpart in config: 
				configs[config.attrib['id']].append(subpart.attrib['id'])
				for class_ in subpart:
					id = class_.attrib['id']
					classes_courses[id] = {}
					if ('parent' in class_.attrib):
						classes_courses[id]['parent'] = class_.attrib['parent']
					else:
						classes_courses[id]['parent'] = class_.attrib['id']

					classes_courses[id]['subpart'] = subpart.attrib['id']
					classes_courses[id]['config'] = config.attrib['id']
					classes_courses[id]['course'] = course.attrib['id']
					classes_courses[id]['limit'] = class_.attrib['limit']




	# classes_options
	classes_options_s = '['
	for idx, class_ in classes.items():
		classes_options_s += str(len(class_['time_options'])) + ','
	classes_options_s = classes_options_s[:-1] + ']'

	# classes_idx
	classes_idx_s = '['
	id = 1
	for idx, class_ in classes.items():
		classes_idx_s += str(id) + ','
		id += len(class_['time_options'])
	classes_idx_s = classes_idx_s[:-1] + ']'

	# classes_weeks
	classes_weeks_s = '['
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_weeks_s += '|'
			for char in option['weeks']:
				if char == '1':
					classes_weeks_s += 'true,'
				else:
					classes_weeks_s += 'false,'
			classes_weeks_s += '\n'
	classes_weeks_s += '|]'

	# classes_days
	classes_days_s = '['
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_days_s += '|'
			for char in option['days']:
				if char == '1':
					classes_days_s += 'true,'
				else:
					classes_days_s += 'false,'
			classes_days_s += '% class {}\n'.format(idx)
	classes_days_s += '|]'

	# classes_days_sd
	classes_days_sd_s = '['
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_days_sd_s += '|'
			classes_days_sd_s += str(option['start']) + ','
			classes_days_sd_s += str(option['length']) + ','
			classes_days_sd_s += '\n'
	classes_days_sd_s += '|]'

	# classes_penalty
	classes_penalty_s = '['
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_penalty_s += str(option['penalty']) + ','
	classes_penalty_s = classes_penalty_s[:-1] + ']'


	# classes_rooms_cnt
	classes_rooms_cnt_s = '['
	for idx, class_ in classes.items():
		classes_rooms_cnt_s += str(len(class_['rooms'])) + ','
	classes_rooms_cnt_s = classes_rooms_cnt_s[:-1] + ']'

	# classes_rooms_idx
	classes_rooms_idx_s = '['
	id = 1
	for idx, class_ in classes.items():
		classes_rooms_idx_s += str(id) + ','
		id += len(class_['rooms'])
	classes_rooms_idx_s = classes_rooms_idx_s[:-1] + ']'

	# class_rooms
	classes_rooms_s = '['
	for idx, class_ in classes.items():
		for room in class_['rooms']:
			classes_rooms_s += '|'
			classes_rooms_s += str(room['id']) + ','
			classes_rooms_s += str(room['penalty']) + ','
			classes_rooms_s += '\n'
	classes_rooms_s += '|]'


	# room capacity
	rooms_capacity_s = '['
	for idx, room in rooms.items():
		rooms_capacity_s += str(room['capacity']) + ','
	rooms_capacity_s = rooms_capacity_s[:-1] + ']'

	# room unav cnt
	rooms_unav_cnt_s = '['
	for idx, room in rooms.items():
		rooms_unav_cnt_s += str(len(room['unavailabilities'])) + ','
	# add a virtual room with 0 unav (if the class does not need a room)
	rooms_unav_cnt_s += '0]'

	# room unav idx
	rooms_unav_idx_s = '['
	id = 1
	for idx, room in rooms.items():
		rooms_unav_idx_s += str(id) + ','
		id += len(room['unavailabilities'])
	# add a virtual room with index 0 (if the class does not need a room)
	rooms_unav_idx_s += '1]'

	# rooms_unav_weeks
	rooms_unav_weeks_s = '['
	for idx, class_ in rooms.items():
		for option in class_['unavailabilities']:
			rooms_unav_weeks_s += '|'
			for char in option['weeks']:
				if char == '1':
					rooms_unav_weeks_s += 'true,'
				else:
					rooms_unav_weeks_s += 'false,'
			rooms_unav_weeks_s += '\n'
	rooms_unav_weeks_s += '|]'
	if rooms_unav_weeks_s == "[|]":
		rooms_unav_weeks_s = "[]"

	# rooms_unav_days
	rooms_unav_days_s = '['
	for idx, class_ in rooms.items():
		for option in class_['unavailabilities']:
			rooms_unav_days_s += '|'
			for char in option['days']:
				if char == '1':
					rooms_unav_days_s += 'true,'
				else:
					rooms_unav_days_s += 'false,'
			rooms_unav_days_s += '% room {}\n'.format(idx)
	rooms_unav_days_s += '|]'
	if rooms_unav_days_s == "[|]":
		rooms_unav_days_s = "[]"

	# rooms_unav_slots
	rooms_unav_slots_s = '['
	for idx, class_ in rooms.items():
		for option in class_['unavailabilities']:
			rooms_unav_slots_s += '|'
			rooms_unav_slots_s += str(option['start']) + ','
			rooms_unav_slots_s += str(option['length']) + ','
			rooms_unav_slots_s += '\n'
	rooms_unav_slots_s += '|]'
	if rooms_unav_slots_s == "[|]":
		rooms_unav_slots_s = "[]"

	travel_adj_mat_s = '['
	for x in range(len(rooms)):
		travel_adj_mat_s += '|'
		for y in range(len(rooms)):
			travel_adj_mat_s += str(traveltime[x-1][y-1]) + ','
		travel_adj_mat_s += '\n'
	travel_adj_mat_s += '|]'


	#students_pref, students_pref_idx and students_pref_cnt_s

	students_pref = '['
	students_pref_idx_s = '['
	students_pref_cnt_s = '['

	idx_count = 1
	cnt_count = 0
	flag = 1
	for idx, student in students.items():

		if flag == 1:
			flag = 0
		else:
			students_pref_cnt_s += str(cnt_count) + ','

		cnt_count = 0
		students_pref_idx_s += str(idx_count) + ','

		for course in student:
			students_pref += str(course) + ','

			idx_count += 1
			cnt_count += 1


	students_pref += ']'
	students_pref_idx_s +=  ']'
	students_pref_cnt_s += str(cnt_count) + ']'

	#class_hierarchy_input

	class_hierarchy_input = '['

	for idx, class_el in classes_courses.items():
		class_hierarchy_input += '|'
		class_hierarchy_input += str(class_el['parent']) + ','
		class_hierarchy_input += str(class_el['subpart']) + ','
		class_hierarchy_input += str(class_el['config']) + ','
		class_hierarchy_input += str(class_el['course']) + ','
		class_hierarchy_input += '\n'
	class_hierarchy_input += '|]'


	#class_limit_input

	class_limit_input = '['
	for idx, class_el in classes_courses.items():
		class_limit_input += str(class_el['limit']) + ','
	class_limit_input += ']'

	# distributions
	distrib_string = ""

	# A BIG REFACTOR WOULD BE NECESSARY HERE BUT NO TIME
	for name, param in distributionConstraints:

		if name not in distributions:
			distrib_string+="""
nr{}=0;
nr{}_distrib=0;
{}_idx = [];
{}_cnt = [];
{}_required = [];
{}_penalty = [];
{}_distrib_input = [];
""".format(name, name, name, name, name, name, name)
			if param == 1 or param == 2:
				distrib_string+= name + "_nr1=[];"
			if param == 2:
				distrib_string+= '\n' + name + "_nr2=[];"

			distrib_string+='\n'
			continue

		additionnal = ""
		nr1_array = ""
		nr2_array = ""

		distrib_collection = distributions[name]
		
		if name == "MaxBreaks":
			nr1_array = name + "_nr1 = ["
			nr2_array = name + "_nr2 = ["
		if name == "MaxBlock":
			nr1_array = name + "_nr1 = ["
			nr2_array = name + "_nr2 = ["
		if name == "MaxDays":
			nr1_array = name + "_nr1 = ["
		if name == "WorkDay":
			nr1_array = name + "_nr1 = ["
		if name == "MaxDayLoad":
			nr1_array = name + "_nr1 = ["
		if name == "MinGap":
			nr1_array = name + "_nr1 = ["

		idx_array = name + "_idx = ["
		cnt_array = name + "_cnt = ["
		required_array = name + "_required = ["
		penalty_array = name + "_penalty = ["
		distrib_array = name + '_distrib_input = ['

		id = 1

		for distrib in distrib_collection:

			idx_array += str(id) + ','
			id += len(distrib["classes"])
			cnt_array += str(len(distrib["classes"])) + ','
			
			if distrib["required"] == True:
				required_array +=  'true,'	
			else:
				required_array +=  'false,'

			penalty_array += str(distrib["penalty"]) + ','

			if name == "MaxBreaks":
				nr1_array += str(distrib["nr1"]) + ','
				nr2_array += str(distrib["nr2"]) + ','
			if name == "MaxBlok":
				nr1_array += str(distrib["nr1"]) + ','
				nr2_array += str(distrib["nr2"]) + ','
			if name == "MaxDays":
				nr1_array += str(distrib["nr1"]) + ','
			if name == "WorkDay":
				nr1_array += str(distrib["nr1"]) + ','
			if name == "MaxDayLoad":
				nr1_array += str(distrib["nr1"]) + ','
			if name == "MinGap":
				nr1_array += str(distrib["nr1"]) + ','

			for class_ in distrib["classes"]:
				distrib_array += str(class_) + ','

		idx_array = idx_array[:-1] + ']'
		cnt_array = cnt_array[:-1] + ']'
		required_array = required_array[:-1] + ']'
		penalty_array = penalty_array[:-1] + ']'
		distrib_array = distrib_array[:-1] + ']'

		if name == "MaxBreaks":
			nr1_array = nr1_array[:-1] + ']'
			nr2_array = nr2_array[:-1] + ']'
			additionnal += nr1_array + ';\n' + nr2_array + ';\n'
		if name == "MaxBlock":
			nr1_array = nr1_array[:-1] + ']'
			nr2_array = nr2_array[:-1] + ']'
			additionnal += nr1_array + ';\n' + nr2_array + ';\n'
		if name == "MaxDays":
			nr1_array = nr1_array[:-1] + ']'
			additionnal += nr1_array + ';\n'
		if name == "WorkDay":
			nr1_array = nr1_array[:-1] + ']'
			additionnal += nr1_array + ';\n'
		if name == "MinGap":
			nr1_array = nr1_array[:-1] + ']'
			additionnal += nr1_array + ';\n'
		if name == "MaxDayLoad":
			nr1_array = nr1_array[:-1] + ']'
			additionnal += nr1_array + ';\n'

		distrib_string += additionnal
		distrib_string += "nr" + name + "=" + str(len(distrib_collection)) + ';\n'
		distrib_string += "nr" + name + "_distrib=" + str(sum([len(distrib["classes"]) for distrib in distrib_collection])) + ';\n'
		distrib_string += idx_array + ';\n'
		distrib_string += cnt_array + ';\n'
		distrib_string += required_array + ';\n'
		distrib_string += penalty_array + ';\n'
		distrib_string += distrib_array + ';\n\n'

	#configs_s, configs_idx and configs_cnt

	configs_idx_s = '['
	configs_cnt_s = '['
	id = 1
	for idx, config in configs.items():
		configs_idx_s += str(id) + ','
		configs_cnt_s += str(len(config)) + ','
		id += len(config)
	configs_idx_s = configs_idx_s[:-1] + ']'
	configs_cnt_s = configs_cnt_s[:-1] + ']'
	nrConfigs = str(len(configs))


	return base_file.format(
		str(nr_days),
		str(nr_weeks),
		str(slots_per_day),
		str(len(classes)),
		str(len(students)),
		str(len(rooms)),
		str(len(courses)),
		classes_options_s,
		classes_idx_s,
		classes_weeks_s,
		classes_days_s,
		classes_days_sd_s,
		classes_penalty_s,
		classes_rooms_cnt_s,
		classes_rooms_idx_s,
		classes_rooms_s,
		rooms_unav_cnt_s,
		rooms_unav_idx_s,
		rooms_capacity_s,
		rooms_unav_weeks_s,
		rooms_unav_days_s,
		rooms_unav_slots_s,
		travel_adj_mat_s,
		students_pref_idx_s,
		students_pref_cnt_s,
		students_pref,
		class_hierarchy_input,
		class_limit_input,
		nrConfigs,
		configs_cnt_s,
		configs_idx_s,
		distrib_string
	)

def convert_sol_to_xml(minizinc_output):
	"""
		Returns a conversion from minizinc's output to a
		solution in XML format defined here:

		https://www.itc2019.org/format#solution

		The solution should be printed with the following arguments:

			minizinc model_canvas.mzn tiny_data.dzn --output-mode json --output-time --output-objective

		Arguments
		---------
		minizinc_json : str
			string containing the solution in JSON format

		Returns
		-------
		xml_string : str
			string containing the solution in XML format
	"""
	# extracting running time
	runtime = float(re.search("time elapsed: (.*) s", minizinc_output).group(1))

	# extracting JSON
	json_start = minizinc_output.find('{')
	json_end = minizinc_output.find('}')
	json_string = minizinc_output[json_start:json_end+1]
	data = json.loads(json_string)

	solution = ET.Element("solution",
		name="unique-instance-name",
		runtime=str(runtime),
		technique="CP",
		author="TDGPDP",
		institution="TU Wien",
		country="Austria")

	for weeks, days, students, room, start, duration, i in zip(
			data["classes_weeks"],
			data["classes_days"],
			data["classes_students"],
			data["classes_room"],
			data["classes_start"],
			data["classes_duration"],
			range(len(data["classes_days"]))):
		string_weeks = ""
		for week in weeks:
			if week == True:
				string_weeks += '1'
			else:
				string_weeks += '0'
		string_days = ""
		for day in days:
			if day == True:
				string_days += '1'
			else:
				string_days += '0'
		classe = ET.SubElement(
			solution,
			"class",
			id=str(i+1),
			days=string_days,
			weeks=string_weeks,
			start=str(duration),
			room=str(room))

		for student in students:
			ET.SubElement(classe, "student", id=str(student))

	return ET.tostring(solution, encoding='utf-8', method='xml', pretty_print=True).decode()

filename = sys.argv[2]
option = sys.argv[1]
xml_file = open(filename, "r")

if option in ["-i", "--input"]:
	print(convert_xml_to_dzn(xml_file.read()))
elif option in ["-o", "--output"]:
	print(convert_sol_to_xml(xml_file.read()))
