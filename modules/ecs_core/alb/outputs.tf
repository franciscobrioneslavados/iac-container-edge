output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.main.id
}

output "wordpress_target_group_arn" {
  description = "The ARN of the WordPress target group"
  value       = aws_lb_target_group.wordpress_tg.arn
}

# output "react_target_group_arn" {
#   description = "The ARN of the React target group"
#   value       = aws_lb_target_group.react_tg.arn
# }

output "zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

