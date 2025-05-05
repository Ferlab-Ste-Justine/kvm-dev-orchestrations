#!/bin/sh

mkdir -p ../work-env;
(cd ../terracd; go build; cp terracd ../work-env/)
TERRAFORM_PATH=$(which terraform)
TERRAFORM_PATH=$(printf '%s\n' "$TERRAFORM_PATH" | sed 's/[\/&]/\\&/g')
sed "s/__TERRAFORM_PATH__/${TERRAFORM_PATH}/g" config.yml > ../work-env/config.yml
if [ -f ../work-env/dir1 ]; then
rm -r ../work-env/dir1
fi
cp -r dir1 ../work-env/dir1
if [ -f ../work-env/dir2 ]; then
rm -r ../work-env/dir2
fi
cp -r dir2 ../work-env/dir2
