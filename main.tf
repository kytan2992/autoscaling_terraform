locals {
 resource_prefix = "ky-tf"
}

resource "aws_launch_template" "asg_template" {
  image_id = "ami-0df8c184d5f6ae949"
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  tags = {
   Name = "${ local.resource_prefix }-ec2-template"
 }

 user_data = filebase64("${path.module}/user_data.txt")
}

resource "aws_lb" "main_lb" {
  name = "ky-tf-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [data.aws_security_group.existing_sg.id]
  subnets = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "${ local.resource_prefix }-alb"
  }
}

resource "aws_lb_target_group" "targetgroup" {
  name = "ky-tf-alb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.existing_vpc.id

  health_check {
    path = "/"
  }

  tags = {
    name = "${ local.resource_prefix }-alb-tg"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}

resource "aws_autoscaling_group" "ec2" {
  name = "${ local.resource_prefix }-asg"
  desired_capacity = 1
  max_size = 2
  min_size = 1
  vpc_zone_identifier = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
  launch_template {
    id = aws_launch_template.asg_template.id
    version = "$Latest"
  }

  health_check_type = "ELB"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.targetgroup.arn]

  tag {
    key = "Name"
    value = "${ local.resource_prefix }-asg-ec2"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "target_tracking" {
  name = "cpu-utilization-policy"
  autoscaling_group_name = aws_autoscaling_group.ec2.name

  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup= 300
  target_tracking_configuration {
    target_value = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    disable_scale_in = false
  }
  
}