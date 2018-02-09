mkdir opencv-tmp
cd opencv-tmp
curl -L \
    "http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/3.1.0/opencv-3.1.0.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopencvlibrary%2F&ts=1478094317&use_mirror=heanet" \
    -o opencv-3.1.0.zip

unzip opencv-3.1.0.zip

cmake opencv-3.1.0

apt-get update && apt-get install -y python-opencv

cd ..
rm -Rf ./opencv-tmp