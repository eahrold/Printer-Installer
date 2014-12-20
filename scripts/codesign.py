#!/usr/bin/python

'''
    Make sure nested Frameworks get properly signed,
    (in the Version/A folder).

    Place this file in a folder named 'scripts' at
    the root of your project.

    Add this next line (including quotes) as a "Run Script"
    AFTER all copy file phases. Including the Copy Pods Resources phase

    "${PROJECT_DIR}/scripts/codesign.py"

    Note: If you have `--deep` set on any of your codesign
    flags remove it!

'''

import os
import subprocess


# Since it's hard to see exactly what's happening on runscripts
# set this to True to turn on debug logging.
debug = True


def log(message, new=False):
    global debug

    if debug:
        mode = 'w' if new else 'a'
        logfile = '/tmp/_xcode_build.log'
        with open(logfile, mode) as f:
            f.write('%s\n' % message)


def checkVar(var, description):
    log('Checking %s:%s\n' % (description, var))
    if not var:
        print('The variable %s is blank.' % description)
        return False
    else:
        return True


def deepSign(path, identity, deep=False):
    log('Checking Path %s\n' % (path))
    if os.path.exists(path):
        log('Signing %s\n' % (path))
        sign_cmd = [
            'codesign',
            '--verbose',
            '--force',
        ]

        if deep:
            sign_cmd.append('--deep')

        sign_cmd.extend(['--sign','%s' % identity, path])

        log('%s\n' % ' '.join(sign_cmd))

        p1 = subprocess.Popen(
            sign_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        output, err = p1.communicate()

        if output:
            log('%s\n' % output)
        if err:
            log('ERROR: %s\n' % err)

        if not p1.returncode == 0:
            log('ERROR: Problem signing item at %s [rc: %s]\n' % (path,output))


def checkSigning(path):
    sign_cmd = ['codesign', '-vvvv', path]
    log('%s\n' % ' '.join(sign_cmd))

    p1 = subprocess.Popen(
        sign_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    output, err = p1.communicate()

    if output:
        log('%s\n' % output)
    if err:
        log('ERROR: %s\n' % err)


def main():
    # Configure info from environment
    log('### Starting Run Script ####\n\n', new=True)

    identity = os.getenv('CODE_SIGN_IDENTITY')
    log('Signing with identity %s\n' % identity)

    build_dir = os.getenv('BUILT_PRODUCTS_DIR')
    checkVar(build_dir, 'BUILT_PRODUCTS_DIR')

    app_path = os.getenv('CODESIGNING_FOLDER_PATH')
    checkVar(app_path, 'PRODUCT_NAME')

    # Sign all of the frameworks in our build directory
    frameworks_folder_path = os.getenv('FRAMEWORKS_FOLDER_PATH')
    frameworks_path = os.path.join(build_dir, frameworks_folder_path)


    log('Checking frameworks path: %s' % frameworks_path)
    frameworks = []
    if os.path.exists(frameworks_path):
        frameworks = os.listdir(frameworks_path)

    log('Found frameworks: %s' % frameworks)

    for i in frameworks:
        path = os.path.join(
            frameworks_path,
            i,
            'Versions',
            'A'
        )
        deepSign(path, identity, deep=True)

    # Sign any of our helper tools
    launch_service_path = os.path.join(
        app_path,
        'Contents',
        'Library',
        'LaunchServices'
    )

    if os.path.exists(launch_service_path):
        helpers = os.listdir(launch_service_path)
        log(helpers)
        log(launch_service_path)
        for i in helpers:
            path = os.path.join(launch_service_path, i)
            deepSign(path, identity)

    # Verify that everything is signed correctly
    checkSigning(app_path)

    log('### Done with RunScript####\n\n')


if __name__ == '__main__':
    main()
