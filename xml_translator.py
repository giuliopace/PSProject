import xml.etree.ElementTree as ET
import itertools

base_file = """
nrDays = {};
nrWeeks = {};
slotsPerDay = {};

nrClasses = {};


% array giving the number of possible time options for each class
classes_options = {};

% array giving the index of each class in the class_week array
classes_idx = {};

% possible weeks
classes_weeks = {};

% possible days
classes_days = {};

% start and duration of the class
classes_days_sd = {};
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

	## create dzn string from python dict

	# classes_options
	classes_options_s = '['
	for idx, class_ in classes.items():
		classes_options_s += str(len(class_['time_options'])) + ','
	classes_options_s = classes_options_s[:-1] + '];'

	# classes_idx
	classes_idx_s = '['
	id = 1 
	for idx, class_ in classes.items():
		classes_idx_s += str(id) + ','
		id += len(class_['time_options'])
	classes_idx_s = classes_idx_s[:-1] + '];'

	# classes_weeks
	classes_weeks_s = '['
	id = 1 
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_weeks_s += '|'
			for char in option['weeks']:
				if char == '1':
					classes_weeks_s += 'true,'
				else:
					classes_weeks_s += 'false,'
			classes_weeks_s += '\n'
	classes_weeks_s += '|];'

	# classes_days
	classes_days_s = '['
	id = 1 
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_days_s += '|'
			for char in option['days']:
				if char == '1':
					classes_days_s += 'true,'
				else:
					classes_days_s += 'false,'
			classes_days_s += '% class {}\n'.format(idx)
	classes_days_s += '|];'

	# classes_days_sd
	classes_days_sd_s = '['
	id = 1 
	for idx, class_ in classes.items():
		for option in class_['time_options']:
			classes_days_sd_s += '|'
			classes_days_sd_s += str(option['start']) + ','
			classes_days_sd_s += str(option['length']) + ','
			classes_days_sd_s += '\n'
	classes_days_sd_s += '|];'

	return base_file.format(
		str(nr_days),
		str(nr_weeks),
		str(slots_per_day),
		str(len(classes)),
		classes_options_s,
		classes_idx_s,
		classes_weeks_s,
		classes_days_s,
		classes_days_sd_s
	)

xml_file = open("./instances/test_wbg-fal10.xml", "r")
print(convert_xml(xml_file.read()))