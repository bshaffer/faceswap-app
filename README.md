# Faceswap

Code for talks on Kubernetes and Tracing, illustrated using a faceswap app. 

## Architecture

The app consists of a PHP frontend and a python backend.

The backend uses a machine learning algorithm to detect the faces in two images and swaps the face from one onto the other.

## Faceswap v1

The [`v1`](https://github.com/bshaffer/faceswap-app/tree/v1) branch performs a synchronous call to the backend processs

## Faceswap v2

The [`v2`](https://github.com/bshaffer/faceswap-app/tree/v2) branch uses messaging to asynchronously send images to get processed
and waits for a response on the frontend
