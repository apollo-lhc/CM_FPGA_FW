#!/bin/env python
import argparse
import os
import shutil

import yaml
import xml.etree.ElementTree as ET

from xml.etree import ElementTree
from xml.dom import minidom


def RecreateDir(dir):
  try:
    os.makedirs(dir)
  except OSError:
    #remote files in this folder
    for filename in os.listdir(dir):
      file_path = os.path.join(dir, filename)
      try:
        if os.path.isfile(file_path) or os.path.islink(file_path):
          os.unlink(file_path)
        elif os.path.isdir(file_path):
          shutil.rmtree(file_path)
      except Exception as e:
        print('Failed to delete %s. Reason: %s' % (file_path, e))


def AddAddressTableNode(name,slave,xmlTop,modulesPath):
  child = ET.SubElement(xmlTop,"node")
  child.set("id",name)
  child.set("address",slave['UHAL_BASE'])
  if "XML" in slave:
    child.set("module",slave['XML'][0].replace("modules",modulesPath))
  if 'XML_MODE' in slave:
    child.set("mode",slave['XML_MODE'])
  if 'XML_SIZE' in slave:
    child.set("size",slave['XML_SIZE'])                

#def CopyModuleFile(

def BuildAddressTable(fileName,top):
    ATFile=open(fileName,"w")
  
    idLen = 0
    addrLen = 0
    moduleLen = 0
    modeLen = 0
    sizeLen = 0
    #find the max length of each type of attribute is
    for child in top:      
        size=len(child.get('id'))
        if(size > idLen):
            idLen=size
        if(child.get('address')):
            size=len(child.get('address'))
            if(size > addrLen):
                addrLen=size
        if(child.get('module')):
            size=len(child.get('module'))
            if(size > moduleLen):
                moduleLen=size
        if(child.get('mode')):
            size=len(child.get('mode'))
            if(size > modeLen):
                modeLen=size
        if(child.get('size')):
            size=len(hex(child.get('size')))
            if(size > sizeLen):
                sizeLen=size
  
    #add the length of the attribute name for padding
    idLen+=5+1
    addrLen+=10+1
    moduleLen+=9+1
    modeLen+=7+1
    sizeLen+=7+1
  
    #reorder data by uhal address
    top[:] = sorted(top,key=lambda child: (child.tag,child.get('address')))
    

    #generate the address table
    ATFile.write("<node id=\"TOP\">\n")
    for child in top:
        #start the node
        ATFile.write("  <node")
        
        #print the node ID
        ATFile.write((" id=\""+child.get('id')+"\"").ljust(idLen))      
        ATFile.write(" ")
  
        #print the address if it exists
        if(child.get('address')):
            ATFile.write((" address=\""+child.get('address')+"\"").ljust(addrLen))
        else:
            ATFILE.write(" ".ljust(addrLen))
        ATFile.write(" ")
        
        #print the module if it exists
        if(child.get('module')):
            ATFile.write((" module=\"file://"+child.get('module')+"\"").ljust(moduleLen))
        else:
            ATFile.write(" ".ljust(moduleLen))
        ATFile.write(" ")      
  
        #print the mode if it exists
        if(child.get('mode')):
            ATFile.write((" mode=\""+child.get('mode')+"\"").ljust(modeLen))
        else:
            ATFile.write(" ".ljust(modeLen))
        ATFile.write(" ")      
  
        #print the mode size if it exists
        if(child.get('size')):
            ATFile.write((" size=\""+hex(child.get('size'))+"\"").ljust(sizeLen))
        else:
            ATFile.write(" ".ljust(sizeLen))
  
  
        ATFile.write("/>\n")
    ATFile.write("</node>\n")
    

def main(localSlavesYAML,remoteSlavesYAML,CMyaml,outputDir,topName,modulesPath):
    #address table top node
    top = ET.Element("node",{"id":"top"})

    #local slaves
    RecreateDir(outputDir)
    slavesFile=open(localSlavesYAML)
    slaves=yaml.load(slavesFile)
    for slave in slaves['UHAL_MODULES']:
      if "XML" in slaves['UHAL_MODULES'][slave]:
        for iFile in range(0,len(slaves['UHAL_MODULES'][slave]["XML"])):
          #copy XML files
          xmlFile=slaves['UHAL_MODULES'][slave]["XML"][iFile]
          try:
            shutil.copyfile(os.path.abspath(xmlFile),outputDir+"/"+os.path.basename(xmlFile))
          except OSError:
            pass
          if iFile == 0:
            relPath=slaves['UHAL_MODULES'][slave]['XML'][iFile]
            relPath=relPath[relPath.find("module"):]
            slaves['UHAL_MODULES'][slave]['XML'][iFile] = relPath

        
        AddAddressTableNode(slave,slaves['UHAL_MODULES'][slave],top,modulesPath)

    remoteSlaves = list()
    #append CM.yaml remote slaves
    try:
      if type(CMyaml) == type('  '):
        CMFile=open(CMyaml)
        remotes=yaml.load(CMFile)
        for remote in remotes:
          filename="os/"+remote+"_slaves.yaml"
          remoteSlaves.append(filename)
    except IOError:
      pass
    #remote slaves (explicit)
    if type(remoteSlavesYAML) == type(list()):      
      for CM in remoteSlavesYAML:
        remoteSlaves.append(CM)

    #go through all found remote slaves
    for CM in remoteSlaves:
      slavesFile=open(CM)
      slaves=yaml.load(slavesFile)
      
      nameCM=os.path.basename(CM)[0:os.path.basename(CM).find("_")]

      for slave in slaves['UHAL_MODULES']:        
        if "XML" in slaves['UHAL_MODULES'][slave]:
          for iFile in range(0,len(slaves['UHAL_MODULES'][slave]["XML"])):
            #change the file path to be relative on the apollo
            relPath=slaves['UHAL_MODULES'][slave]['XML'][iFile]
            relPath=nameCM+"_"+relPath[relPath.find("module"):]
            slaves['UHAL_MODULES'][slave]['XML'][iFile] = relPath
          AddAddressTableNode(slave,slaves['UHAL_MODULES'][slave],top)

        


    #generate the final address table file
    BuildAddressTable(outputDir+"/../"+topName,top)


    #generate a connections file
    connFile=open(outputDir+"/../connections.xml","w")
    connFile.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    connFile.write('\n')
    connFile.write('<connections>\n')
    connFile.write('  <!-- be sure to use the same file in both "uri" and "address_table" -->\n')
    connFile.write('  <connection id="test.0"        uri="uioaxi-1.0:///opt/address_table/'+topName+'"                     address_table="file:///opt/address_table/'+topName+'" />\n')
    connFile.write('</connections>\n')
    connFile.close()

        

    





if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build address table.")
    parser.add_argument("--localSlavesYAML","-l"      ,help="YAML file storing the slave info for generation",required=True)
    parser.add_argument("--remoteSlavesYAML","-r"     ,help="YAML file storing remote locations of slave info for generation",required=False,action='append')
    parser.add_argument("--CM","-R"                   ,help="YAML file for CM sources used to set the remoteSlaves",required=False)  
    parser.add_argument("--outputDir","-o"            ,help="Output directory",default="os/address_table/modules")
    parser.add_argument("--topName","-t"              ,help="top name for name.xml", default="address_apollo.xml")
    parser.add_argument("--modulesPath","-m"          ,help="what to rename the modules path to", default="modules")
    args=parser.parse_args()
    
    main(args.localSlavesYAML,
         args.remoteSlavesYAML,
         args.CM,
         args.outputDir,
         args.topName,
         args.modulesPath)
