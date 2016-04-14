#!/bin/bash

# armv7 arm64 i386 x86_64
ARCHS="armv7 arm64 i386 x86_64"

# Debug Release
BUILD_CONFIG="Release NoLinkLib NoOpenSSL"

# Product Directory
PRODUCT_DIR="Product"

# Lib Directory
LIBS_DIR="Libs"

# Origin Address
ORIGIN_ADDR=""

# Spec Name
SEPC_NAME=""


function BUILD_LIB()
{
    echo "start build" $1
    # for ARCH in $ARCHS
    # do
    #     echo "building $ARCH..."

    #     if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
    #     then
    #     XCRUN_SDK="iphonesimulator"
    #     export CFLAGS_CONFIG="-fembed-bitcode-marker"
    #     else
    #     XCRUN_SDK="iphoneos"
    #     export CFLAGS_CONFIG="-fembed-bitcode -Qunused-arguments"
    #     fi

    #     xcodebuild -configuration $1 clean build ARCHS=$ARCH -sdk $XCRUN_SDK TARGET_BUILD_DIR="./build-$ARCH" BUILT_PRODUCTS_DIR="./build-$ARCH" OTHER_CFLAGS="$OTHER_CFLAGS $CFLAGS_CONFIG"
    # done
    # lipo -create `find ./build-* -name libNIMLib.a` -output 'libNIMSDK.a'
}


function PUSH_GIT()
{
    SDK_DIR="SDK"
    SDK_NAME="libNIMSDK.a"
    SDK_HEADER_NAME="ExportHeaders"

    SDK_VERSION="1.0.0"

    echo "start push "$ORIGIN_ADDR
    mkdir -p $SDK_DIR

    git clone $ORIGIN_ADDR $SDK_DIR

    # rm -rf $SDK_DIR/$SDK_NAME
    # cp -rf $1"/"$SDK_NAME $SDK_DIR

    rm -rf $SDK_DIR/$SDK_HEADER_NAME
    cp -rf $1"/"$SDK_HEADER_NAME $SDK_DIR

    . spec.sh $SEPC_NAME $SDK_VERSION $ORIGIN_ADDR $SDK_DIR

    cd $SDK_DIR

    git add -A
    git commit -m "commit version"$SDK_VERSION
    git remote add origin $ORIGIN_ADDR

    git tag -d $SDK_VERSION
    git push origin :refs/tags/$SDK_VERSION

    git tag $SDK_VERSION
    git push --tag origin master

    pod lib lint NIMSDK.podspec

    cd ..

    #rm -rf $SDK_DIR
    echo "end push"
}


function ORIGIN_ADDRESS()
{
    if [ "$1" == "Release" ]
        then
        ORIGIN_ADDR=""
    fi

    if [ "$1" == "NoOpenSSL" ]
        then
        ORIGIN_ADDR="git@github.com:netease-im/NIM_iOS_SDK_NO_OPENSSL.git"
    fi
}

function SEPC()
{
    if [ "$1" == "Release" ]
        then
        SEPC_NAME="NIMSDK"
    fi

    if [ "$1" == "NoOpenSSL" ]
        then
        SEPC_NAME="NIMSDK_NO_OPENSSL"
    fi
}


for CONFIG in $BUILD_CONFIG
do
    BUILD_LIB $CONFIG

    echo "generate product..."

    BUILD_DIR=$PRODUCT_DIR'_'$CONFIG

    mkdir -p $BUILD_DIR
    # mv -f ./libNIMSDK.a $BUILD_DIR

    HEADERS_DIR=$BUILD_DIR/ExportHeaders

    cp -rf ./NIMLib/ExportHeaders/ $HEADERS_DIR

    rm -rf ./build ./build-* ./$BUILD_DIR/doc
    appledoc -o ./$BUILD_DIR/doc --project-name NIMSDK --project-company Netease --company-id com.netease.nimsdk  --keep-intermediate-files ./$BUILD_DIR
    docpath=$(awk '$1=="Path:" {print $2}' ./$BUILD_DIR/doc/docset-installed.txt)

    cp -rf $docpath ./$BUILD_DIR/doc
    rm ./$BUILD_DIR/doc/docset-installed.txt
    rm -rf ./$BUILD_DIR/doc/docset
    mv ./$BUILD_DIR/doc/html ./$BUILD_DIR/doc/NIMSDK-iOS

    if [ "$CONFIG" == "NoLinkLib" ]
        then
        LIB_PATH=./$BUILD_DIR/$LIBS_DIR 
        mkdir -p $LIB_PATH
        cp -rf ./NIMLib/Vendors/Libs/ $LIB_PATH
    fi

    ORIGIN_ADDRESS $CONFIG
    SEPC $CONFIG

    if [ "$ORIGIN_ADDR" != "" ]
        then
        PUSH_GIT $BUILD_DIR
    fi
    

done
echo "end build"

