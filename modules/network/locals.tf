locals {
  az_index_map = {
    for index, az in var.availability_zones : az => index
  }
  common_tags = merge(
    {
      "Project"     = var.project_name
      "Environment" = "dev"
      "ManagedBy"   = "terraform"
    },
    var.tags
  )
}
