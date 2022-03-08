resource "aws_elb" "elb" {
  name               = "backend-clb"
  subnets = ["subnet-0e1969331d87d4ce9"]
  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:3000"
    interval            = 5
  }
//  instances                   = [aws_instance.foo.id]
//  cross_zone_load_balancing   = true
//  idle_timeout                = 400
//  connection_draining         = true
//  connection_draining_timeout = 400
  tags = {
    Name = "terraform-elb"
  }
}