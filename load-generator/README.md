# How to I build the Load Generator docker image?

Make sure you have Docker installed and run the following command in the `load-generator` folder:  

```
docker build -t load-generator .
```

# How to test the Load Generator docker image locally?

After you have built the image, you can run it by executing:  

```
docker run --name load-generator \
    -e JAVA_OPTS="-DBASE_URL=http://nlb-wiremock-backend-2b34b5f85b8ba33b.elb.eu-central-1.amazonaws.com:8080" \
    --rm -it \
    load-generator
```

```
docker run -it --rm \
    -v $(PWD)/src/gatling/conf:/opt/gatling/conf \
    -v $(PWD)/src/gatling/user-files:/opt/gatling/user-files \
    -v $(PWD)/src/gatling/results:/opt/gatling/results \
    -e JAVA_OPTS="-DBASE_URL=http://nlb-wiremock-backend-2b34b5f85b8ba33b.elb.eu-central-1.amazonaws.com:8080" \
    denvazh/gatling:3.2.1
```

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













# Maven build steps
`./mvnw clean package`

# Docker build steps
`docker build -t 0-spring-fargate .`  

#RUN THE APPLICATION IN DOCKER LOCALLY
`AWS_ACCESS_KEY_ID=$(aws --profile default configure get aws_access_key_id)`  

`AWS_SECRET_ACCESS_KEY=$(aws --profile default configure get aws_secret_access_key)`  

`AWS_REGION=$(aws --profile default configure get region)`  

`docker run -it --rm -e AWS_REGION=$AWS_REGION -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e PORT=80 -p 80:80 0-spring-fargate:latest`  

## Store a Pet
`curl -i -X POST -d '{"name": "Max", "type": "dog", "birthday": "2010-11-03", "medicalRecord": "bla bla bla"}' -H "Content-Type: application/json" http://localhost/pet` 

# Upload to Amazon ECR
`aws ecr create-repository --repository-name 0-spring-fargate`  

`$(aws ecr get-login --no-include-email --region eu-central-1)`  

`docker tag 0-spring-fargate:latest 689573718314.dkr.ecr.eu-central-1.amazonaws.com/0-spring-fargate:latest`  

`docker push 689573718314.dkr.ecr.eu-central-1.amazonaws.com/0-spring-fargate:latest`  

```
aws cloudformation create-stack \
    --stack-name spring-fargate \
    --template-body file://template.yaml \
    --capabilities CAPABILITY_IAM
```


```
aws cloudformation wait stack-create-complete \
    --stack-name spring-fargate
```