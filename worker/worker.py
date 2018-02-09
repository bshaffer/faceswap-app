import base64, json, os, tempfile, time, sys, urllib3

from google.cloud import pubsub_v1
from google.cloud import firestore

# disable SSL warnings for older python version
urllib3.disable_warnings()

# unbuffer stdout for logging purposes
sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)

project = os.environ.get('GCLOUD_PROJECT')
subscription_name = os.environ.get('PUBSUB_SUBSCRIPTION')

"""Receives messages from a pull subscription."""
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(
    project, subscription_name)

def callback(message):
    print('Received message: {}'.format(message))
    documentId = message.attributes['documentId']
    imageName = message.attributes['imageName']
    payload = json.loads(message.data)

    baseImageFile = tempfile.NamedTemporaryFile()
    baseImageFile.write(base64.b64decode(payload['baseImage']));

    faceImageFile = tempfile.NamedTemporaryFile()
    faceImageFile.write(base64.b64decode(payload['faceImage']));

    outputFile = tempfile.NamedTemporaryFile(suffix='.jpg')

    os.system('faceswap.py %s %s %s' % (
        baseImageFile.name, faceImageFile.name, outputFile.name))

    update_firestore(documentId, imageName, outputFile.read())

    message.ack()

def update_firestore(documentId, imageName, output):
    # Update the document
    db = firestore.Client()
    doc_ref = db.collection(u'faceswap').document(documentId)
    doc_ref.update({
        'img'+imageName: base64.b64encode(output)
    })

subscriber.subscribe(subscription_path, callback=callback)

# The subscriber is non-blocking, so we must keep the main thread from
# exiting to allow it to process messages in the background.
print('Listening for messages on {}'.format(subscription_path))
while True:
    time.sleep(60)
