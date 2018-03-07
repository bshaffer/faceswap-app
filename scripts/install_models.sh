# configure faceswap.py
curl -L \
    'https://github.com/davisking/dlib-models/blob/6a82ae1d20e9f5ca2a68156344d927da4d4d45e7/shape_predictor_68_face_landmarks.dat.bz2?raw=true' \
    -o shape_predictor_68_face_landmarks.dat.bz2

bunzip2 shape_predictor_68_face_landmarks.dat.bz2

mv shape_predictor_68_face_landmarks.dat /etc
