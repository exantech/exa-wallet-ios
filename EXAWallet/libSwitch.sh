#!/bin/bash
usage="$(basename "$0") [-h] [-a] [-d] [-p] [-l path] -- Program to switch prebuilded libs in project

Where:
    -h  Show this help text
    -d  Develop build
    -p  Production build
    -l  Project root dir path
    -a  Prepare libs for switch from Carthage dit"

declare -a archToDelete=("i386" "x86_64")
PROJECT_DIR=$(pwd)
CARTHAGE_BUID_DIR=$PROJECT_DIR/Carthage/Build/iOS/
LIBS_DIR=$PROJECT_DIR/libs
ALL_ARCH=$LIBS_DIR/all
ARM_ARCH=$LIBS_DIR/arm
FRAMEWORK_MASK="*.framework"
DEBUG=false
PRODUCTION=false
PREPARE_LIB=false

while getopts ':hadpl:p:' option; do
  case "$option" in
    h) echo "$usage"
       exit ;;
    a) PREPARE_LIB=true ;;
    l) PROJECT_PATH=$OPTARG ;;
    d) DEBUG=true ;;
    p) PRODUCTION=true ;;
    :) printf "⚠️  Missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "⚠️  Illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done

if $PREPARE_LIB ; then
  echo "👷‍ Preparing libs for switching"
  carthage update --platform iOS --no-use-binaries
  BUILD_RESULT=$?
  if [ $BUILD_RESULT -ne 0 ]; then
    echo "⚠️  Failed Carthage build"
    exit 1
  fi
  echo "Do libs"
  cd $CARTHAGE_BUID_DIR
  for frimeworkDir in $FRAMEWORK_MASK; do
    filename=${frimeworkDir%.framework}
    cp $frimeworkDir/$filename $ALL_ARCH/$filename
    cp $ALL_ARCH/$filename $ARM_ARCH/$filename
    for arch in "${archToDelete[@]}"; do
      echo "Remove $arch from $filename"
      lipo -remove $arch $ARM_ARCH/$filename -output $ARM_ARCH/$filename
    done
    file $ARM_ARCH/$filename
  done

  cd $PROJECT_DIR
  exit
fi


if $DEBUG && $PRODUCTION ; then
  printf "⚠️  You can choose only one build variant!\n" >&2
  exit 1
fi

if ! $DEBUG && ! $PRODUCTION ; then
  printf "⚠️  Choose build variant \n" >&2
  exit 1
fi

if $DEBUG ; then
  printf "🔧  Debug build \n"
  cd $ALL_ARCH
else
  printf "📲  Production build \n"
  cd $ARM_ARCH
fi

echo "Coping Swift framework binaries to the project"
ls
pwd
IS_DEBUG_CARTHAGE=false
FIRST_FILE=$(ls | sort -n | head -1)
CARTHAGE_CURRENT_ARCH=$(nm $CARTHAGE_BUID_DIR/$FIRST_FILE.framework/$FIRST_FILE | grep '^0' | head -1 | sed 's/ .*//' | wc -c)
if ((CARTHAGE_CURRENT_ARCH == 17)) ; then
  IS_DEBUG_CARTHAGE=true
fi

if ( $DEBUG && ! $IS_DEBUG_CARTHAGE ) || ( $PRODUCTION && $IS_DEBUG_CARTHAGE ) ; then
  for LIB in $( ls ); do
    cp $LIB $CARTHAGE_BUID_DIR/$LIB.framework/$LIB
    file $CARTHAGE_BUID_DIR/$LIB.framework/$LIB
  done
else
  echo "Passed. Libs are already installed"
fi
