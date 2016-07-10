provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_api_gateway_rest_api" "ChainsAPI" {
  name = "Chains"
}

resource "aws_api_gateway_resource" "CounterResource" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.ChainsAPI.root_resource_id}"
  path_part = "counter"
}

resource "aws_api_gateway_method" "CounterGet" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  resource_id = "${aws_api_gateway_resource.CounterResource.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "CounterMock" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  resource_id = "${aws_api_gateway_resource.CounterResource.id}"
  http_method = "${aws_api_gateway_method.CounterGet.http_method}"
  type = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  resource_id = "${aws_api_gateway_resource.CounterResource.id}"
  http_method = "${aws_api_gateway_method.CounterGet.http_method}"
  status_code = 200
  response_models = {
    "application/json" = "CounterModel"
  }
}

resource "aws_api_gateway_integration_response" "CounterMockResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  resource_id = "${aws_api_gateway_resource.CounterResource.id}"
  http_method = "${aws_api_gateway_method.CounterGet.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  response_templates = {
    "application/json" = "{ \"value\": 42 }"
  }
}

resource "aws_api_gateway_model" "CounterModel" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  name = "CounterModel"
  content_type = "application/json"
  schema = "${file("model.json")}"
}

resource "aws_api_gateway_deployment" "ChainsTestDeployment" {
  rest_api_id = "${aws_api_gateway_rest_api.ChainsAPI.id}"
  stage_name = "test"
  depends_on = ["aws_api_gateway_method.CounterGet"]
}

output "url" {
  value = "https://${aws_api_gateway_rest_api.ChainsAPI.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.ChainsTestDeployment.stage_name}"
}
