import maya.OpenMaya as OpenMaya
import maya.OpenMayaMPx as OpenMayaMPx
import os

from xmodel_finger_reskin import remapModel

__author__ = 'Treyarch'
__version__ = 1.0

# Start of scripted plugin code
class XmodelFingerReskin(OpenMayaMPx.MPxCommand):
   kCommand = 'XmodelFingerReskin'

   kFileFlag = '-f'
   kFileFlagLong = '-file'

   def __init__(self):
      OpenMayaMPx.MPxCommand.__init__(self)

   def doIt(self, argList):
      fileToConvert = ''

      argData = OpenMaya.MArgDatabase(self.syntax(), argList)

      # Put the provided arguments into the appropriate variables
      if argData.isFlagSet(self.kFileFlag):
         fileToConvert = argData.flagArgumentString(self.kFileFlag, 0)

      if not fileToConvert:
         OpenMaya.MGlobal.displayError("XmodelFingerReskin: Must specify file to reskin")
         return

      if not os.path.isfile(fileToConvert):
         OpenMaya.MGlobal.displayError("XmodelFingerReskin: Specified file doesn't exist")
         return

      remapModel(fileToConvert)

def XmodelFingerReskin_creator():
   return OpenMayaMPx.asMPxPtr( XmodelFingerReskin() )

def XmodelFingerReskin_syntax():
   syntax = OpenMaya.MSyntax()
   syntax.addFlag(XmodelFingerReskin.kFileFlag, XmodelFingerReskin.kFileFlagLong, OpenMaya.MSyntax.kString)
   return syntax

def initializePlugin(pObject):
   lPlugin = OpenMayaMPx.MFnPlugin(pObject, __author__, str(__version__))
   try:
      lPlugin.registerCommand( XmodelFingerReskin.kCommand, XmodelFingerReskin_creator, XmodelFingerReskin_syntax )
   except:
      OpenMaya.MGlobal.displayError( "Failed to register: %s\n" % XmodelFingerReskin.kCommand )
      raise

def uninitializePlugin(pObject):
   lPlugin = OpenMayaMPx.MFnPlugin(pObject)
   try:
      lPlugin.deregisterCommand( XmodelFingerReskin.kCommand )
   except:
      OpenMaya.MGlobal.displayError( "Failed to unregister: %s\n" % XmodelFingerReskin.kCommand )
      raise