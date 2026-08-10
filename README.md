# OpenVox Control Repository Template

A template [control repository](https://docs.openvoxproject.org/openvox/latest/environments_about.html)
with the minimum scaffolding needed to get started managing infrastructure with
[OpenVox](https://voxpupuli.org/openvox/), using
[r10k](https://github.com/puppetlabs/r10k) or
[g10k](https://github.com/xorpaul/g10k) to deploy code environments.

* [What You Get From This Template](#what-you-get-from-this-template)
* [Quick Start](#quick-start)
* [Repository Layout](#repository-layout)
* [Continuous Integration](#continuous-integration)
* [Working With Site Modules](#working-with-site-modules)
* [OpenBolt Project](#openbolt-project)
* [Hiera and Plan Data](#hiera-and-plan-data)
* [Using Another Git Server](#using-another-git-server)
* [Credits](#credits)

## What You Get From This Template

* Basic examples of roles and profiles, packaged as standalone Puppet modules.
* An `adhoc` module for tasks and plans that do not fit into a specific role or profile.
* Example Puppet language and Ruby functions with unit tests.
* An example `Puppetfile` with various module references.
* An example Hiera configuration file and data directory with a pre-created `common.yaml` and `nodes` directory,
  including an OpenBolt `plan_hierarchy` example and commented eyaml configuration guidance.
* An [environment.conf](https://docs.openvoxproject.org/openvox/latest/config_file_environment.html)
  that configures the site module path and `config_version` script.
* An example `config_version` script that outputs the git commit ID of the code that was used during a run.
* An example [OpenBolt project](https://docs.openvoxproject.org/openbolt/latest/projects.html).
* A working GitHub Actions pipeline, plus example CI configurations for GitLab CI, Azure Pipelines,
  and Bitbucket Pipelines.

## Quick Start

1. Click **Use this template** on GitHub to create your own control repository from this one
   (see [GitHub's documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)),
   or push a copy to [another git server](#using-another-git-server).
2. On your OpenVox server, install r10k (or g10k) and point it at your new repository, for example in
   `/etc/puppetlabs/r10k/r10k.yaml`:

   ```yaml
   :sources:
     :main:
       remote: 'git@your-git-server.example.com:puppet/control-repo.git'
       basedir: '/etc/puppetlabs/code/environments'
   ```

3. Deploy your environments:

   ```shell
   r10k deploy environment --modules
   ```

Each git branch of the control repository becomes a Puppet
[environment](https://docs.openvoxproject.org/openvox/latest/environments_about.html)
of the same name. The default branch of this template is `production`, which is
the default environment agents use.

## Repository Layout

```text
control-repo/
├── .github/
│   └── workflows/
│       ├── ci.yml                  # GitHub Actions pipeline.
│       └── module-ci.yml           # Reusable module validation workflow.
├── bolt/                           # OpenBolt project directory.
│   ├── plans/                      # Project-only plans directory.
│   ├── tasks/                      # Project-only tasks directory.
│   ├── bolt-project.yaml           # OpenBolt project config.
│   └── inventory.yaml              # OpenBolt target inventory.
├── data/                           # Hiera data directory.
│   ├── nodes/                      # Node-specific data goes here.
│   ├── plan/                       # OpenBolt plan data.
│   └── common.yaml                 # Common data goes here.
├── manifests/
│   └── site.pp                     # Main manifest.
├── scripts/
│   ├── config_version-r10k.rb      # r10k deployment metadata.
│   └── config_version.sh           # Selects a config_version helper.
├── site-modules/                   # Site modules in $modulepath.
│   ├── adhoc/                      # Task and plan examples.
│   ├── profile/                    # Profile classes and functions.
│   └── role/                       # Role classes that compose profiles.
├── .gitlab-ci.yml.example          # GitLab CI example pipeline.
├── azure-pipelines.yml.example     # Azure Pipelines example pipeline.
├── bitbucket-pipelines.yml.example # Bitbucket Pipelines example pipeline.
├── LICENSE
├── NOTICE
├── Puppetfile                      # External modules for deployment.
├── README.md
├── environment.conf                # modulepath and config_version.
└── hiera.yaml                      # Hiera hierarchy.
```

## Continuous Integration

The GitHub Actions pipeline in `.github/workflows/ci.yml` runs automatically on
pushes and pull requests targeting the `production` branch. It validates the
`Puppetfile`, main manifest, and Hiera data, and runs validation and unit tests
for the `adhoc`, `profile`, and `role` modules.

Example CI definitions with the same checks are included for other git platforms:

* GitLab CI: `.gitlab-ci.yml.example`
* Azure Pipelines: `azure-pipelines.yml.example`
* Bitbucket Pipelines: `bitbucket-pipelines.yml.example`

To use one, copy or rename the relevant `.example` file into the filename
expected by your CI provider.

## Working With Site Modules

The modules under `site-modules/` are standalone Puppet modules with their own
Gemfiles and test suites. Work from the individual module directory:

```shell
cd site-modules/profile
bundle install
bundle exec rake validate lint check rubocop
bundle exec rake parallel_spec
```

The included modules demonstrate these patterns:

* `adhoc` contains example Linux and Windows tasks, an example plan, and specs for task metadata and plans.
* `profile` contains example profile classes, Hiera-backed data, Puppet language functions, Ruby functions,
  custom facts, and unit tests.
* `role` contains example role classes and tests for composing profiles.

## OpenBolt Project

The `bolt/` directory is a local [OpenBolt](https://voxpupuli.org/openbolt/) project.
Its `bolt-project.yaml` exposes the control repo's `site-modules` and `modules`
directories to OpenBolt and points it at the root `hiera.yaml` file.

Use `bolt/plans/` and `bolt/tasks/` for plans and tasks that belong only to this
OpenBolt project. Use `site-modules/adhoc` for tasks and plans that should be
packaged and tested as a Puppet module.

## Hiera and Plan Data

The root `hiera.yaml` includes the standard node and common data hierarchy:

```text
data/nodes/%{trusted.certname}.yaml
data/common.yaml
```

It also includes an OpenBolt `plan_hierarchy` example that reads from
`data/plan/common.yaml`. This keeps plan-specific data separate from catalog
data and avoids relying on per-target facts when OpenBolt runs outside an apply
block.

The bottom of `hiera.yaml` contains a commented
[eyaml](https://github.com/voxpupuli/hiera-eyaml) example for encrypted Hiera
data, including the server gem installation command, key generation step, and a
sample `eyaml_lookup_key` configuration.

## Using Another Git Server

If your control repository will live somewhere other than GitHub, create an
empty repository named `control-repo` on your git server (GitLab, Bitbucket,
Gitea, or similar), then:

1. Clone this template repository to your workstation:
   * `git clone https://github.com/OpenVoxProject/control-repo-template.git control-repo`
   * `cd control-repo`
2. Remove this repository as the origin remote:
   * `git remote remove origin`
3. Add your internal repository as the origin remote:
   * `git remote add origin <url of your repository>`
4. Push the production branch of the repository from your machine up to your git server:
   * `git push origin production`

Give your r10k or g10k deployment user read access to the repository, and
configure a webhook or scheduled job to run `r10k deploy environment --modules`
when the repository changes.

## Credits

Adapted from [puppetlabs/control-repo](https://github.com/puppetlabs/control-repo),
licensed under the Apache License 2.0. See [NOTICE](NOTICE).
