# How to I build the SmartProxy docker image?

Make sure you have Docker installed and run the following command in the `fargate-smart-proxy-scaling-demo-with-custom-metrics` folder:
```
export BACKEND_URL=nlb...
./mvnw clean package
docker build -t smart-proxy .
```


# How to run the SmartProxy locally?

Simply run the following command in the `fargate-smart-proxy-scaling-demo-with-custom-metrics` folder:

```
./mvnw spring-boot:run
```


# How to test the SmartProxy docker image locally?

After you have built the image, you can run it by executing:

```
docker run --rm -it -p 8080:8080 smart-proxy
```

You can test whether the SmartProxy running locally is healthy by executing:

```
curl -i http://localhost:8080/actuator
```

or 

```
curl -i http://localhost:8080/actuator/health
```

You can test the SmartProxy running locally by executing:

```
curl -i http://localhost:8080/los/1
```

You should now see a similar result like this:

```
HTTP/1.1 200
Matched-Stub-Id: 336e11a6-c68f-4440-9d38-e85c8fbe1328
Transfer-Encoding: chunked
Vary: Accept-Encoding, User-Agent
Custom-Header: smart-proxy
Content-Type: application/json
Transfer-Encoding: chunked
Date: Sat, 10 Jul 2021 20:06:26 GMT

{
    "id": "1",
    "name": "Home",
    "coordinates": {
        "lat": "50.1411",
        "long": "8.4899"
    }
}
```


# How to push it to your Amazon ECR repository?

After you have built the image, you can create an Amazon ECR repository:

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr create-repository \
    --repository-name smart-proxy
```

... and push the image to it, by executing:

```bash
aws ecr get-login-password \
    --region eu-central-1 \
    | docker login --username AWS \
    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com
docker tag smart-proxy:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/smart-proxy:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/smart-proxy:latest
```


