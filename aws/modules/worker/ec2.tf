resource "aws_launch_configuration" "worker" {
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = "${ var.volume_size["ebs"] }"
    volume_type = "gp2"
  }
  iam_instance_profile = "${ var.instance_profile_name }"
  image_id = "${ var.ami_id }"
  instance_type = "${ var.instance_type }"
  key_name = "${ var.key_name }"

  # Storage
  root_block_device {
    volume_size = "${ var.volume_size["root"] }"
    volume_type = "gp2"
  }

  security_groups = [
    "${ var.security_group_id }",
  ]

  user_data = "${ data.template_file.cloud-config.rendered }"

  /*lifecycle {
    create_before_destroy = true
  }*/
}

resource "aws_autoscaling_group" "worker" {
  name = "worker-${ var.worker_name }-${ var.name }"

  desired_capacity = "${ var.capacity["desired"] }"
  health_check_grace_period = 60
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${ aws_launch_configuration.worker.name }"
  max_size = "${ var.capacity["max"] }"
  min_size = "${ var.capacity["min"] }"
  vpc_zone_identifier = [ "${ split(",", var.subnet_ids) }" ]

  tag {
    key = "builtWith"
    value = "terraform"
    propagate_at_launch = true
  }

  tag {
    key = "depends-id"
    value = "${ var.depends_id }"
    propagate_at_launch = false
  }

  # used by kubelet's aws provider to determine cluster
  tag {
    key = "KubernetesCluster"
    value = "${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "kz8s"
    value = "${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "Name"
    value = "worker-${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "role"
    value = "worker"
    propagate_at_launch = true
  }

  tag {
    key = "version"
    value = "${ var.kubelet_image_tag }"
    propagate_at_launch = true
  }

  tag {
    key = "visibility"
    value = "private"
    propagate_at_launch = true
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_autoscaling_group.worker",
    "aws_launch_configuration.worker",
  ]
}
