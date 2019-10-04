echo "Downloading gcc source files..."
if [ ! -d "gcc-5.4.0-build" ]; then
    curl https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.bz2 -O
    echo "extracting files..."
    tar xvfj gcc-5.4.0.tar.bz2

    echo "Installing dependencies..."
    sudo yum install gcc-c++ gmp-devel mpfr-devel libmpc-devel -y

    echo "Configure and install..."
    mkdir gcc-5.4.0-build
    cd gcc-5.4.0-build
    ../gcc-5.4.0/configure --enable-languages=c,c++ --disable-multilib
    make -j$(nproc) && sudo make install
    sudo ldconfig
    cd ../
fi

