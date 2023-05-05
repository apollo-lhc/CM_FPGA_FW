#!/bin/env python3


#################################################################################                                                                                                             
## Force python3                                                                                                                                                                              
#################################################################################                                                                                                             
import sys                                                                                                                                                                                    
if not sys.version_info.major == 3:                                                                                                                                                           
    raise BaseException("Wrong Python version detected.  Please ensure that you are using Python 3.")                                                                                         
#################################################################################              

import argparse
import os
import shutil

import yaml
import xml.etree.ElementTree as ET

from xml.etree import ElementTree
from xml.dom import minidom

from lxml import etree
from os.path import exists

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
  child.set("fwinfo","uio_endpoint")
  if "XML" in slave:
    child.set("module",slave['XML'].replace("modules",modulesPath))
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
    fwinfoLen = 0
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
        if(child.get('fwinfo')):
            size=len(child.get('fwinfo'))
            if(size > fwinfoLen):
                fwinfoLen=size
        
  
    #add the length of the attribute name for padding (name + "=" + quote chars)
    idLen+=5+1
    addrLen+=10+1
    moduleLen+=9+1
    modeLen+=7+1
    sizeLen+=7+1
    fwinfoLen+=7+1 
  
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

        #print the fwinfo if it exists
        if(child.get('fwinfo')):
            ATFile.write((" fwinfo=\""+child.get('fwinfo')+"\"").ljust(addrLen))
        else:
            ATFILE.write(" ".ljust(addrLen))
        ATFile.write(" ")
        
        #print the module if it exists
        if(child.get('module')):
            filepath=child.get('module')
            if filepath.startswith("address_table/"):
                filepath= filepath[len("address_table/"):]
            ATFile.write((" module=\"file://"+filepath+"\"").ljust(moduleLen))
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
    
def findXMLModules(path,currentElement):
    included_files = []
    for child in currentElement:
        #get attributes
        attributes = child.attrib
        #keep track of path needed for the next recursive call to findXMLModules
        sub_path=path
        
        if "module" in attributes:
            #This node has a module attribute, load and follow it
            module_file = attributes["module"].replace("file://", "")
            #This module is in a sub-path, so update sub_path for this search
            if len(os.path.dirname(module_file)) > 0:
                   sub_path=path+"/"+os.path.dirname(module_file)

            module_file = os.path.basename(module_file)
            module_file = sub_path+"/"+module_file
            #check if this file really exists
            if not exists(module_file):
                raise BaseException("File "+module_file+" not found")
            #open file, read in XML, get the current XML node and process it.
            f = open(module_file, "rb")
            parser = etree.XMLParser(remove_comments=True)
            tree = etree.parse(f, parser=parser)
            root = tree.getroot()
            f.close()
            #add the new file found to the list of files
            included_files.extend([module_file])
            #add any files found while searching the new file
            included_files.extend(findXMLModules(sub_path,root))
        else:
            #this isn't a module, but see if it has any children that might
            included_files.extend(findXMLModules(sub_path,child))
        
    return included_files
    
def main(localSlavesYAML,remoteSlavesYAML,CMyaml,outputDir,topName,modulesPath):
    #address table top node
    top = ET.Element("node",{"id":"top"})

    #local slaves
    RecreateDir(outputDir)
    slavesFile=open(localSlavesYAML)
    slaves=yaml.load(slavesFile, Loader=yaml.Loader)
    for slave in slaves['UHAL_MODULES']:
      if "XML" in slaves['UHAL_MODULES'][slave]:
       #get the full file path and the base path
        module_file=os.path.abspath(slaves['UHAL_MODULES'][slave]["XML"])
        module_base_path=os.path.dirname(module_file)

        #start the list of files needed for this address table element
        module_files=[module_file]
        
        if not exists(module_file):
            raise BaseException("File "+module_file+" not found")

        #open the XML file and start parsing it
        f = open(module_file, "rb")
        parser = etree.XMLParser(remove_comments=True)
        tree = etree.parse(f, parser=parser)
        root = tree.getroot()
        f.close()
        #search through all the children of this node and fine all the include files from module attributes
        module_files.extend(findXMLModules(os.path.dirname(module_file)+"/",root))
        
        #hacky way of removing duplicates from the list
        file_list = []
        for i in module_files:
            if i != []:
                if i not in file_list:
                    file_list.append(i)

        #copy all the files to their final destination
        for iFile in file_list:
            src_path = iFile
            dest_path = outputDir+iFile.replace(module_base_path,"/")
            if not exists(os.path.dirname(dest_path)):
                os.makedirs(os.path.dirname(dest_path))
            shutil.copyfile(src_path,dest_path)        
      else:
          print(module_file+" does not exist")          

      AddAddressTableNode(slave,slaves['UHAL_MODULES'][slave],top,modulesPath)

    remoteSlaves = list()
    #append CM.yaml remote slaves
    try:
      if type(CMyaml) == type('  '):
        CMFile=open(CMyaml)
        remotes=yaml.load(CMFile)
        for remote in remotes:
          filename="os/"+remote+"_config.yaml"
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
    connFile.write('  <connection id="test.0"        uri="uioaxi-1.0:///fw/address_table/'+topName+'"                     address_table="file:///fw/address_table/'+topName+'" />\n')
    connFile.write('</connections>\n')
    connFile.close()

        

    





if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build address table.")
    parser.add_argument("--localConfigYAML","-l"      ,help="YAML file storing the slave info for generation",required=True)
    parser.add_argument("--remoteConfigYAML","-r"     ,help="YAML file storing remote locations of slave info for generation",required=False,action='append')
    parser.add_argument("--CM","-R"                   ,help="YAML file for CM sources used to set the remoteConfig",required=False)  
    parser.add_argument("--outputDir","-o"            ,help="Output directory",default="kernel/address_table/modules")
    parser.add_argument("--topName","-t"              ,help="top name for name.xml", default="address_apollo.xml")
    parser.add_argument("--modulesPath","-m"          ,help="what to rename the modules path to", default="modules")
    args=parser.parse_args()
    
    main(args.localConfigYAML,
         args.remoteConfigYAML,
         args.CM,
         args.outputDir,
         args.topName,
         args.modulesPath)
