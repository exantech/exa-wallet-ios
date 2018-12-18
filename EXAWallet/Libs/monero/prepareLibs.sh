#!/bin/bash

declare -a archToDelete=("i386" "x86_64")
LIBS_DIR=$(pwd)
ALL_ARCH=$LIBS_DIR/all
ARM_ARCH=$LIBS_DIR/arm
LIB_MASK="*.a"

echo "Lipo libs"
cd $ARM_ARCH
for lib in $LIB_MASK; do
  filename=${lib}
  echo $filename

  for arch in "${archToDelete[@]}"; do
    echo "Remove $arch from $filename"
    lipo -remove $arch $ARM_ARCH/$filename -output $ARM_ARCH/$filename
  done
  file $ARM_ARCH/$filename
done

cd $LIBS_DIR
exit
