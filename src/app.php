<?php

use Google\Cloud\PubSub\PubSubClient;
use Symfony\Component\HttpFoundation\Request;

/** Set up tracing integration */
use OpenCensus\Trace\Tracer;
use OpenCensus\Trace\Exporter\StackdriverExporter;
use OpenCensus\Trace\Integrations\Curl;

Tracer::start(new StackdriverExporter());
Curl::load();

$app = new Silex\Application();
$app->register(new Silex\Provider\TwigServiceProvider());
$app['twig.path'] = [ __DIR__ . '/../views' ];
$app['apiKey'] = getenv('FIREBASE_API_KEY');
$app['projectId'] = getenv('GCLOUD_PROJECT');


$app->get('/', function (Request $request) use ($app) {
    return $app['twig']->render('index.html.twig');
});

$app->post('/', function (Request $request) use ($app) {
    $documentId = create_firestore_document($app['projectId']);
    $pubsub = new PubSubClient([
        'projectId' => $app['projectId'],
    ]);
    $topic = $pubsub->topic(getenv('PUBSUB_TOPIC'));
    try {
        $faceImageJpeg = convert_image_to_jpeg($request->files->get('face_image'));
        $faceImage = base64_encode(file_get_contents($faceImageJpeg));

        $baseImages = [];
        foreach ($request->files->get('base_images') as $i => $image) {
            $baseImageJpeg = convert_image_to_jpeg($image);
            $baseImage = base64_encode(file_get_contents($baseImageJpeg));

            $topic->publish([
                'data' => json_encode([
                    'faceImage' => $faceImage,
                    'baseImage' => $baseImage,
                ]),
                'attributes' => [
                    'imageName' => (string) $i,
                    'documentId' => $documentId,
                    'traceId' => Tracer::spanContext()->traceId(),
                ]
            ]);

            $baseImages[$i] = $baseImage;
        }

        $twigVars = [
            'faceImage' => $faceImage,
            'baseImages' => $baseImages,
            'documentId' => $documentId,
            'cols' => ceil(sqrt(count($baseImages))),
        ];
    } catch (Exception $e) {
        $twigVars = ['error' => $e->getMessage()];
    }

    return $app['twig']->render('index.html.twig', $twigVars);
});

return $app;
