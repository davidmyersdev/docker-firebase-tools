# docker-firebase-cli

A docker container for https://firebase.google.com/docs/cli - aka firebase-tools

## Usage

#### Basic

```shell
docker run -it -e FIREBASE_PROJECT_ID=project-123 -p 4000:4000 -p 8080:8080 avigorousdev/firebase-cli
```

#### Firebase CLI Authorization

https://firebase.google.com/docs/cli#cli-ci-systems

Generate the authorization URL.

```shell
# port 9005 is required for the oauth redirect
docker run -it -e FIREBASE_PROJECT_ID=project-123 -p 9005:9005 avigorousdev/firebase-cli login:ci
```

This should give you a URL similar to the following.

```
https://accounts.google.com/o/oauth2/auth?client_id=abc-123.apps.googleusercontent.com&scope=email%20openid%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloudplatformprojects.readonly%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffirebase%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform&response_type=code&state=123&redirect_uri=http%3A%2F%2Flocalhost%3A9005
```

Visit this URL on your host machine to authorize Firebase CLI via OAuth. After authorizing, you should see an auth token in your terminal.

Run the docker container with the auth token as `FIREBASE_TOKEN` to use any `firebase-tools` features that require authorization. This token can be reused across containers, but you can always generate a new one by following the steps above.

```shell
docker run -it -e FIREBASE_TOKEN=token-123 -e FIREBASE_PROJECT_ID=project-123 -p 4000:4000 -p 8080:8080 avigorousdev/firebase-cli
```
