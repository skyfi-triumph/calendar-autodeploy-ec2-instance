#!/bin/bash

rm ./calendar_pull_event.zip
# create and enter the virtualenv
python3 -m venv ./lambda_virtualenv
source lambda_virtualenv/bin/activate
# install Lambda function dependencies
pip3 install --upgrade pip
pip3 install -r requirements.txt
# zip up the dependencies
cd $VIRTUAL_ENV/lib/python3*/site-packages
zip -r ../../../../calendar_pull_event.zip .
cd - # ../../../../
# add the Lambda code to the zip file
zip -g calendar_pull_event.zip *.py
# destroy the virtualenv
deactivate
rm -rf ./lambda_virtualenv