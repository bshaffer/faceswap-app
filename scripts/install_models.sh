# configure faceswap.py
curl -L \
    http://sourceforge.net/projects/dclib/files/dlib/v18.10/shape_predictor_68_face_landmarks.dat.bz2 \
    -o shape_predictor_68_face_landmarks.dat.bz2
bunzip2 shape_predictor_68_face_landmarks.dat.bz2

mv shape_predictor_68_face_landmarks.dat /etc
