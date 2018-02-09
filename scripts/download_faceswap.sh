# Download the library and the trained model and configure faceswap.py
git clone https://github.com/bshaffer/faceswap.git

curl -L \
    http://sourceforge.net/projects/dclib/files/dlib/v18.10/shape_predictor_68_face_landmarks.dat.bz2 \
    -o shape_predictor_68_face_landmarks.dat.bz2
bunzip2 shape_predictor_68_face_landmarks.dat.bz2

mv shape_predictor_68_face_landmarks.dat.bz2 faceswap/
mv faceswap /usr/local/lib
ln -s /usr/local/lib/faceswap/faceswap.py /usr/local/bin/
