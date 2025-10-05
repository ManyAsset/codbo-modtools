import sys, os

IW_CORE_PATH = os.getenv('IW_CORE_PATH')
IW_PROJECT_BIN = os.getenv('IW_PROJECT_BIN')
IW_PROJECT_GAMEDIR = os.getenv('IW_PROJECT_GAMEDIR')

if IW_CORE_PATH:
   sys.path.append( IW_CORE_PATH+'\\tools_bin\\maya' )
   sys.path.append( IW_CORE_PATH+'\\tools_bin\\python26\\Lib\\site-packages' )
else:
   print 'Cannot find IW project setup environment'