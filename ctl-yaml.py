#!/usr/local/bin/python3
import os
import sys
import time
import json
import yaml

def getEnvironmentConfig():
    return { "fileIn": os.environ.get('FI_AUTH_FILE', 'auth.crypt'),
             "salt": os.environ.get('FI_SALT', 'xxxxx'),
             "password": os.environ.get('FI_PWD', 'yyyyy'),
             "keyLength": int( os.environ.get('FI_KEY_LENGTH', 132)),
             "keyIterations": int( os.environ.get('FI_KEY_ITERATIONS', 1100000)) }

cmd = sys.argv[1]
if cmd == "test":
    print( "test" )

elif cmd == "yamlRead":
    yamlFile = sys.argv[2]
    with open(yamlFile,'r') as f:
        yDocsList = list(yaml.safe_load_all(f))
        #yDocsList = [ doc for doc in yData ]

        for doc in yDocsList:
            if doc['kind'] == "Deployment":
                print( "" )
                print( doc.keys() )
                #print( "template: ", doc["spec"]["template"] )
                for i in doc["spec"]["template"].keys():
                    print( i, doc["spec"]["template"][i] )
                #print( doc["spec"].keys() )
                #for i in doc["spec"].keys():
                #    print( i, doc["spec"][i] )

