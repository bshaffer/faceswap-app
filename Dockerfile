# The Google App Engine php runtime is Debian Jessie with PHP installed
# and various os-level packages to allow installation of popular PHP
# libraries. The source is on github at:
#   https://github.com/GoogleCloudPlatform/php-docker
FROM gcr.io/google_appengine/php72

ENV DOCUMENT_ROOT=${APP_DIR}/web

# Get dependencies for python faceswap
COPY scripts/install_platform_deps.sh /app/scripts/install_platform_deps.sh
RUN scripts/install_platform_deps.sh

COPY scripts/install_opencv.sh /app/scripts/install_opencv.sh
RUN scripts/install_opencv.sh

COPY scripts/install_dlib.sh /app/scripts/install_dlib.sh
RUN scripts/install_dlib.sh

COPY scripts/install_models.sh /app/scripts/install_models.sh
RUN scripts/install_models.sh

# Set Faceswap Model Path
ENV FACESWAP_PREDICTOR_PATH "/etc/shape_predictor_68_face_landmarks.dat"

COPY composer.* /app/
RUN composer install

COPY . /app
COPY php.ini /opt/php/lib/conf.d
