<?php

use Symfony\Component\HttpFoundation\Request;

$app = new Silex\Application();
$app->register(new Silex\Provider\TwigServiceProvider());
$app['twig.path'] = [ __DIR__ . '/../views' ];

$app->get('/', function (Request $request) use ($app) {
    return $app['twig']->render('index.html.twig');
});

$app->post('/', function (Request $request) use ($app) {
    $faceImageJpeg = file_get_contents(convert_image_to_jpeg($request->files->get('face_image')));
    $faceImageTemp = tempnam(sys_get_temp_dir(), 'face') . '.jpg';
    file_put_contents($faceImageTemp, $faceImageJpeg);

    $baseImageJpeg = file_get_contents(convert_image_to_jpeg($request->files->get('base_image')));
    $baseImageTemp = tempnam(sys_get_temp_dir(), 'base') . '.jpg';
    file_put_contents($baseImageTemp, $baseImageJpeg);

    $return_var = null;
    exec($cmd = sprintf(
        'python /app/worker/faceswap.py %s %s %s',
        $baseImageTemp,
        $faceImageTemp,
        $outputTemp = tempnam(sys_get_temp_dir(), 'out') . '.jpg'
    ), $output, $return_var);

    if ($return_var != 0) {
        return $app['twig']->render('index.html.twig', [
            'error' => 'error executing ' . $cmd . ': ' . implode('<br />', $output)
        ]);
    }

    return $app['twig']->render('index.html.twig', [
        'faceImage' => base64_encode($faceImageJpeg),
        'baseImage' => base64_encode($baseImageJpeg),
        'resultImage' => base64_encode(file_get_contents($outputTemp))
    ]);
});

return $app;
