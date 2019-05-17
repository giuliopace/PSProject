import xml.etree.ElementTree as ET
import itertools
import sys
from array import *

base_file = """
nrDays = {};
nrWeeks = {};
slotsPerDay = {};

nrClasses = {};
nrStudents = 1; %temporary
nrRooms = {};

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
students_pref_idx = {}

%students_pref_cnt
students_pref_cnt = {}

%students_pref (first value is a course, second value is the student id of the student that wants to attend it)
students_pref = {};

%class_info
class_info = {}

"""

def convert_xml(xml_string):
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

	## create dzn string from python dict

	classes_courses = {}
	courses = problem.find('courses')
	for course in courses:
		for config in course:
			for subpart in config:
				for class_ in subpart:
					id = class_.attrib['id']
					classes_courses[id] = {}
					if ('parent' in class_.attrib):
						classes_courses[id]['parent'] = class_.attrib['parent']
					else:
						#classes_courses[id]['parent'] = [id]
						classes_courses[id]['parent'] = '0'

					classes_courses[id]['subpart'] = subpart.attrib['id']
					classes_courses[id]['config'] = config.attrib['id']
					classes_courses[id]['course'] = course.attrib['id']




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
	flag = 1
	for idx, student in students.items():

		if flag == 1:
			flag = 0
		else:
			students_pref_cnt_s += str(cnt_count) + ','

		cnt_count = 0
		students_pref_idx_s += str(idx_count) + ','

		for course in student:
			#print(student[id])
			students_pref += '|'
			students_pref += str(course) + ','
			students_pref += '% student {}\n'.format(idx)
			students_pref += '\n'

			idx_count += 1
			cnt_count += 1


	students_pref += '|]'
	students_pref_idx_s += str(idx_count) + ']'
	students_pref_cnt_s += str(cnt_count) + ']'

	#class_info

	class_info = '['

#	print('printing classes')
#	print(classes_courses)

	for idx, class_el in classes_courses.items():
		class_info += '|'
		class_info += str(class_el['parent']) + ','
		class_info += str(class_el['subpart']) + ','
		class_info += str(class_el['config']) + ','
		class_info += str(class_el['course']) + ','
		class_info += '\n'
	class_info += '|]'

	print('printing class_info')
	print(class_info)


	return base_file.format(
		str(nr_days),
		str(nr_weeks),
		str(slots_per_day),
		str(len(classes)),
		str(len(rooms)),
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
		classes_days_sd_s
	)

"""
room_capacities = {};

% array giving the number of unavailabilities per room
room_unav_cnt = {};

% array giving the index of each room in the unavailabilities array
rooms_unav_idx = {};

"""

filename = sys.argv[1]
xml_file = open(filename, "r")
print(convert_xml(xml_file.read()))
