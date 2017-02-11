#!/bin/sh

PREFIX=$HOME/.local

# Dep tree:
#
#      Cura
#     /    \
#    /      \
# Uranium  CuraEngine
#    \      /
#     \    /
#    libArcus
#

clone_if_needed(){
    if [ ! -d $1 ]; then
        echo "cloning $1..."
        git clone git://github.com/Ultimaker/$1
    else
        echo "updating $1..."
        (cd $1; git pull)
    fi
}

cmake_build(){
    echo "building $1..."
    (
        cd $1
        sed 's#${PYTHON_VERSION_MAJOR}/dist-packages#${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages#g' -i CMakeLists.txt
        rm -rf build
        mkdir -p build
        (
            cd build
            cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX $2
            make -j10
            make install
        )
        git checkout CMakeLists.txt
    )
}

clone_if_needed libArcus
clone_if_needed Uranium
clone_if_needed CuraEngine
clone_if_needed Cura

cmake_build libArcus
cmake_build Uranium
cmake_build CuraEngine
cmake_build Cura -DURANIUM_SCRIPTS_DIR=
