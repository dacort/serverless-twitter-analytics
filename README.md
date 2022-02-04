# Serverless Twitter Analytics

CloudFormation template and example SQL queries for [analyzing wordle tweets](https://dacort.dev/posts/serverless-analytics-of-twitter-data/).

## Overview

The CloudFormation template creates the following resources:
- VPC and related network resources including NAT/Internet Gateway and subnets
- Amazon S3 bucket for MSK Connect artifacts and data delivery
- Amazon MSK Cluster
- IAM Roles for Glue and MSK Connect
- Glue Crawler for 

Once the stack is up and running, you'll need to build/upload Connect artifacts as mentioned in the blog post and create the connectors manually.

## Twitter Connector Build

I used Docker to build the Twitter connector because I was having problems in my local environment. The following command builds the latest version and exports the zip file you need for MSK Connect to your local filesystem.

```shell
docker build --output . .
```

I could probably build/push artifacts via an EC2 instance: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-msk-cluster.html#aws-resource-msk-cluster-return-values

## Athena Queries

There are a bunch of example queries in [queries.sql](queries.sql).