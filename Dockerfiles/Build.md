# Steps
Build it
`bash
docker build . \
  -f github_runner.dockerfile \
  --build-arg="TOKEN=placeholder" \
  --build-arg="REPO=placeholder" \
  --tag github_self_runner:latest
`
