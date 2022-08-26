
output "api-gateway-url" {
  value = "${aws_api_gateway_stage.example.invoke_url}"
}

output "product-url" {
  value = "${aws_api_gateway_stage.example.invoke_url}:/:${aws_api_gateway_resource.product.path_part}"
}
output "health-url" {
  value = "${aws_api_gateway_stage.example.invoke_url}:${var.stage-name}:${aws_api_gateway_resource.health-api.path_part}"
}
output "products-url" {
  value = "${aws_api_gateway_stage.example.invoke_url}:${var.stage-name}:${aws_api_gateway_resource.products-api.path_part}"
}
