# How to I build the WireMock docker image?


Make sure you have Docker installed and run the following command in the `wiremock-backend` folder:  
```
docker build -t wiremock-backend .
```

# How to test the WireMock docker image locally?

After you have built the image, you can run it by executing:  

```
docker run --rm -it -p 8080:8080 wiremock-backend
```

You should now be able to access the Admin UI under [http://localhost:8080/__admin/](http://localhost:8080/__admin/).

You can also pass Wiremock arguments to it. E.g. by executing:

```
docker run -it --rm -p 8443:8443 wiremock-backend --https-port 8443 --verbose
```

you should be able to access the Admin UI under the sucure URL [https://localhost:8080/__admin/](https://localhost:8080/__admin/) and see the verbose output.

# How to push it to your Amazon ECR repository?

After you have built the image, you can create an Amazon ECR repository:

```
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr create-repository \
    --repository-name wiremock-backend
```

... and push the image to it, by executing:

```bash
aws ecr get-login-password \
    --region eu-central-1 \
    | docker login --username AWS \
    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com
docker tag wiremock-backend:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/wiremock-backend:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/wiremock-backend:latest
```

# How to use the WireMock docker image?

By default, WireMock will listen on port 8080 for HTTP requests. You can test it, by browsing to the admin page, located at [http://localhost:8080/__admin/](http://localhost:8080/__admin/).  

You can than configure WireMock with posting REST requests as described [here](http://wiremock.org/docs/running-standalone/) or by recording your requests as described [here](http://wiremock.org/docs/record-playback/).  

We have added already a set of WireMock mappings and files. You can test them by running:

```
curl -i http://localhost:8080/status
```

You should now see a similar result like this:  

```
HTTP/1.1 200 OK
Content-Type: application/json
Matched-Stub-Id: 76da8616-8aa0-41d1-bdb8-17c32310fc55
Vary: Accept-Encoding, User-Agent
Transfer-Encoding: chunked

{"status":"up"}
```

Now, execute:

```
curl -i http://localhost:8080/los
```

You should see an output like:

```
HTTP/1.1 200 OK
Content-Type: application/json
Matched-Stub-Id: 3f1ba879-4199-4669-81e0-1072f6d34546
Vary: Accept-Encoding, User-Agent
Transfer-Encoding: chunked

{
    "id":"1",
    "name": "Home",
    "coordinates": {
        "lat": "50.1411",
        "long": "8.4899"
    }
}
```

NOTE: The response for `http://localhost:8080/los` is delayed by 150ms - 300ms. If you want to change this, please take a look at the file `wiremock-root-dir/mappings/los.json`.

Congrats, you did it!