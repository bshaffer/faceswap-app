<?php

/**
 * Convert an image to JPEG
 */
function convert_image_to_jpeg($imagePath)
{
    // jpg, png, gif or bmp?
    if (false === $imgInfo = getimagesize($imagePath)) {
        throw new InvalidArgumentException('Image not found or not an image');
    }

    switch ($imgInfo[2]) {
        case IMAGETYPE_GIF:
            $src = imagecreatefromgif($imagePath);
            break;
        case IMAGETYPE_JPEG:
            // Do nothing! We are already JPEG format
            $src = imagecreatefromjpeg($imagePath);
            break;
        case IMAGETYPE_PNG:
            $src = imagecreatefrompng($imagePath);
            break;
        default:
            throw new InvalidArgumentException('Unsupported filetype');
    }

    $src = imagescale($src, 700);
    imagejpeg($src, $imagePath . '.jpg');
    imagedestroy($src);
    return $imagePath . '.jpg';
}

function create_firestore_document($projectId)
{
    // create authorized HTTP client
    $http = Google\Auth\CredentialsLoader::makeHttpClient(
        Google\Auth\ApplicationDefaultCredentials::getCredentials(
            'https://www.googleapis.com/auth/datastore'
        )
    );
    // create a firestore document
    $path = "https://firestore.googleapis.com/v1beta1/projects/$projectId/databases/(default)/documents/faceswap";
    $response = $http->request('post', $path);
    // return the document ID
    $json = json_decode((string) $response->getBody(), true);
    return @end(explode('/', $json['name']));
}
