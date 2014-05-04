#!/usr/bin/python

''' Make sure all your resources are properly signed
'''

import os
import subprocess
import plistlib
import logging

## since it's hard to see exactly what's happening on runscripts
## we do some loggin
logging.basicConfig(filename='/tmp/xcode_runscript.log',level=logging.DEBUG)


def checkVar(var,description):
    logging.info('Checking %s:%s\n' % (description,var))
    if var == "" or var == None:
        print ("the variable %s is blank" % description)
        exit(1)

def deepSign(path):
    logging.info('Signing %s\n' % (path))

    identity = os.getenv('CODE_SIGN_IDENTITY')
    result = subprocess.call(['codesign','--force','--deep','--sign',identity,path])
    if not result == 0:
        logging.error('Problem signing item at %s\n %s' % (path,result))


def signFrameworks(build_dir):
    frameworks_dir = os.getenv('FRAMEWORKS_FOLDER_PATH')
    frameworks_path = os.path.join(build_dir,frameworks_dir)
    frameworks = os.listdir(frameworks_path)

    for i in frameworks:
        checkVar(i,'framework')
        path = os.path.join(frameworks_path,i,'Versions','A')
        deepSign(path)
        
def main():
    # Configure info from environment
    logging.info('### Starting Run Script ####\n\n')

    identity = os.getenv('CODE_SIGN_IDENTITY')
    logging.info('Signing with identity %s\n' % identity)

    build_dir    = os.getenv('BUILT_PRODUCTS_DIR')
    checkVar(build_dir,'BUILT_PRODUCTS_DIR')
    
    app_path = os.getenv('CODESIGNING_FOLDER_PATH')
    checkVar(app_path,'PRODUCT_NAME')

    signFrameworks(build_dir)
    deepSign(app_path)
    logging.info('### Done with RunScript####\n\n')

    

if __name__ == "__main__":
    main()
