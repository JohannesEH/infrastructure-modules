resource "aws_security_group_rule" "webhooks" {
  count = "${var.deploy}"
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  #cidr_blocks = ["0.0.0.0/0"] # add a CIDR block here
  source_security_group_id = "${var.security_group_id_masters}"
  #prefix_list_ids = ["pl-12c4e678"]
  description = "Webhook to validate Istio deployment"

  security_group_id = "${var.security_group_id_nodes}"
}

resource "aws_security_group_rule" "http" {
  count = "${var.deploy}"
  type            = "ingress"
  from_port       = 31380
  to_port         = 31380
  protocol        = "tcp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  cidr_blocks = ["0.0.0.0/0"] # add a CIDR block here
  #source_security_group_id = "${var.security_group_id_masters}"
  #prefix_list_ids = ["pl-12c4e678"]
  description = "Enable http traffic for istio nlb"

  security_group_id = "${var.security_group_id_nodes}"
}

resource "kubernetes_namespace" "istio" {
  count = "${var.deploy}"
  metadata {
    name = "istio-system"
  }

  #depends_on = ["${aws_security_group_rule.webhooks}"]
}


resource "helm_release" "istio-init" {
  count = "${var.deploy}"
  name       = "istio-init"
  repository = "${var.istio_helm_repo}"
  chart      = "istio-init"
  namespace  = "istio-system"

  depends_on = ["kubernetes_namespace.istio"]
}

resource "helm_release" "istio" {
  count = "${var.deploy}"
  name       = "istio"
  repository = "${var.istio_helm_repo}"
  chart      = "istio"
  namespace  = "istio-system"

  set {
      name = "prometheus.enabled"
      value = "false"
  }

  set {
      name = "gateways.istio-ingressgateway.type"
      value = "NodePort"
      #value = "LoadBalancer"
  }

    set {
      name = "gateways.istio-ingressgateway.sds.enabled"
      value = "true"
  }

    set {
      name = "global.proxy.envoyAccessLogService.tlsSettings.mode"
      value = "SIMPLE"
  }

  set {
      name= "kiali.enabled"
      value = "true"
  }

  depends_on = ["helm_release.istio-init"]
}