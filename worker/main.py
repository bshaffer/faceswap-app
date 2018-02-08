# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import tempfile, os, sys, base64

from flask import Flask, request, current_app

def create_app():
    app = Flask(__name__)

    # Add a default root route.
    @app.route("/", methods=['POST'])
    def post():
        faceImage = request.json.get('faceImage', None)
        baseImage = request.json.get('baseImage', None)
        if not faceImage or not baseImage:
            return 'Please supply the "faceImage" and "baseImage" arguments'

        tmpFace = tempfile.NamedTemporaryFile()
        tmpBase = tempfile.NamedTemporaryFile()
        tmpFace.write(base64.b64decode(faceImage))
        tmpBase.write(base64.b64decode(baseImage))
        output = tempfile.NamedTemporaryFile(suffix='.jpg')

        os.system('faceswap.py %s %s %s' % (tmpBase.name, tmpFace.name, output.name))
        return base64.b64encode(output.read())
    return app

app = create_app()

# This is only used when running locally. When running live, gunicorn runs
# the application.
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
