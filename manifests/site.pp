## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to the server and asks for an updated configuration.
# https://docs.openvoxproject.org/openvox/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##

# Disable filebucket by default for all File resources. Server-side file
# backups add load and disk usage on the server and are rarely restored from;
# use version control and Hiera data to recover file content instead.
File { backup => false }

## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from
# External Node Classifiers (ENCs), if one is configured.
#
# For more on node definitions, see: https://docs.openvoxproject.org/openvox/latest/lang_node_definitions.html
# If your provisioning process cannot set certificate extensions, node
# definitions matched by certname are the quickest alternative. They take
# precedence over the default node:
#
#   node /^db\d+\.example\.com$/ {
#     include role::example::database_server
#   }

node default {
  # Include the role class named by the `classes` key in Hiera data. The
  # hierarchy in hiera.yaml resolves it from the node's pp_role certificate
  # extension (see data/roles/), so each node gets exactly one role. Nodes
  # with no role data fall back to role::soe.
  lookup('classes', Array[String], 'unique', ['role::soe']).include
}
