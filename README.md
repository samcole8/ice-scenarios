# ice-scenarios

*Note: This README reflects the intended operational state of the repository. Functionality may be partial or broken.*

This repository contains deployable test scenarios for the [infrastructure-contracts-engine](https://github.com/samcole8/infrastructure-contracts-engine) (ICE).

## Layout

Deployment follows an IaC-based approach, split across two levels of Terraform control:

1. The **global** instance provisions the Proxmox node itself. This is shared infrastructure and is not torn down between scenario runs.
2. Each **scenario** instance provisions its own isolated infrastructure on top of that node, independently of every other scenario. Each scenario also deploys [ICE](https://github.com/samcole8/infrastructure-contracts-engine) and configures the rules relevant to that scenario, placing its systems in a contract-conformant state.

Within each scenario's `tf/` directory, resources are split by contract scope:

- **`managed.tf`**: resources treated as Terraform-managed declaratively provisioned infrastructure.
- **`unmanaged.tf`**: resources treated as imperatively provisioned infrastructure.

Once scenarios are deployed, two types of event can be enacted to test the engine:

- **Imperative** actions that place systems into non-conformant states are executed using `playbook.yml` where appropriate, which should trigger the expected contract violations and notification events.
- **Declarative** modifications that place systems into non-conformant states exist as commented code blocks that can be swapped into `managed.tf` to trigger the expected contract violations and prevent Terraform from deploying.

```
ice-scenarios/
├── global/                     # Proxmox node: host, storage, networking, firewall
│   ├── main.tf
│   └── outputs.tf
│
└── scenarios/
    ├── 01-firewall-conflict/    # Exception: no tf/, acts on global's firewall
    │   └── playbook.yml
    │
    └── 02-k8s-conflict/
        ├── tf/                  # Isolated Terraform instance for this scenario
        │   ├── managed.tf       # Resources under ICE's contract
        │   └── unmanaged.tf     # Resources excluded from ICE's contract
        └── playbook.yml
```

## Resetting scenarios

Scenarios should be executed independently and destroyed after each run by executing `terraform destroy` followed by `terraform apply` within the scenario's own `tf/` directory.