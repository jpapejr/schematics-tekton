data "ibm_resource_group" "resource_group" {
  name = "${var.resource_group}"
}

data "ibm_container_cluster" "cluster" {
    cluster_name_id     = "${var.cluster_name}"
    region              = "${var.region}"
    resource_group_id   = "${data.ibm_resource_group.resource_group.id}"
}


data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = "${data.ibm_container_cluster.cluster.id}"
  resource_group_id = "${data.ibm_resource_group.resource_group.id}"
  region            = "${var.region}"
  config_dir        = "/tmp"
}

resource "null_resource" "addons" {

    provisioner "local-exec" {
        environment = {
            IBMCLOUD_COLOR=false
        }
        command = <<EOT
        kubectl apply --kubeconfig=${data.ibm_container_cluster_config.cluster_config.config_file_path} --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml \
        && kubectl apply--kubeconfig=${data.ibm_container_cluster_config.cluster_config.config_file_path} --filename https://github.com/tektoncd/dashboard/releases/download/v0.1.1/release.yaml \
        && sleep 20 \
        && kubectl get pods --namespace tekton-pipelines \
        && kubectl get svc --namespace tekton-pipelines
        EOT
    }
#   depends_on = ["ibm_container_cluster_config.cluster_config"]
}