
module "custom-vpc" {
    source = "../../../../terraform-aws/services/vpc/base/v1"

    context = {
        app_name = "PSI"
        env_name = "Terra-Demo"
        location = "us-east-1"
    }

    vpc_settings = {
        cidr_block = "10.0.0.0/16"
        instance_tenancy = "default"
        enable_ipv6 = false
        additional_cidr_blocks = ["10.2.0.0/28", "10.3.0.0/28"]
        custom_tags = {
            Project = "RnD"
        }
        priv-sub_custom_tags = {
            "kubernetes.io/role/internal-elb" = 1
        }
        pub-sub_custom_tags = {
            "kubernetes.io/role/elb" = 1
        }
    }

    subnet_settings = {
        private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
        public_subnet_cidr_blocks = ["10.0.3.0/28"]
    #    availability_zones = ["us-east-1a", "us-east-1b"]
    }

}

module "eks" {
    source = "../../../../terraform-aws/services/eks/base/v1"

    context = {
        app_name = "PSI"
        env_name = "Terra-Demo"
        location = "us-east-1"
    }

    eks_cluster_settings = {
        subnet_ids = concat(module.custom-vpc.private_subnet_ids, module.custom-vpc.public_subnet_ids)
        public_access_cidrs = ["0.0.0.0/0"]
        custom_tags = {
            Project = "RnD"
        }
    }

    nodegroup_settings = {
        ami_type = "AL2_x86_64"
        disk_size = 20
        instance_types = ["t3.medium"]
        desired_size = 2
        max_size = 4
        min_size = 2
        custom_tags = {
            Project = "RnD"
        }
    }

}
