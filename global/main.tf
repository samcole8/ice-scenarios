
# Keep template always

module "template" {
  source    = "./modules/template"
  node_name = var.node_name
}

# Swap in one scenario at a time

# module "service_enablement" {
#   source    = "./modules/service_enablement"
#   node_name = var.node_name
# }

# module "composite_contracts" {
#   source    = "./modules/composite_contracts"
#   node_name = var.node_name
# }

# module "policy_adjacent_drift" {
#   source = "./modules/policy_adjacent_drift"
# }

# module "iac_side_drift" {
#   source    = "./modules/iac_side_drift"
#   node_name = var.node_name
# }

# module "scenario05" {
#   source    = "./modules/01-firewall"
#   node_name = var.node_name
# }
