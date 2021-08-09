# Minikube Spinnaker

Install Spinnaker in Minikube using [Spinnaker Operator](https://github.com/armory/spinnaker-operator)

This setup uses:
- [MinIO](https://min.io/) instead of S3
- Minikube for local kubernetes provider

## Prerequisite

- [yq](https://github.com/mikefarah/yq)
- Minikube installed

## Run

- Create Github personal access token: Go to https://github.com/settings/tokens, Generate new token with scope `repo`
- Install [direnv](https://direnv.net/)
- `cp ./.envrc.template ./.envrc` and fill in `.envrc` with the github token above, run `direnv allow`. This will allow `direnv` to export `GITHUB_TOKEN` environment variable whenever you are in this directory.
- Run `./up.sh`

Once all deployments are ready, spinnaker is available at `http://minikube-ip:32070`
