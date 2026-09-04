# ice-scenarios

This repository contains deployable test scenarios for the [infrastructure-contracts-engine](https://github.com/samcole8/infrastructure-contracts-engine) (ICE).

## Layout

Scenarios are configured as isolated Terraform modules. Within each scenario/module, resources are split by contract scope:

- **`unmanaged.tf`**: simulation of imperatively provisioned infrastructure.
- **`managed.tf`**: simulation of declaratively provisioned Terraform-managed infrastructure, including `ice_config` resources that may reference imperative infrastructure.

## Setup

1. **Setup Proxmox**: Install Proxmox Virtual Environment following the [official documentation](https://pve.proxmox.com/pve-docs/chapter-pve-installation.html).
2. **Setup ICE**: Install and run ICE locally following the [official documentation](github.com/samcole8/infrastructure-contracts-engine).
2. **Configure the global instance**: Add the IP address and root password of the Proxmox instance in `global/main.tfvars`, e.g.:
   
    ```
    password = "password"
    ip       = "192.168.122.230:8006"
    ```
3. **Deploy the template instance**: Execute `terraform init` and `terraform apply`. 

### Standard (Proxmox) Scenarios

1. `global/main.tf` contains several module references, some of which are block commented. To deploy a scenario, uncomment the module and run terraform apply. You should only run one scenario at a time, and the template should remain uncommented.

2. Some scenarios contain a bash script called `diverge.sh` which represents a change that will cause the engine to report a failure. Some scenarios have comments in `managed.tf` that describe a Terraform-side change that should cause a failure to be reported as a warning by the provider. These are not necessarily the only methods to induce divergence.

3. Once finished with a scenario, use `terraform destroy -target scenario_module` to destroy the scenario. You can then recomment it and try a different scenario.

Some scenarios have additional testing requirements:

- `policy_adjacent_drift` depends on Amazon Web Services and requires the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables to be set accordingly.
- `iac_side_divergence` does not use `diverge.sh` because the divergence-inducing change originates on the Terraform side. Overriding the default `max_connections` variable with a value lower than 10 should cause failure for this scenario.
- `service_enablement` has two requirements and two separate corresponding divergence scripts.