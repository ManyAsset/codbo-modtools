class Xmodel:
	def __init__(self):
		self.export_name = ''
		self.maya_name = ''
		self.export_date = ''
		self.version = 0
		self.num_bones = 0
		self.num_verts = 0
		self.num_faces = 0
		self.num_objects = 0
		self.num_materials = 0
		self.bones = []
		self.verts = []
		self.faces = []
		self.objects = []
		self.materials = []
		self.empty_type = {'type': 'none', 'data' : 'none'}

	def trimSingleQuotes(self, string): #trims leading and trailing single-quotes from string
		"""Trims the leading and trailing single-quotes from a string.
		
		Returns a string.
		"""
		ret_string = string
		if string[0] == "'":
			ret_string = ret_string[1:]
		if ret_string[-1] == "'":
			ret_string = ret_string[:-1]
		return ret_string
		
	def trimDoubleQuotes(self, string): #trims leading and trailing single-quotes from string
		"""Trims the leading and trailing double-quotes from a string.
		
		Returns a string.
		"""
		ret_string = string
		if string[0] == '"':
			ret_string = ret_string[1:]
		if ret_string[-1] == '"':
			ret_string = ret_string[:-1]
		return ret_string
	
	def trimCommas(self, string): #trims leading and trailing commas from string
		"""Trims the leading and trailing commas from a string.
		
		Returns a string.
		"""
		ret_string = string
		if string[0] == ',':
			ret_string = ret_string[1:]
		if ret_string[-1] == ',':
			ret_string = ret_string[:-1]
		return ret_string
		
	def readBone(self, f_line): # reads bone information: index, parent and name
		"""Parses a bone definition from an xmodel_export file in the form of 'BONE 1 0 \"J_MainRoot\"'.
		
		Returns dictionary {'bone_id' : <int>, 'bone_parent' : <int>, 'bone_name' : <string>}
		"""
		elements = f_line.split()
		if len(elements) < 0:
			return {'bone_id' : 0, 'bone_parent' : -1, 'bone_name' : 'none'}
		return {'bone_id' : int(elements[1]), 'bone_parent' : int(elements[2]), 'bone_name' : self.trimDoubleQuotes(elements[3]), 'bone_data' : None}
		
	def readBoneData(self, file_data, line_num): # reads bone data and adds it to bone list
		"""Parses a multiline bone data from an xmodel_export file.

		Adds dictionary {'index' : <int>, 'offset' : {'x':<float>, 'y':<float>, 'z':<float>}, 
			'scale' : {'x':<float>, 'y':<float>, 'z':<float>},
			'X' : {'x':<float>, 'y':<float>, 'z':<float>}, 
			'Y' : {'x':<float>, 'y':<float>, 'z':<float>}
			'z' : {'x':<float>, 'y':<float>, 'z':<float>}} to class member bones[]
		"""
		new_bone = {'index' : 0, 'offset' : {'x' : 0, 'y': 0, 'z' : 0}, 'scale' : {'x' : 0, 'y': 0, 'z' : 0}, 'X' : {'x' : 0, 'y': 0, 'z' : 0}, 'Y' : {'x' : 0, 'y': 0, 'z' : 0}, 'Z' : {'x' : 0, 'y': 0, 'z' : 0}}
		for j in range(6):
			elements = file_data[line_num].split()
			elements = map(self.trimCommas, elements)
			if len(elements) > 0:
				if elements[0] == 'BONE':
					new_bone['index'] = int(elements[1])
				elif elements[0] == 'OFFSET':
					new_bone['offset']['x'] = float(elements[1])
					new_bone['offset']['y'] = float(elements[2])
					new_bone['offset']['z'] = float(elements[3])
				elif elements[0] == 'SCALE':
					new_bone['scale']['x'] = float(elements[1])
					new_bone['scale']['y'] = float(elements[2])
					new_bone['scale']['z'] = float(elements[3])
				elif elements[0] == 'X':
					new_bone['X']['x'] = float(elements[1])
					new_bone['X']['y'] = float(elements[2])
					new_bone['X']['z'] = float(elements[3])
				elif elements[0] == 'Y':
					new_bone['Y']['x'] = float(elements[1])
					new_bone['Y']['y'] = float(elements[2])
					new_bone['Y']['z'] = float(elements[3])
				elif elements[0] == 'Z':
					new_bone['Z']['x'] = float(elements[1])
					new_bone['Z']['y'] = float(elements[2])
					new_bone['Z']['z'] = float(elements[3])
			line_num += 1
		self.bones[new_bone['index']]['bone_data'] = new_bone
		return line_num
		
	def readBones(self, file_contents, line_num): # reads in all bone data
		"""Reads all the bone data from an xmodel_export file.
		
		Calls readBone and readBoneData methods.
		"""
		for i in range(self.num_bones):
			line_num += 1
			bone = self.readBone(file_contents[line_num])
			self.bones.append(bone)
		line_num += 1
		j = 0
		while j < self.num_bones:
			elements = file_contents[line_num].split()
			if len(elements) == 0:
				line_num += 1
			elif elements[0] == 'BONE':
				line_num = self.readBoneData(file_contents, line_num)
				j += 1
		return line_num
		
	def readVertData(self, file_data, line_num): # reads vert data and appends it to vert list
		"""Reads vertex data and appends it to the vertex list.
		
		Adds dictionary {'index' : <int>, 'offset' : {'x':<float>, 'y':<float>, 'z':<float>}, 
			'bone_count' : <int>,
			'bones' : ['index' : <int>, 'weight : <float>]}
		"""
		new_vert = {'index' : 0, 'offset' : {'x' : 0, 'y': 0, 'z' : 0}, 'bone_count' : 0, 'bones' : []}
		for j in range(3):
			elements = map(self.trimCommas, file_data[line_num].split())
			if len(elements) > 0:
				if elements[0] == 'VERT':
					new_vert['index'] = int(elements[1])
				elif elements[0] == 'OFFSET':
					new_vert['offset']['x'] = float(elements[1])
					new_vert['offset']['y'] = float(elements[2])
					new_vert['offset']['z'] = float(elements[3])
				elif elements[0] == 'BONES':
					new_vert['bone_count'] = int(elements[1])
					line_num += 1
					b = 0
					while b < new_vert['bone_count']:
						weights = file_data[line_num].split()
						if weights[0] == 'BONE':
							new_vert['bones'].append({'index' : int(weights[1]), 'weight' : float(weights[2])})
							b += 1
						line_num += 1
			line_num += 1
		self.verts.append(new_vert)
		return line_num
		
	def readVerts(self, file_contents, line_num): # reads in all vertex data
		"""Reads all vertex data.
		
		Calls readVertexData method.
		"""
		i = 0
		while i < self.num_verts:
			elements = file_contents[line_num].split()
			if len(elements) == 0:
				line_num += 1
			elif elements[0] == 'VERT':
				line_num = self.readVertData(file_contents, line_num)
				i += 1
			else:
				line_num += 1
		return line_num
		
	def readFaceData(self, file_contents, line_num):
		"""Reads face data and appends it to the face list.
		
		Adds dictionary {'tri' : {'object_id' : <int>, 'material_id' : <int>},
			'verts' : [{'index' : 0, 'normal' : {'x' : <float>, 'y' : <float>, 'z' : <float>},
				'color : {'r' : <float>, 'g' : <float>, 'b' : <float>, 'a' : <float>},
				'uvs' : [{'normal' : {'x' : <float>, 'y' : <float>, 'z' : <float>}}]}
		"""
		new_face = {'tri' : {'object_id' : 0, 'material_id' : 0}, 'verts' : []}
		elements = file_contents[line_num].split()
		if elements[0] == 'TRI':
			new_face['tri']['object_id'] = int(elements[1])
			new_face['tri']['material_id'] = int(elements[2])
			line_num += 1
			for i in range(3):
				new_vert = {'index' : 0, 'normal' : {'x' : 0, 'y' : 0, 'z' : 0}, 'color' : {'r' : 0, 'g' : 0, 'b' : 0, 'a' : 0}, 'uv' : {'x' : 0, 'y' : 0, 'z' : 0}}
				components = file_contents[line_num].split() # read vert index
				new_vert['index'] = int(components[1])
				line_num += 1
				components = file_contents[line_num].split() # read vert normal
				new_vert['normal'] = {'x' : float(components[1]), 'y' : float(components[2]), 'z' :float(components[3])}
				line_num += 1
				components = file_contents[line_num].split() # read vert color
				new_vert['color'] = {'r' : float(components[1]), 'g' : float(components[2]), 'b' : float(components[3]), 'a' : float(components[4])}
				line_num += 1
				components = file_contents[line_num].split() # read vert uv
				new_vert['uv'] = {'x' : float(components[1]), 'y' : float(components[2]), 'z' :float(components[3])}
				line_num += 1
				new_face['verts'].append(new_vert)
		else:
			line_num += 1
		self.faces.append(new_face)
		return line_num
				
	def readFaces(self, file_contents, line_num):
		"""Reads all face data.
		
		Calls readFaceData method.
		"""
		i = 0
		while i < self.num_faces:
			elements = file_contents[line_num].split()
			if len(elements) == 0:
				line_num += 1
			elif elements[0] == 'TRI':
				line_num = self.readFaceData(file_contents, line_num)
				i += 1
			else:
				line_num += 1
		return line_num

	def readObject(self, f_line): # reads object information: index and name
		"""Reads object from list.
		
		Returns dictionary: {'object_id' : <int>, 'object_name' : <string>}
		"""
		elements = f_line.split()
		if len(elements) < 0:
			return {'object_id' : 0, 'object_name' : 'none'}
		return {'object_id' : int(elements[1]), 'object_name' : self.trimDoubleQuotes(elements[2])}
			
	def readObjects(self, file_contents, line_num): # reads object list
		"""Reads all objects.
		
		Calls readObject method.
		"""
		for i in range(self.num_objects):
			line_num += 1
			object = self.readObject(file_contents[line_num])
			self.objects.append(object)
		line_num += 1
		return line_num
			
	def readMaterials(self, file_contents, line_num): #reads material list
		"""Reads all materials.
		
		Adds dictionaries: {'index' : <int>, 'name' : <string>, 'image' : <string>} to materials member array.
		"""
		i = 0
		while i < (self.num_materials):
			elements = map(self.trimDoubleQuotes, file_contents[line_num].split())
			if elements[0] == 'MATERIAL':
				self.materials.append({'index' : int(elements[1]), 'name' : elements[2], 'type' : elements[3], 'image' : elements[4]})
				i += 1
			line_num += 1
		return line_num
	def parseLine(self, f_line): # splits string by whitespace and returns type and value
		"""Splits line by white.
		
		Returns dictionary with type and value.
		"""
		empty_type = {'type': 'none', 'data' : 'none'}
		elements = f_line.split()
		if len(elements) == 0:
			return self.empty_type
		if elements[0] == '//': # line in file is commented, usually indicating metadata like source file name
			if elements[1] + elements[2] == 'Exportfilename:': # path and filename of exported file
				return {'type': 'export_file', 'filename' : self.trimSingleQuotes(elements[3])}
			elif elements[1] + elements[2] == 'Sourcefilename:': # path and filename of source file
				return {'type': 'source_file', 'filename' : self.trimSingleQuotes(elements[3])}
			elif elements[1] + elements[2] == 'Exporttime:': # time and date of export
				return {'type' : 'export_date', 'date' : {'day' : elements[3], 'month' : elements[4], 'date' : elements[5], 'time': elements[6], 'year' : elements[7]}}
			else:
				return self.empty_type
		elif elements[0] == 'VERSION':
			return {'type' : 'version' , 'number' : int(elements[1])}
		elif elements[0] == 'NUMBONES':
			return {'type' : 'num_bones' , 'number' : int(elements[1])}
		elif elements[0] == 'NUMVERTS':
			return {'type' : 'num_verts' , 'number' : int(elements[1])}
		elif elements[0] == 'NUMFACES':
			return {'type' : 'num_faces' , 'number' : int(elements[1])}
		elif elements[0] == 'NUMOBJECTS':
			return {'type' : 'num_objects' , 'number' : int(elements[1])}
		elif elements[0] == 'NUMMATERIALS':
			return {'type' : 'num_materials' , 'number' : int(elements[1])}
		else:
			return self.empty_type

	def read(self, f_name):
		"""Reads xmodel_export file from disk.
		
		Populates class members with value from file.
		"""
		f = open(f_name, 'r')
		file_contents = f.readlines()
		line_num = 0
		while line_num < len(file_contents):
			data = self.parseLine(file_contents[line_num])
			if data['type'] == 'export_file':
				self.export_name = data['filename']
			elif data['type'] == 'source_file':
				self.maya_name = data['filename']
			elif data['type'] == 'export_date':
				self.export_date = data['date']
			elif data['type'] == 'version':
				self.version = data['number']
			elif data['type'] == 'num_bones':
				self.num_bones = data['number']
				line_num = self.readBones(file_contents, line_num)
			elif data['type'] == 'num_verts':
				self.num_verts = data['number']
				line_num = self.readVerts(file_contents, line_num) - 1
			elif data['type'] == 'num_faces':
				self.num_faces = data['number']
				line_num = self.readFaces(file_contents, line_num)
			elif data['type'] == 'num_objects':
				self.num_objects = data['number']
				line_num = self.readObjects(file_contents, line_num)
			elif data['type'] == 'num_materials':
				self.num_materials = data['number']
				line_num = self.readMaterials(file_contents, line_num)
			line_num += 1
		f.closed
		
	def write(self, f_name):
		"""Writes class data to output xmodel_export file.
		"""
		f = open(f_name, 'w')
		f.write('// Export filename: \'%s\'\n' % (self.export_name))
		f.write('// Source filename: \'%s\'\n' % (self.maya_name))
		f.write('// Export time: %s %s %s %s %s\n' % (self.export_date['day'], self.export_date['month'], self.export_date['date'], self.export_date['time'], self.export_date['year']))
		f.write('MODEL\n')
		f.write('VERSION %i\n' % (self.version))
		f.write('\n')
		f.write('NUMBONES %i\n' % (self.num_bones))
		for i in self.bones:
			f.write('BONE %i %i "%s"\n' % (i['bone_id'], i['bone_parent'], i['bone_name']))
		f.write('\n')
		for i in self.bones:
			f.write('BONE %i\n' % (i['bone_id']))
			f.write('OFFSET %.6f %.6f %.6f\n' % (i['bone_data']['offset']['x'], i['bone_data']['offset']['y'], i['bone_data']['offset']['z']))
			f.write('SCALE %.6f %.6f %.6f\n' % (i['bone_data']['scale']['x'], i['bone_data']['scale']['y'], i['bone_data']['scale']['z']))
			f.write('X %.6f %.6f %.6f\n' % (i['bone_data']['X']['x'], i['bone_data']['X']['y'], i['bone_data']['X']['z']))
			f.write('Y %.6f %.6f %.6f\n' % (i['bone_data']['Y']['x'], i['bone_data']['Y']['y'], i['bone_data']['Y']['z']))
			f.write('Z %.6f %.6f %.6f\n' % (i['bone_data']['Z']['x'], i['bone_data']['Z']['y'], i['bone_data']['Z']['z']))
			f.write ('\n')
		f.write('NUMVERTS %i\n' % (self.num_verts))
		for i in self.verts:
			f.write('VERT %i\n' % (i['index']))
			f.write('OFFSET %.6f %.6f %.6f\n' % (i['offset']['x'], i['offset']['y'], i['offset']['z']))
			f.write('BONES %i\n' % (i['bone_count']))
			for b in i['bones']:
				f.write('BONE %i %.6f\n' % (b['index'], b['weight']))
			f.write('\n')
		f.write('NUMFACES %i\n' % (self.num_faces))
		for i in self.faces:
			f.write('TRI %i %i 0 0\n' % (i['tri']['object_id'], i['tri']['material_id']))
			for v in i['verts']:
 				f.write('VERT %i\n' % (v['index']))
 				f.write('NORMAL %.6f %.6f %.6f\n' % (v['normal']['x'], v['normal']['y'], v['normal']['z']))
 				f.write('COLOR %.6f %.6f %.6f %.6f\n' % (v['color']['r'], v['color']['g'], v['color']['b'], v['color']['a']))
 				f.write('UV %.6f %.6f %.6f\n' % (v['uv']['x'], v['uv']['y'], v['uv']['z']))
 		f.write('\n')
 		f.write('NUMOBJECTS %i\n' % (self.num_objects))
 		for i in self.objects:
 			f.write('OBJECT %i "%s"\n' % (i['object_id'], i['object_name']))
 		f.write('\n')
 		f.write('NUMMATERIALS %i\n' % (self.num_materials))
 		for i in self.materials:
 			f.write('MATERIAL %i "%s" "%s" "%s"\n' % (i['index'], i['name'], i['type'], i['image']))
 			# padding out material data
 			# none of the following is useful
 			f.write('COLOR 0.000000 0.000000 0.000000 1.000000\n')
			f.write('TRANSPARENCY 0.000000 0.000000 0.000000 1.000000\n')
			f.write('AMBIENTCOLOR 0.000000 0.000000 0.000000 1.000000\n')
			f.write('INCANDESCENCE 0.000000 0.000000 0.000000 1.000000\n')
			f.write('COEFFS 0.800000 0.000000\n')
			f.write('GLOW 0.000000 0\n')
			f.write('REFRACTIVE 6 1.000000\n')
			f.write('SPECULARCOLOR -1.000000 -1.000000 -1.000000 1.000000\n')
			f.write('REFLECTIVECOLOR -1.000000 -1.000000 -1.000000 1.000000\n')
			f.write('REFLECTIVE -1 -1.000000\n')
			f.write('BLINN -1.000000 -1.000000\n')
			f.write('PHONG -1.000000\n')
		f.close
		
# model = Xmodel()
# model.read('C:\\mw_root\\cod4\\model_export\\characters\\sp_characters_usmc_ghillie\\xmodel_characters\\body_complete_sp_usmc_ghillie_price_lod1.XMODEL_EXPORT')
# model.write('C:\\temp\\body_complete_sp_usmc_ghillie_price_lod1.XMODEL_EXPORT')
