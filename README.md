# Custom Rocky Live CD Generator

Docker image to generate customized Rocky Linux live CD ISOs

## Usage

```bash
docker run \
    --privileged \
    -e VAR=value \
    -v $(pwd):/out \
    ghcr.io/spencerhughes/custom-live-cd-rocky:9
```

If a Kickstart file is placed into /custom, the configuration variables will be overridden and the custom config will be used as-is.
This will build a live CD image and place it in the current working directory, as well as the rendered Kickstart file used to build the live CD.

### Variables

These environnment variables can be set at runtime to customize the generated live CD:

| Name | Description | Default |
| ---- | ----------- | ------- |
| VAR | Configures output | `value` |

## How it Works

A [Kickstart]() file is generated or provided by the user, then `ksflatten` is used to merge the project-provided live CD Kickstart files with the custom Kickstart. The merged Kickstart file is then passed to `livecd-creator`, which is used to build a live CD ISO image.
