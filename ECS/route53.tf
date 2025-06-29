# # 1. Request ACM Certificate (Must come first)
# resource "aws_acm_certificate" "app" {
#   domain_name       = "taskmgr.mckeen.sg"
#   validation_method = "DNS"
#   lifecycle { create_before_destroy = true }
# }

# # 2. Automate DNS Validation (Route 53 CNAME Records)
# resource "aws_route53_record" "acm_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#   zone_id = var.hosted_zone_id  # Replace with your Route 53 Zone ID
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 60
# }

# # 3. Wait for ACM Validation to Complete
# resource "aws_acm_certificate_validation" "app" {
#   certificate_arn         = aws_acm_certificate.app.arn
#   validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
# }

# # 4. ALB Listeners (HTTPS and HTTP Redirect)
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.app.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.app.arn  # Uses the validated cert
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }

# # Redirect HTTP (80) to HTTPS (443)
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.app.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }