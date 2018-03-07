import base64, json, os, tempfile, time, sys, urllib3, logging

from google.cloud import pubsub_v1
from google.cloud import firestore
from opencensus.trace import config_integration
from opencensus.trace import tracer as tracer_module
from opencensus.trace import link as trace_link
from opencensus.trace import status as trace_status
from opencensus.trace.exporters import stackdriver_exporter
from opencensus.trace.exporters import print_exporter
from opencensus.trace.exporters import zipkin_exporter
import requests

# disable SSL warnings for older python version
urllib3.disable_warnings()

# Start logging (this wasn't getting created automatically)
logging.info('Starting worker...')

project = os.environ.get('GCLOUD_PROJECT')
subscription_name = os.environ.get('PUBSUB_SUBSCRIPTION')

"""Receives messages from a pull subscription."""
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(
    project, subscription_name)

def callback(message):
    print('Received message: {}'.format(message))
    tracer = get_tracer(message.attributes['traceId'])
    try:
        with tracer.span(name='worker'):
            documentId = message.attributes['documentId']
            imageName = message.attributes['imageName']
            payload = json.loads(message.data)

            baseImageFile = tempfile.NamedTemporaryFile()
            baseImageFile.write(base64.b64decode(payload['baseImage']));

            faceImageFile = tempfile.NamedTemporaryFile()
            faceImageFile.write(base64.b64decode(payload['faceImage']));

            outputFile = tempfile.NamedTemporaryFile(suffix='.jpg')

            dir_path = os.path.dirname(os.path.realpath(__file__))

            with tracer.span(name='exec faceswap'):
                os.system('%s/faceswap.py %s %s %s' % (
                    dir_path, baseImageFile.name, faceImageFile.name, outputFile.name))

            update_firestore(documentId, imageName, outputFile.read())
    except:
        e = sys.exc_info()[0]
        tracer.start_span().status = trace_status.Status(0, str(e))
        raise
    finally:
        message.ack()
        tracer.finish()

def update_firestore(documentId, imageName, output):
    # Update the document
    db = firestore.Client()
    doc_ref = db.collection(u'faceswap').document(documentId)
    doc_ref.update({
        'img'+imageName: base64.b64encode(output)
    })

def get_tracer(traceId):
    exporter = stackdriver_exporter.StackdriverExporter(
        project_id=project)
    # exporter = print_exporter.PrintExporter()
    spanCtx = tracer_module.SpanContext(trace_id=str(traceId))
    tracer = tracer_module.Tracer(exporter=exporter, span_context=spanCtx)
    # config_integration.trace_integrations(['google_cloud_clientlibs'])
    return tracer

subscriber.subscribe(subscription_path, callback=callback)

# The subscriber is non-blocking, so we must keep the main thread from
# exiting to allow it to process messages in the background.
print('Listening for messages on {}'.format(subscription_path))

while True:
    time.sleep(60)
