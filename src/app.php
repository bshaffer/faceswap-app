<?php

$app = new Silex\Application();

$app->get('/', function () use ($app) {
    $twigVars = [];
    $form = Symfony\Component\Form\Forms::createFormFactory()
        ->createBuilder('form')
        ->add('face_image', 'file', [
            'attr' => ['accept' => 'images/*']
        ])
        ->add('base_image', 'file', [
            'attr' => ['accept' => 'images/*'],
        ])
        ->getForm();

    $form->handleRequest();

    if ($form->isValid()) {
        try {
            $files = $app['files'];
            $faceImageJpeg = convert_image_to_jpeg($files['face_image']);
            $faceImage = base64_encode(file_get_contents($faceImageJpeg));

            $baseImageJpeg = convert_image_to_jpeg($files['base_image']);
            $baseImage = base64_encode(file_get_contents($baseImageJpeg));

            $http = new GuzzleHttp\Client();
            $result = $http->get('faceswap-worker', [
                'json' => [
                    'faceImage' => $faceImage,
                    'baseImage' => $baseImage,
                ]
            ]);

            $twigVars['faceImage'] = $faceImage;
            $twigVars['baseImage'] = $baseImage;
            $twigVars['resultImage'] = $resultImage;
        } catch (Exception $e) {
            $twigVars['error'] = $e->getMessage();
        }
    }

    $twigVars['form'] = $form->createView();
    return $app['twig']->render('faceswap.html.twig', $twigVars);
});

return $app;
