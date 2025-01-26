# Custom Rocky Live CD Generator

Docker image to generate customized Rocky Linux live CD ISOs

## Usage

```bash
docker run \
    --privileged \
    -e CD_LABEL="RockyLiveCD" \
    -e CUSTOM_KICKSTART="custom" \
    -e FLATTENED_KICKSTART="live" \
    -e AUTOLOGIN_ENABLED=true \
    -e LIVE_PRODUCT_LABEL="Custom Rocky 9 live CD" \
    -v $(pwd):/out \
    ghcr.io/spencerhughes/custom-live-cd-rocky:9
```

By default, the image uses the values of the environment variables to generate
a Kickstart file that is combined with the live CD Kickstarts from the Rocky
Linux project to build the live CD image.

If a file named `custom.ks` is present at `/in/custom.ks` in the container at
runtime, that file is used instead of the environment variables to customize
the live CD.

This will build a live CD image and place it in the current working directory,
as well as the rendered Kickstart file used to build the live CD.

### Variables

These environnment variables can be set at runtime to customize the generated
live CD:

| Name | Description | Default |
| ---- | ----------- | ------- |
| `CD_LABEL` | Sets the label of the ISO filesystem for the live CD image. This value must not have spaces, as spaces are not allowed in ISO filesystem labels. | `RockyLiveCD` |
| `LIVE_PRODUCT_LABEL` | Sets the product label, used to set the name in the GRUB boot menu | `Custom Rocky ${ROCKY_VERSION} live CD` |
| `CUSTOM_KICKSTART` | Determines the base name of the customization Kickstart file (without `.ks` extension) | `custom` |
| `FLATTENED_KICKSTART` | Determines the base name of the Kickstart file output from merging the customization and upstream Kickstart files (without `.ks` extension) | `live` |
| `SSH_ENABLED` | Determines whether the `sshd` service is started at boot | `true` |
| `SSH_AUTHORIZED_KEY` | SSH public key to be embedded into the `authorized_keys` of the `root` user within the live CD OS | *Unset* |
| `SSH_KEY_URL` | URL from which to download public keys for the `root` user at boot | *Unset* |
| `AUTOLOGIN_ENABLED` | Determines whether the `root` account logs in on the console automatically | `true` |

## How it Works

A [Kickstart](https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/appendixes/Kickstart_Syntax_Reference/)
file is generated or provided by the user, then `ksflatten` is used to merge
the project-provided live CD Kickstart files with the custom Kickstart. The
merged Kickstart file is then passed to `livecd-creator`, which is used to
build a live CD ISO image.
