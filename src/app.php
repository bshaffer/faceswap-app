<?php

use Symfony\Component\HttpFoundation\Request;

$app = new Silex\Application();
$app->register(new Silex\Provider\TwigServiceProvider());
$app['twig.path'] = [ __DIR__ . '/../views' ];

$app->get('/', function (Request $request) use ($app) {
    return $app['twig']->render('index.html.twig');
});

$app->post('/', function (Request $request) use ($app) {
    try {
        $faceImageJpeg = convert_image_to_jpeg($request->files->get('face_image'));
        $faceImage = base64_encode(file_get_contents($faceImageJpeg));

        $baseImageJpeg = convert_image_to_jpeg($request->files->get('base_image'));
        $baseImage = base64_encode(file_get_contents($baseImageJpeg));

        $http = new GuzzleHttp\Client();
        $result = $http->post('localhost:8081', [
            'json' => [
                'faceImage' => $faceImage,
                'baseImage' => $baseImage,
            ]
        ]);

        $twigVars = [
            'faceImage' => $faceImage,
            'baseImage' => $baseImage,
            'resultImage' => (string) $result->getBody(),
        ];
    } catch (Exception $e) {
        $twigVars = ['error' => $e->getMessage()];
    }

    return $app['twig']->render('index.html.twig', $twigVars);
});

return $app;
