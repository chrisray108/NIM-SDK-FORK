#!/bin/bash

# i am tester
# armv7 arm64 i386 x86_64
ARCHS="armv7 arm64 i386 x86_64"

# Debug Release
BUILD_CONFIG="Release NoLinkLib NoOpenSSL"

# Product Directory
PRODUCT_DIR="Product"

# Lib Directory
LIBS_DIR="Libs"


echo "start build"

for CONFIG in $BUILD_CONFIG
do
    BUILD_LIB CONFIG

    echo "generate product..."

    BUILD_DIR=$PRODUCT_DIR'_'$CONFIG

    mkdir -p $BUILD_DIR
    mv -f ./libNIMSDK.a $BUILD_DIR

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

    ORIGIN=ORIGIN_ADDRESS CONFIG
    
    PUSH_GIT $BUILD_DIR ORIGIN

done
echo "end build"


function BUILD_LIB()
{
    echo "start build" $1
    for ARCH in $ARCHS
    do
        echo "building $ARCH..."

        if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
        then
        XCRUN_SDK="iphonesimulator"
        export CFLAGS_CONFIG="-fembed-bitcode-marker"
        else
        XCRUN_SDK="iphoneos"
        export CFLAGS_CONFIG="-fembed-bitcode -Qunused-arguments"
        fi

        #xcodebuild -configuration $1 clean build ARCHS=$ARCH -sdk $XCRUN_SDK TARGET_BUILD_DIR="./build-$ARCH" BUILT_PRODUCTS_DIR="./build-$ARCH" OTHER_CFLAGS="$OTHER_CFLAGS $CFLAGS_CONFIG"
    done
    #lipo -create `find ./build-* -name libNIMLib.a` -output 'libNIMSDK.a'
}

function PUSH_GIT()
{
    SDK_DIR="SDK"
    SDK_NAME="libNIMSDK.a"
    SDK_HEADER_NAME="ExportHeaders"

    SDK_VERSION="2.1.0"
    ORIGIN_ADDRESS=$2 

    echo "start push"
    mkdir -p $SDK_DIR

    git clone $ORIGIN_ADDRESS $SDK_DIR

    # rm -rf $SDK_DIR/$SDK_NAME
    # cp -rf $1"/"$SDK_NAME $SDK_DIR

    rm -rf $SDK_DIR/$SDK_HEADER_NAME
    cp -rf $1"/"$SDK_HEADER_NAME $SDK_DIR

    cd $SDK_DIR

    git add -A
    git commit -m "commit version"$SDK_VERSION
    git remote add origin $ORIGIN_ADDRESS

    git tag -d $SDK_VERSION
    git push origin :refs/tags/$SDK_VERSION

    git tag $SDK_VERSION
    git push --tag origin master

    cd ..

    rm -rf $SDK_DIR

    echo "end push"
}



function ORIGIN_ADDRESS()
{
    if [ $1 == "Release" ]
        return "git@github.com:netease-im/NIM_iOS_SDK.git"
    fi
    if [ $1 == "NoLinkLib" ]
        return ""
    fi
    if [ $1 == "NoOpenSSL" ]
        return "git@github.com:netease-im/NIM_iOS_SDK_NO_OPENSSL.git"
    fi
}



