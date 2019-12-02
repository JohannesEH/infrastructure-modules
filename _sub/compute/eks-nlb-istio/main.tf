resource "aws_lb" "istio" {
  count = "${var.deploy}"
  name               = "${var.cluster_name}-istio-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${var.subnet_ids}"]
}

resource "aws_lb_target_group" "istio" {
  count = "${var.deploy}"
  name_prefix = "${substr(var.cluster_name, 0, min(6, length(var.cluster_name)))}"
  port        = 31380
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"

  stickiness {
    type = "lb_cookie"
    enabled = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "istio" {
  count = "${var.deploy}"
  autoscaling_group_name = "${var.autoscaling_group_id}"
  alb_target_group_arn   = "${aws_lb_target_group.istio.arn}"
}

resource "aws_lb_listener" "istio" {
  count = "${var.deploy}"
  load_balancer_arn = "${aws_lb.istio.arn}"
  port              = "80"
  protocol          = "TCP"
#   ssl_policy        = "ELBSecurityPolicy-2015-05"
#   certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.istio.arn}"
  }
}

resource "aws_lb_listener" "istio-https" {
  count = "${var.deploy}"
  load_balancer_arn = "${aws_lb.istio.arn}"
  port              = "443"
  protocol          = "TCP"
#   ssl_policy        = "ELBSecurityPolicy-2015-05"
#   certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.istio-https.arn}"
  }
}

resource "aws_lb_target_group" "istio-https" {
  count = "${var.deploy}"
  name_prefix = "${substr(var.cluster_name, 0, min(6, length(var.cluster_name)))}"
  port        = 31390
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"

  stickiness {
    type = "lb_cookie"
    enabled = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "istio-https" {
  count = "${var.deploy}"
  autoscaling_group_name = "${var.autoscaling_group_id}"
  alb_target_group_arn   = "${aws_lb_target_group.istio-https.arn}"
}