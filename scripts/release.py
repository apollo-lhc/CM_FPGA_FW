#!/bin/env python

from git import Repo #interact with local git repo
import re #decode local repo
import requests #interact with github.com
import json # parse github return
import os


#find files
from os import listdir
from os.path import isfile, join

def GetFilesToSend(path,match):
    files=dict()
    for f in listdir(path):
        if isfile(join(path,f)):
            if f.find(match) >= 0:
                if f.find("~") == -1:
                    files[f]=join(path,f)
    return files


token=os.getenv("GH_TOKEN")
if token == None:
    print "Missing github oath token"
    quit()



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
if branch.find("release-v") == -1:
    print "Not on a release branch!"
    quit()
releaseVersion=branch[branch.find("release-v") + len("release-v"):]
print "Release:"+ releaseVersion



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


##Upload files and finalize the release
try:
    #dtsi files
    dtsiFiles=GetFilesToSend('os/hw','dtsi')
    addressTableFiles=GetFilesToSend('address_tables/modules/','xml')
    bitFiles=GetFilesToSend('bit/','top')
    
    #upload dtsi files
    for file in dtsiFiles:
        url=ReleaseJSON["upload_url"].replace("{?name,label}","?name=dtsi/"+file)
        print "Uploading: "+dtsiFiles[file]
        uploadFile=open(dtsiFiles[file])
        response=requests.post(url,data=uploadFile,headers = {"Authorization": "token "+token,"Content-Type": "application/octet-stream"})    
        uploadFile.close()
        if response.status_code != 201:
            raise Exception('Error ({0}) while uploading {1}'.format(response.status_code,file))
	
    #upload address table files        
    for file in addressTableFiles:
        url=ReleaseJSON["upload_url"].replace("{?name,label}","?name=modules/"+file)
        print "Uploading: "+addressTableFiles[file]
        uploadFile=open(addressTableFiles[file])
        response=requests.post(url,data=uploadFile,headers = {"Authorization": "token "+token,"Content-Type": "application/octet-stream"})    
        uploadFile.close()
        if response.status_code != 201:
            raise Exception('Error ({0}) while uploading {1}'.format(response.status_code,file))
	
    #Upload bit files
    for file in bitFiles:
        url=ReleaseJSON["upload_url"].replace("{?name,label}","?name="+file)
        print "Uploading: "+bitFiles[file]
        uploadFile=open(bitFiles[file])
        response=requests.post(url,data=uploadFile,headers = {"Authorization": "token "+token,"Content-Type": "application/octet-stream"})    
        uploadFile.close()
        if response.status_code != 201:
            raise Exception('Error ({0}) while uploading {1}'.format(response.status_code,file))



except Exception as e:
    requests.delete(ReleaseJSON["url"],headers={"Authorization": "token "+token})
