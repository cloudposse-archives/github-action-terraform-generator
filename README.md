# github-action-terraform-generator

## What

Generate terraform modules or spacelift stacks using a github action.

### Building

```
$ make
```

### Testing
(Note: build first by running `make`)
```
$ make test
```

## How

### Terraform Module
Default operation is 'module'. Here's a sample workflow:
```
name: Deployment
on: [deployment]
jobs:
  shipit:
    name: OTP, Shipping octocat with cthulu
    runs-on: ubuntu-latest
    steps:
      - name: Create terraform module
        uses: cloudposse/github-action-terraform-generator@0.1.0
        with:
          type: module
          component: components/terraform/preview
          module_name: ${{ github.event.deployment.payload.module_name }}
          module_source: ${{ format( 'git::https://github.com/{0}.git//terraform?ref={1}', github.repository, github.sha ) }}
          module_attributes: |
            {
              "name": "${{ github.event.deployment.payload.moniker }}",
              "notes": "This ship just ships itself",
              "shipping": ["octocat", "cthulhu"]
            }
```

### Terraform Stack
Specifying a type of 'stack' enabled stack generation. All params below are required:
```
name: Deployment
on: [deployment]
jobs:
  shipit:
    name: OTP, Shipping octocat with cthulu
    runs-on: ubuntu-latest
    steps:
      - name: Create terraform module
        uses: cloudposse/github-action-terraform-generator@0.1.0
        with:
          type: stack
          stacks_dir: deploys/stacks
          stack: ${{ github.event.deployment.payload.stack_name }}
          stack_source: ${{ format( 'git::https://github.com/{0}.git//terraform?ref={1}', github.repository, github.sha ) }}
          components: |
            {
              "some_component": {
                "settings": {
                  "ship_type": "forbidden"
                }
                "vars": {
                  "rating": "dank"
                }
              }
            }
          global_vars: |
            {
              "name": "${{ github.event.deployment.payload.moniker }}",
              "notes": "This ship just ships itself",
              "shipping": ["octocat", "cthulhu"]
            }
          imports: |
            [
              "some/baseline",
              "some/other/baseline"
            ]
```