# Python CRUD Serverless App: API Gateway, AWS Lambda, and DynamoDB. 

##Additional info
The python code for this application was from the following youtube video: https://www.youtube.com/watch?v=9eHh946qTIk.

Create IaC to make this Serverless Application a one-click deployment.

Note the DynanmoDB database will not have any product data in it. Therefore, data will need to be imported to DynamoDB or created manually. 

This API Gateway is a Regional Deployment, and thus publicily accessible.

Due to an issue with the source_arn for the aws_lambda_permission for the Lambda permissions, it is omitted from IaC. When manaually creating through the console, every API method is added to the Statement ID and triggers. When I had the source arn as: source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/*/*" it would only add one trigger to the API. Therefore, other triggers/resouces would fail to invoke Lambda.

Current bug in the programming, if you try to make a GET call to /product without adding a querying parameter for the productID, you will get a 404 error. 

These APIs do not require API keys.
