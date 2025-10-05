import xmodel

def findBone (bones, name):
	for i in range(len(bones)):
		if bones[i]['bone_name'] == name:
			return i
	return -1

def isBoneUsed (vert, idx):
	for i in range(vert['bone_count']):
		if vert['bones'][i]['index'] == idx:
			return i
	return -1
	
def remapBones (verts, idx1, idx2):
	for vert in verts:
		i = 0
		while i < (vert['bone_count']):
			if vert['bones'][i]['index'] == idx1:
				used_idx = isBoneUsed(vert, idx2)
				if used_idx > -1:
					vert['bones'][used_idx]['weight'] += vert['bones'][i]['weight']
					del vert['bones'][i]
					vert['bone_count'] -= 1
				else:
					vert['bones'][i]['index'] = idx2
			i += 1
	return verts
	
def remapModel (file): #file is the filename of the xmodel with complete path
	model = xmodel.Xmodel()
	model.read(file)
	
	remapBones (model.verts, findBone(model.bones, 'J_Pinky_RI_3'), findBone (model.bones,  'J_Mid_RI_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Pinky_LE_3'), findBone (model.bones,  'J_Mid_LE_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Pinky_RI_2'), findBone (model.bones,  'J_Mid_RI_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Pinky_LE_2'), findBone (model.bones,  'J_Mid_LE_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Pinky_RI_1'), findBone (model.bones,  'J_Mid_RI_1'))
	remapBones (model.verts, findBone(model.bones, 'J_Pinky_LE_1'), findBone (model.bones,  'J_Mid_LE_1'))
	
	remapBones (model.verts, findBone(model.bones, 'J_Ring_RI_3'), findBone (model.bones,  'J_Mid_RI_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Ring_LE_3'), findBone (model.bones,  'J_Mid_LE_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Ring_RI_2'), findBone (model.bones,  'J_Mid_RI_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Ring_LE_2'), findBone (model.bones,  'J_Mid_LE_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Ring_RI_1'), findBone (model.bones,  'J_Mid_RI_1'))
	remapBones (model.verts, findBone(model.bones, 'J_Ring_LE_1'), findBone (model.bones,  'J_Mid_LE_1'))
	
	remapBones (model.verts, findBone(model.bones, 'J_Mid_RI_3'), findBone (model.bones,  'J_Mid_RI_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Mid_LE_3'), findBone (model.bones,  'J_Mid_LE_2'))
	
	remapBones (model.verts, findBone(model.bones, 'J_Thumb_LE_3'), findBone (model.bones,  'J_Thumb_LE_2'))
	remapBones (model.verts, findBone(model.bones, 'J_Thumb_RI_3'), findBone (model.bones,  'J_Thumb_RI_2'))

	remapBones (model.verts, findBone(model.bones, 'J_ShoulderRaise_LE'), findBone (model.bones,  'J_Spine4'))
	remapBones (model.verts, findBone(model.bones, 'J_ShoulderRaise_RI'), findBone (model.bones,  'J_Spine4'))

	model.write(file)