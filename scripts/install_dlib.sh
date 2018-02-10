mkdir -p dlib-tmp
cd dlib-tmp

curl -L \
     https://github.com/davisking/dlib/archive/v19.0.tar.gz \
     -o dlib.tar.bz2

tar xf dlib.tar.bz2

mkdir -p dlib-19.0/python_examples/build
cd dlib-19.0/python_examples/build

cmake ../../tools/python

cmake --build . --config Release

cp dlib.so /usr/local/lib/python2.7/dist-packages

pip install dlib

cd ../../../..
rm -rf ./dlib-tmp