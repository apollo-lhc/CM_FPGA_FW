#!/bin/env python
import argparse

from git import Repo #interact with local git repo
import re #decode local repo
import requests #interact with github.com
import json # parse github return
import os
import yaml

#find files
from os import listdir
from os.path import isfile, join

token=""

def GetFilesToSend(path,match):
    files=dict()
    for f in listdir(path):
        if isfile(join(path,f)):
            if f.find(match) >= 0:
                if f.find("~") == -1:
                    files[f]=join(path,f)
    return files


def releaseFile(releaseJSON,localFile,uploadFile):
    global token
    url=releaseJSON["upload_url"].replace("{?name,label}","?name="+uploadFile)
    uploadFile=open(localFile)
    response=requests.post(url,data=uploadFile,headers = {"Authorization": "token "+token,"Content-Type": "application/octet-stream"})    
    uploadFile.close()
    if response.status_code != 201:
        raise Exception('Error ({0}:{1}) while uploading {2}\n{3}'.format(response.status_code,response.reason,localFile,response.text))


def main():

    parser = argparse.ArgumentParser(description="Build address table.")
    parser.add_argument("--dtsiPath","-d"      ,help="path for dtsi files")
    parser.add_argument("--tablePath","-t"      ,help="path for address table files")
    args=parser.parse_args()
    

    #get the token for remote write access to the repo
    global token
    token=os.getenv("GH_TOKEN")
    if token == None:
        print "Missing github oath token"
        quit()
      
    
    #############################################################################
    # Load local repo and 
    #############################################################################

    #open current path as repo
    localRepo = Repo("./")
    localRepoRemote=localRepo.remotes.origin.url
    #get remote info
    host=   re.search('(\@|https:\/\/)(.*):',localRepoRemote).group(2)           #match git@HOST:XXXXX or https://HOST:XXXX
    project=re.search('(\@|https:\/\/).*:(.*)\/',localRepoRemote).group(2)       #match XXXXhost:PROJECT/XXXXX
    repo=   re.search('(\@|https:\/\/).*:.*\/(.*).git',localRepoRemote).group(2) #match XXXXhost:project/REPO.git
    
    print "Repo is "+host+"/"+project+"/"+repo
    
    #get branch and check that it is a release branch
    branch=localRepo.active_branch.name
    #check if this is named release
    releaseVersion=""
    if branch.find("release-v") >= 0:
        releaseVersion=branch[branch.find("release-v") + len("release-v"):]
    elif branch.find("hotfix-v") >= 0 :
        releaseVersion=branch[branch.find("hotfix-v") + len("hotfix-v"):]
    else:
        print "Not on a release or hotfix branch!"
        quit()

    print "Release:"+ releaseVersion
    
    
    #############################################################################
    # Create a new release remotely
    #############################################################################
    
    #Create the new release
    GIT_API_URL="https://api."+host+"/repos/"+project+"/"+repo+"/releases"
    
    createReleaseData='\
        {\
    	"tag_name": "v'+releaseVersion+'",\
    	"target_commitish": "'+branch+'",\
    	"name": "v'+releaseVersion+'",\
    	"body": "v '+releaseVersion+' release of '+repo+'",\
    	"draft": false,\
    	"prerelease": false\
    	}'
    
    response=requests.post(GIT_API_URL,data=createReleaseData,headers = {"Authorization": "token "+token})
    if response.status_code != 201:
        print "Error: Creation failed with {0}".format(response.status_code)
        quit()
    else:
        print "Created draft release v{0}".format(releaseVersion)
    ReleaseJSON=json.loads(response.text)


    #############################################################################
    # Upload files to the release
    #############################################################################
    
    ##Upload files and finalize the release
    try:
        #dtsi files
        
        
        
        #########################################################################
        # DTSI files
        #########################################################################
        print "========================================"
        print "Processing dtsi files"
        print "========================================"
        #upload dtsi files        
        dtsiSlavesFile=args.dtsiPath+"slaves.yaml"
        uploadDir="dtsi/"
        uploadFile=uploadDir+"slaves.yaml"
        printPadding=len(dtsiSlavesFile)
        for slave in yaml.load(open(dtsiSlavesFile))['DTSI_CHUNKS']: 
            dtsiFile=GetFilesToSend(args.dtsiPath+"hw/",slave+".")    
            if len(dtsiFile) != 1:
                raise Exception('Too few or too many dtsi file matches!\nret:{0}\n'.format(dtsiFile))            
            for file in dtsiFile:
                if len(dtsiFile[file]) > printPadding:                    
                    printPadding = len(dtsiFile[file])+1
        print "  Uploading: " + (dtsiSlavesFile).ljust(printPadding) + " to  "+uploadFile+"\n" 
        releaseFile(ReleaseJSON,dtsiSlavesFile,uploadFile)
        for slave in yaml.load(open(dtsiSlavesFile))['DTSI_CHUNKS']:
            #since we don't know at the start that this is a dtsi_chunk or dtsi_post_chunk file
            #we use the name with a "." after it.   If it returns 0 or more than 1 files, then
            #we throw
            dtsiFile=GetFilesToSend(args.dtsiPath+"hw/",slave+".")    
            for file in dtsiFile:
                uploadFile=uploadDir+file                
                print "  Uploading:",(dtsiFile[file]).ljust(printPadding), "to",uploadFile 
                releaseFile(ReleaseJSON,dtsiFile[file],uploadFile)

        #########################################################################
        # Address table files
        #########################################################################
        print ""
        print "========================================"
        print "Processing address table files"
        print "========================================"
        #address tables
        tableSlavesFile=args.tablePath+"slaves.yaml"
        uploadFile="address_table/slaves.yaml"
        printPadding=len(tableSlavesFile)
        tableYAML = yaml.load(open(tableSlavesFile))
        for slave in tableYAML['UHAL_MODULES']:
            slave = tableYAML['UHAL_MODULES'][slave]
            if 'XML' in slave:
                for xmlFile in slave['XML']:
                    if len(xmlFile) > printPadding:                    
                        printPadding = len(xmlFile)+1

        print "  Uploading: " + (tableSlavesFile).ljust(printPadding) + " to  "+uploadFile+"\n" 
        releaseFile(ReleaseJSON,tableSlavesFile,uploadFile)
        uploadXMLFileList=[]
        for slave in tableYAML['UHAL_MODULES']:
            slave = tableYAML['UHAL_MODULES'][slave]
            if 'XML' in slave:
                for xmlFile in slave['XML']:
                    if xmlFile not in uploadXMLFileList:
                        uploadFile=xmlFile
                        uploadXMLFileList.append(xmlFile)
                        print "  Uploading: " + (xmlFile).ljust(printPadding) + " to  "+uploadFile 
                        releaseFile(ReleaseJSON,xmlFile,uploadFile)
                    else:
                        print "  Skipping:  " + (xmlFile).ljust(printPadding) + " to  "+uploadFile 


        #########################################################################
        # FW files
        #########################################################################                
        print
        print "========================================"
        print "Processing bit files"
        print "========================================"
        bitFiles=GetFilesToSend('bit/','top')
        printPadding=0
        for file in bitFiles:
            if(len(bitFiles[file])>printPadding):
                printPadding=len(bitFiles[file])+1
        for file in bitFiles:
            print "  Uploading: " + (bitFiles[file]).ljust(printPadding) + " to  "+file
            releaseFile(ReleaseJSON,bitFiles[file],file)
            
            
    
    except Exception as e:
        requests.delete(ReleaseJSON["url"],headers={"Authorization": "token "+token})
        requests.delete("https://api."+host+"/repos/"+project+"/"+repo+"/git/refs/tags/"+ReleaseJSON["tag_name"],headers={"Authorization": "token "+token})
        print "Error! Deleting partial release"
        print e


if __name__ == "__main__":
    main()
