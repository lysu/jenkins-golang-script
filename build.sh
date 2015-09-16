#!/usr/bin/env bash

export PATH="/usr/local/go/bin/:$PATH"

MODULE_NAME=[modulename] #fix me
MODULE_PATH=[github.com/company/modulename] #fix me
VCS_PATH=$GIT_URL

go version

### create a GOPATH env to build

/usr/bin/find $WORKSPACE -name ".git" -print0 | xargs -0 -I% rm -fr %
/usr/bin/find $WORKSPACE -name ".gitignore" -print0 | xargs -0 -I% rm -f %

GOPATH=${WORKSPACE%/*}/go
[ -d $GOPATH ] || mkdir -p $GOPATH

export GOPATH="$GOPATH"

go get github.com/tools/godep

export PATH=$GOPATH/bin:$PATH

GO_BUILD_DIR=$GOPATH/src/$MODULE_PATH

mkdir -p $GO_BUILD_DIR

rsync -az $WORKSPACE/ $GO_BUILD_DIR

ls -al $GO_BUILD_DIR

cd $GO_BUILD_DIR

godep go build

### build rpm package

mkdir -p $WORKSPACE/output/{bin,logs,conf}

cp $GO_BUILD_DIR/$MODULE_NAME $WORKSPACE/output/bin/$MODULE_NAME
cp $GO_BUILD_DIR/conf/* $WORKSPACE/output/conf

FPM_WORK=${WORKSPACE%/*}/fpm_work
[ -d $FPM_WORK ] || mkdir -p $FPM_WORK

RPM_ROLE=online
RPM_NAME=${MODULE_NAME}-${RPM_ROLE}

BUILDTIME=$(date +"%Y%m%d%H%M%S")
TAG=${RPM_NAME}-${BUILD_NUMBER}-${BUILDTIME}

cd $WORKSPACE/output && /usr/bin/fpm -s dir -t rpm -p $FPM_WORK -n ${RPM_NAME} -v $BUILD_NUMBER --iteration $(date +"%Y%m%d%H%M%S") --license 'Copyright' --prefix /home/xx/$MODULE_NAME --directories "/home/xx/$MODULE_NAME" --url $VCS_PATH --vendor xx.com --rpm-user xx --rpm-group xx --description "$PROJECT_NAME $MODULE_NAME" --workdir $FPM_WORK .

######################################
### at here we can distribute our rpm
######################################

### Clean up
cd $FPM_WORK && [ -f ${RPM_NAME}-${BUILD_NUMBER}-*.rpm ] && rm -f ${RPM_NAME}-${BUILD_NUMBER}-*.rpm

cd $WORKSPACE

rm -rf *

ls -la $WORKSPACE

cd $GOPATH/src

rm -rf *

ls -la $GOPATH/src
###
