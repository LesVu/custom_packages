# Steps
## Build it
`bash
docker build . \
  -f github_runner.dockerfile \
  --build-arg="TOKEN=placeholder" \
  --build-arg="REPO=placeholder" \
  --tag github_self_runner:latest
`
## Run It
`bash
docker run -itd \
  --init \
  --privileged \
  --name self_runner \
  --dns 1.1.1.1 \
  --dns 1.0.0.1 \
  github_self_runner:latest
`
