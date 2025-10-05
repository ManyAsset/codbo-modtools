from stat import S_IWRITE
from gdtAttributes import *
from itertools import izip
import sys, os, glob, re
import maya.OpenMaya as OpenMaya
import maya.OpenMayaMPx as OpenMayaMPx

__author__ =   'Stev Kalinowski'
__copyright__ = 'Treyarch 2009'
__version__ = 1.11

def isFileWritable(mfile):
   attr = os.stat(mfile)[0]
   if not attr & S_IWRITE:
      return False
   else:
      return True

class gdtCreateMaterialEntry(OpenMayaMPx.MPxCommand):
   kCommand = 'gdtCreateMaterialEntry'

   kFileFlag = '-f'
   kFileFlagLong = '-file'
   kEntryNameFlag = '-n'
   kEntryNameFlagLong = '-entryName'
   kColorFlag = '-c'
   kColorFlagLong = '-color'
   kNormalFlag = '-nor'
   kNormalFlagLong = '-normal'
   kSpecularFlag = '-s'
   kSpecularFlagLong = '-specular'
   kCosineFlag = '-cos'
   kCosineFlagLong = '-cosinePower'
   kMaterialTypeFlag = '-t'
   kMaterialTypeFlagLong = '-type'
   kSurfaceTypeFlag = '-sur'
   kSurfaceTypeFlagLong = '-surface'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      # These variables will hold our arguments
      # The gdt file we'll add our entries to
      gdtFile = ''
      # The name of the gdt entry
      entryName = ''
      # These will be the texture paths
      colorMap = ''
      normalMap = ''
      specMap = ''
      cosineMap = ''
      # Material and Surface Type variables
      matType = ''
      surType = ''

      # Set result to fail
      self.setResult(0)
      # Make the arg database
      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Get our arguments
      if argData.isFlagSet(self.kFileFlag):
         gdtFile = argData.flagArgumentString(self.kFileFlag, 0)
      if argData.isFlagSet(self.kEntryNameFlag):
         entryName = argData.flagArgumentString(self.kEntryNameFlag, 0).split(':')[-1].lower()
      if argData.isFlagSet(self.kColorFlag):
         colorMap = argData.flagArgumentString(self.kColorFlag, 0)
      if argData.isFlagSet(self.kNormalFlag):
         normalMap = argData.flagArgumentString(self.kNormalFlag, 0)
      if argData.isFlagSet(self.kSpecularFlag):
         specMap = argData.flagArgumentString(self.kSpecularFlag, 0)
      if argData.isFlagSet(self.kCosineFlag):
         cosineMap = argData.flagArgumentString(self.kCosineFlag, 0)
      if argData.isFlagSet(self.kMaterialTypeFlag):
         matType = argData.flagArgumentString(self.kMaterialTypeFlag, 0)
      if argData.isFlagSet(self.kSurfaceTypeFlag):
         surType = argData.flagArgumentString(self.kSurfaceTypeFlag, 0)

      if not os.path.isfile(gdtFile):
         OpenMaya.MGlobal.displayError('GDT file does not exist')
         return None

      if not isFileWritable(gdtFile):
         OpenMaya.MGlobal.displayError('GDT file is not writable')
         return None

      if not entryName:
         OpenMaya.MGlobal.displayError('A GDT entry name must be specified')
         return None

      newEntry = GdtEntry( entryName, MaterialEntry() )

      newEntry.entry.attrs['colorMap'] = colorMap.replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['normalMap'] = normalMap.replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['specColorMap'] = specMap.replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['cosinePowerMap'] = cosineMap.replace('\\', r'\\').replace('/', r'\\')

      if matType:
         newEntry.entry.attrs['materialType'] = matType
      if surType:
         newEntry.entry.attrs['surfaceType'] = surType

      newEntry.write( gdtFile )

      self.setResult(1)

# This command finds an xmodel gdt entry's attributes and returns them as a string
# This is used to update the mel UI in Maya for updating an xmodel entry
class gdtGetXmodelEntry(OpenMayaMPx.MPxCommand):
   kCommand = 'gdtGetXmodelEntry'

   kFileFlag = '-f'
   kFileFlagLong = '-file'
   kEntryNameFlag = '-n'
   kEntryNameFlagLong = '-entryName'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      # These variables will hold our arguments
      # The gdt file we'll add our entries to
      gdtFile = ''
      # The name of the gdt entry
      entryName = ''

      # Set result to fail
      self.setResult('')
      # Make the arg database
      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Get our arguments
      if argData.isFlagSet(self.kFileFlag):
         gdtFile = argData.flagArgumentString(self.kFileFlag, 0)
      if argData.isFlagSet(self.kEntryNameFlag):
         entryName = argData.flagArgumentString(self.kEntryNameFlag, 0)

      # Make sure we have gdt file and entry name
      if gdtFile and entryName:
         # Check to see if the gdt file is an actual file
         if not os.path.isfile( gdtFile ):
            OpenMaya.MGlobal.displayError('Gdt file not found')
            return None

         # Create the entry object
         existingEntry = GdtEntry( entryName, XmodelEntry() )

         # Find the entry we're looking to get data from
         if not existingEntry.find( gdtFile ):
            OpenMaya.MGlobal.displayError('Xmodel entry not found in gdt')
            return None

         # Start with empty strings for each attribute we're looking for
         modelType, collisionLod, highDist, medDist, lowDist, lowestDist = '', '', '', '', '', ''
         # Get the attribute values from the gdt entry object
         modelType = existingEntry.entry['type']
         collisionLod = existingEntry.entry['BulletCollisionLOD']
         highDist = existingEntry.entry['highLodDist']
         medDist = existingEntry.entry['mediumLodDist']
         lowDist = existingEntry.entry['lowLodDist']
         lowestDist = existingEntry.entry['lowestLodDist']

         # All these attrs are mandatory for xmodels, os if any of them are not found, this entry is not an xmodel
         if modelType and collisionLod and highDist and medDist and lowDist and lowestDist:
            self.setResult( modelType+'|'+collisionLod+'|'+highDist+'|'+medDist+'|'+lowDist+'|'+lowestDist )

class gdtUpdateMaterialAttribute(OpenMayaMPx.MPxCommand):
   kCommand = 'gdtUpdateMaterialAttribute'

   kFileFlag = '-f'
   kFileFlagLong = '-file'
   kEntryNameFlag = '-n'
   kEntryNameFlagLong = '-name'
   kAttributeFlag = '-a'
   kAttributeFlagLong = '-attribute'
   kValueFlag = '-v'
   kValueFlagLong = '-value'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      # These variables will hold our arguments
      # The gdt file we'll add our entries to
      gdtFile = ''
      # The name of the gdt entry
      entryName = ''
      # The string to represent attributes to change
      attrStr = ''
      # The string to represent the attribute values
      attrValueStr = ''

      # Set result to fail
      self.setResult(0)
      # Make the arg database
      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Get our arguments
      if argData.isFlagSet(self.kFileFlag):
         gdtFile = argData.flagArgumentString(self.kFileFlag, 0)
      if argData.isFlagSet(self.kEntryNameFlag):
         entryName = argData.flagArgumentString(self.kEntryNameFlag, 0)
      if argData.isFlagSet(self.kAttributeFlag):
         attrStr = argData.flagArgumentString(self.kAttributeFlag, 0)
      if argData.isFlagSet(self.kValueFlag):
         attrValueStr = argData.flagArgumentString(self.kValueFlag, 0)

      # Make sure we have an attribute to change and a value to change to
      if not attrStr or not attrValueStr:
         OpenMaya.MGlobal.displayError('You must specify an attribute and value')
         return None

      # The attributes are separated by pipe characters
      attrs = attrStr.split('|')
      # The values are separated by pipe characters
      attrValues = attrValueStr.split('|')

      # Also make sure we have gdt file and entry name
      if gdtFile and entryName:
         # Check to see if the gdt file is an actual file
         if not os.path.isfile( gdtFile ):
            OpenMaya.MGlobal.displayError('Gdt file not found')
            return None
         # Check to see if the gdt file is writable
         if not isFileWritable( gdtFile ):
            OpenMaya.MGlobal.displayError('Gdt is not writable')
            return None
         # Make the gdt entry object
         existingEntry = GdtEntry( entryName, MaterialEntry() )
         # Find the entry in the gdt
         if not existingEntry.find( gdtFile ):
            OpenMaya.MGlobal.displayError('Material entry not found in gdt')
            return None

      # Set the attributes to their values
      for attr, attrValue in izip(attrs, attrValues):
         existingEntry.entry[attr] = attrValue.replace('\\', r'\\\\').replace('/', r'\\\\')

      # Update the gdt file
      if existingEntry.update( gdtFile ):
         self.setResult(1)


class gdtUpdateXmodelEntry(OpenMayaMPx.MPxCommand):
   kCommand = 'gdtUpdateXmodelEntry'

   kFileFlag = '-f'
   kFileFlagLong = '-file'
   kEntryNameFlag = '-n'
   kEntryNameFlagLong = '-entryName'
   kCollisionFlag = '-c'
   kCollisionFlagLong = '-collision'
   kLodDistFlag = '-d'
   kLodDistFlagLong = '-distance'
   kExportFilesFlag = '-e'
   kExportFilesFlagLong = '-exportFiles'
   kTypeFlag = '-t'
   kTypeFlagLong = '-type'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      # These are the possible collision settings
      collisionTypes = ('None', 'High', 'Medium', 'Low', 'Lowest')
      # These are the possible type of models
      modelTypes = ('rigid', 'animated', 'multiplayer body', 'pieces', 'viewhands')
      # These variables will hold our arguments
      # The gdt file we'll add our entries to
      gdtFile = ''
      # The name of the gdt entry
      entryName = ''
      # The collision LOD, must be None, High, Medium, Low, or Lowest
      collision = 'None'
      # Four LOD distances
      lodDistances = [0,0,0,0]
      # The full path to each of the XMODEL_EXPORT files
      exportFiles = ['','','','']
      # Type of model, animated or rigid
      modelType = 'rigid'

      # Set result to fail
      self.setResult(0)
      # Make the arg database
      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Get our arguments
      if argData.isFlagSet(self.kFileFlag):
         gdtFile = argData.flagArgumentString(self.kFileFlag, 0)
      if argData.isFlagSet(self.kEntryNameFlag):
         entryName = argData.flagArgumentString(self.kEntryNameFlag, 0)
      if argData.isFlagSet(self.kCollisionFlag):
         collision = argData.flagArgumentString(self.kCollisionFlag, 0)
      if argData.isFlagSet(self.kLodDistFlag):
         for i in range(4):
            lodDistances[i] = argData.flagArgumentInt(self.kLodDistFlag, i)
      if argData.isFlagSet(self.kExportFilesFlag):
         for i in range(4):
            exportFiles[i] = argData.flagArgumentString(self.kExportFilesFlag, i)
      if argData.isFlagSet(self.kTypeFlag):
         modelType = argData.flagArgumentString(self.kTypeFlag, 0)

      if not os.path.isfile(gdtFile):
         OpenMaya.MGlobal.displayError('GDT file does not exist')
         return None

      if not isFileWritable(gdtFile):
         OpenMaya.MGlobal.displayError('GDT file is not writable')
         return None

      if not entryName:
         OpenMaya.MGlobal.displayError('A GDT entry name must be specified')
         return None

      if not exportFiles[0]:
         OpenMaya.MGlobal.displayError('At least one XMODEL_EXPORT must be specified')
         return None

      existingEntry = GdtEntry( entryName, XmodelEntry() )

      if not existingEntry.find( gdtFile ):
         OpenMaya.MGlobal.displayError('Xmodel entry not found in gdt')
         return None

      if collision in collisionTypes:
         existingEntry.entry['BulletCollisionLOD'] = collision

      existingEntry.entry['filename'] = exportFiles[0].replace('\\', r'\\\\').replace('/', r'\\\\')
      existingEntry.entry['mediumLod'] = exportFiles[1].replace('\\', r'\\\\').replace('/', r'\\\\')
      existingEntry.entry['lowLod'] = exportFiles[2].replace('\\', r'\\\\').replace('/', r'\\\\')
      existingEntry.entry['lowestLod'] = exportFiles[3].replace('\\', r'\\\\').replace('/', r'\\\\')
      existingEntry.entry['highLodDist'] = str(lodDistances[0])
      existingEntry.entry['mediumLodDist'] = str(lodDistances[1])
      existingEntry.entry['lowLodDist'] = str(lodDistances[2])
      existingEntry.entry['lowestLodDist'] = str(lodDistances[3])

      if modelType in modelTypes:
         existingEntry.entry['type'] = modelType

      if existingEntry.update( gdtFile ):
         self.setResult(1)


class gdtCreateXmodelEntry(OpenMayaMPx.MPxCommand):
   kCommand = 'gdtCreateXmodelEntry'

   kFileFlag = '-f'
   kFileFlagLong = '-file'
   kEntryNameFlag = '-n'
   kEntryNameFlagLong = '-entryName'
   kCollisionFlag = '-c'
   kCollisionFlagLong = '-collision'
   kLodDistFlag = '-d'
   kLodDistFlagLong = '-distance'
   kExportFilesFlag = '-e'
   kExportFilesFlagLong = '-exportFiles'
   kTypeFlag = '-t'
   kTypeFlagLong = '-type'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      # These are the possible collision settings
      collisionTypes = ('None', 'High', 'Medium', 'Low', 'Lowest')
      # These are the possible type of models
      modelTypes = ('rigid', 'animated', 'multiplayer body', 'pieces', 'viewhands')
      # These variables will hold our arguments
      # The gdt file we'll add our entries to
      gdtFile = ''
      # The name of the gdt entry
      entryName = ''
      # The collision LOD, must be None, High, Medium, Low, or Lowest
      collision = 'None'
      # Four LOD distances
      lodDistances = [0,0,0,0]
      # The full path to each of the XMODEL_EXPORT files
      exportFiles = ['','','','']
      # Type of model, animated or rigid
      modelType = 'rigid'

      # Set result to fail
      self.setResult(0)
      # Make the arg database
      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Get our arguments
      if argData.isFlagSet(self.kFileFlag):
         gdtFile = argData.flagArgumentString(self.kFileFlag, 0)
      if argData.isFlagSet(self.kEntryNameFlag):
         entryName = argData.flagArgumentString(self.kEntryNameFlag, 0)
      if argData.isFlagSet(self.kCollisionFlag):
         collision = argData.flagArgumentString(self.kCollisionFlag, 0)
      if argData.isFlagSet(self.kLodDistFlag):
         for i in range(4):
            lodDistances[i] = argData.flagArgumentInt(self.kLodDistFlag, i)
      if argData.isFlagSet(self.kExportFilesFlag):
         for i in range(4):
            exportFiles[i] = argData.flagArgumentString(self.kExportFilesFlag, i)
      if argData.isFlagSet(self.kTypeFlag):
         modelType = argData.flagArgumentString(self.kTypeFlag, 0)

      if not os.path.isfile(gdtFile):
         OpenMaya.MGlobal.displayError('GDT file does not exist')
         return None

      if not isFileWritable(gdtFile):
         OpenMaya.MGlobal.displayError('GDT file is not writable')
         return None

      if not entryName:
         OpenMaya.MGlobal.displayError('A GDT entry name must be specified')
         return None

      if not exportFiles[0]:
         OpenMaya.MGlobal.displayError('At least one XMODEL_EXPORT must be specified')
         return None

      newEntry = GdtEntry( entryName, XmodelEntry() )

      if collision in collisionTypes:
         newEntry.entry.attrs['BulletCollisionLOD'] = collision

      newEntry.entry.attrs['filename'] = exportFiles[0].replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['mediumLod'] = exportFiles[1].replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['lowLod'] = exportFiles[2].replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['lowestLod'] = exportFiles[3].replace('\\', r'\\').replace('/', r'\\')
      newEntry.entry.attrs['highLodDist'] = str(lodDistances[0])
      newEntry.entry.attrs['mediumLodDist'] = str(lodDistances[1])
      newEntry.entry.attrs['lowLodDist'] = str(lodDistances[2])
      newEntry.entry.attrs['lowestLodDist'] = str(lodDistances[3])

      if modelType in modelTypes:
         newEntry.entry.attrs['type'] = modelType

      newEntry.write( gdtFile )

      self.setResult(1)


class gdtFindEntry(OpenMayaMPx.MPxCommand):
   kCommand = 'gdtFindEntry'

   # The command will retrieve all gdt file in this folder to search
   kFolderFlag = '-f'
   kFolderFlagLong = '-folder'
   # This is the entry name that will be searched for
   kEntryNameFlag = '-n'
   kEntryNameFlagLong = '-entryName'
   # This optional flag allows the user to specify an entry type
   kEntryTypeFlag = '-t'
   kEntryTypeFlagLong = '-type'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      # These variables will hold our arguments
      folderToSearch = ''
      entryName = ''
      entryType = ''

      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Get our arguments
      if argData.isFlagSet(self.kFolderFlag):
         folderToSearch = argData.flagArgumentString(self.kFolderFlag, 0)
      if argData.isFlagSet(self.kEntryNameFlag):
         entryName = argData.flagArgumentString(self.kEntryNameFlag, 0).split(':')[-1].lower()
      if argData.isFlagSet(self.kEntryTypeFlag):
         entryType = argData.flagArgumentString(self.kEntryTypeFlag, 0)

      # If either argument is not provided, then stop
      if not folderToSearch or not entryName:
         return None

      # Get gdt files from our search path
      gdtFiles = glob.glob( folderToSearch + '/*.gdt' )

      # If no gdts are found, then stop
      if not gdtFiles:
         return None

      # Set the default result
      self.setResult( '' )

      # Make our Reg-Ex pattern
      if not entryType:
         reObj = re.compile( r'"' + entryName + '" \( "(.+).gdf" \)' )
      else:
         reObj = re.compile( r'"' + entryName + '" \( "'+entryType+'.gdf" \)' )

      # Scan all files for the pattern
      for f in gdtFiles:
         # Open and read the file
         fin = open( f )
         gdt = fin.read()
         fin.close()

         # If we find our pattern, set the result to the GDT name
         if reObj.search( gdt ):
            self.setResult( os.path.basename( f ) )

def gdtUpdateMaterialAttribute_syntax_creator():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(gdtUpdateMaterialAttribute.kFileFlag, gdtUpdateMaterialAttribute.kFileFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateMaterialAttribute.kEntryNameFlag, gdtUpdateMaterialAttribute.kEntryNameFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateMaterialAttribute.kAttributeFlag, gdtUpdateMaterialAttribute.kAttributeFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateMaterialAttribute.kValueFlag, gdtUpdateMaterialAttribute.kValueFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def gdtCreateMaterialEntry_syntax_creator():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(gdtCreateMaterialEntry.kFileFlag, gdtCreateMaterialEntry.kFileFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kEntryNameFlag, gdtCreateMaterialEntry.kEntryNameFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kColorFlag, gdtCreateMaterialEntry.kColorFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kNormalFlag, gdtCreateMaterialEntry.kNormalFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kSpecularFlag, gdtCreateMaterialEntry.kSpecularFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kCosineFlag, gdtCreateMaterialEntry.kCosineFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kMaterialTypeFlag, gdtCreateMaterialEntry.kMaterialTypeFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateMaterialEntry.kSurfaceTypeFlag, gdtCreateMaterialEntry.kSurfaceTypeFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def gdtGetXmodelEntry_syntax_creator():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(gdtGetXmodelEntry.kFileFlag, gdtGetXmodelEntry.kFileFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtGetXmodelEntry.kEntryNameFlag, gdtGetXmodelEntry.kEntryNameFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def gdtUpdateXmodelEntry_syntax_creator():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(gdtUpdateXmodelEntry.kFileFlag, gdtUpdateXmodelEntry.kFileFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateXmodelEntry.kEntryNameFlag, gdtUpdateXmodelEntry.kEntryNameFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateXmodelEntry.kCollisionFlag, gdtUpdateXmodelEntry.kCollisionFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateXmodelEntry.kLodDistFlag, gdtUpdateXmodelEntry.kLodDistFlagLong, OpenMaya.MSyntax.kLong, \
      OpenMaya.MSyntax.kLong, OpenMaya.MSyntax.kLong, OpenMaya.MSyntax.kLong)
   syntax.addFlag(gdtUpdateXmodelEntry.kExportFilesFlag, gdtUpdateXmodelEntry.kExportFilesFlagLong, OpenMaya.MSyntax.kString, \
      OpenMaya.MSyntax.kString, OpenMaya.MSyntax.kString, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtUpdateXmodelEntry.kTypeFlag, gdtUpdateXmodelEntry.kTypeFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def gdtCreateXmodelEntry_syntax_creator():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(gdtCreateXmodelEntry.kFileFlag, gdtCreateXmodelEntry.kFileFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateXmodelEntry.kEntryNameFlag, gdtCreateXmodelEntry.kEntryNameFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateXmodelEntry.kCollisionFlag, gdtCreateXmodelEntry.kCollisionFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateXmodelEntry.kLodDistFlag, gdtCreateXmodelEntry.kLodDistFlagLong, OpenMaya.MSyntax.kLong, \
      OpenMaya.MSyntax.kLong, OpenMaya.MSyntax.kLong, OpenMaya.MSyntax.kLong)
   syntax.addFlag(gdtCreateXmodelEntry.kExportFilesFlag, gdtCreateXmodelEntry.kExportFilesFlagLong, OpenMaya.MSyntax.kString, \
      OpenMaya.MSyntax.kString, OpenMaya.MSyntax.kString, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtCreateXmodelEntry.kTypeFlag, gdtCreateXmodelEntry.kTypeFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def gdtFindEntry_syntax_creator():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(gdtFindEntry.kFolderFlag, gdtFindEntry.kFolderFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtFindEntry.kEntryNameFlag, gdtFindEntry.kEntryNameFlagLong, OpenMaya.MSyntax.kString)
   syntax.addFlag(gdtFindEntry.kEntryTypeFlag, gdtFindEntry.kEntryTypeFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def gdtUpdateMaterialAttribute_creator():
	return OpenMayaMPx.asMPxPtr( gdtUpdateMaterialAttribute() )

def gdtCreateMaterialEntry_creator():
	return OpenMayaMPx.asMPxPtr( gdtCreateMaterialEntry() )

def gdtGetXmodelEntry_creator():
	return OpenMayaMPx.asMPxPtr( gdtGetXmodelEntry() )

def gdtUpdateXmodelEntry_creator():
	return OpenMayaMPx.asMPxPtr( gdtUpdateXmodelEntry() )

def gdtCreateXmodelEntry_creator():
	return OpenMayaMPx.asMPxPtr( gdtCreateXmodelEntry() )

def gdtFindEntry_creator():
	return OpenMayaMPx.asMPxPtr( gdtFindEntry() )

def initializePlugin(mobject):
	mplugin = OpenMayaMPx.MFnPlugin(mobject, __author__, str(__version__))
	try:
		mplugin.registerCommand( gdtFindEntry.kCommand, gdtFindEntry_creator, gdtFindEntry_syntax_creator )
		mplugin.registerCommand( gdtCreateMaterialEntry.kCommand, gdtCreateMaterialEntry_creator, gdtCreateMaterialEntry_syntax_creator )
		mplugin.registerCommand( gdtGetXmodelEntry.kCommand, gdtGetXmodelEntry_creator, gdtGetXmodelEntry_syntax_creator )
		mplugin.registerCommand( gdtUpdateXmodelEntry.kCommand, gdtUpdateXmodelEntry_creator, gdtUpdateXmodelEntry_syntax_creator )
		mplugin.registerCommand( gdtCreateXmodelEntry.kCommand, gdtCreateXmodelEntry_creator, gdtCreateXmodelEntry_syntax_creator )
		mplugin.registerCommand( gdtUpdateMaterialAttribute.kCommand, gdtUpdateMaterialAttribute_creator, gdtUpdateMaterialAttribute_syntax_creator )
	except:
		sys.stderr.write( "Failed to register: %s\n" % gdtFindEntry.kCommand )
		raise

def uninitializePlugin(mobject):
	mplugin = OpenMayaMPx.MFnPlugin(mobject)
	try:
		mplugin.deregisterCommand( gdtFindEntry.kCommand )
		mplugin.deregisterCommand( gdtCreateMaterialEntry.kCommand )
		mplugin.deregisterCommand( gdtGetXmodelEntry.kCommand )
		mplugin.deregisterCommand( gdtUpdateXmodelEntry.kCommand )
		mplugin.deregisterCommand( gdtCreateXmodelEntry.kCommand )
		mplugin.deregisterCommand( gdtUpdateMaterialAttribute.kCommand )
	except:
		sys.stderr.write( "Failed to unregister: %s\n" % gdtFindEntry.kCommand )
		raise