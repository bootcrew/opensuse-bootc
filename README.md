# OpenSUSE Bootc

Reference [OpenSUSE](https://www.opensuse.org/) container image preconfigured for [bootc](https://github.com/bootc-dev/bootc) usage.

<img width="2201" height="1239" alt="image" src="https://github.com/user-attachments/assets/2d906848-ee82-40b1-8c3d-91e83ef7e492" />

## Building

In order to get a running opensuse-bootc system you can run the following steps:
```shell
just build-containerfile # This will build the containerfile and all the dependencies you need
just generate-bootable-image # Generates a bootable image for you using bootc!
```

Then you can run the `bootable.img` as your boot disk in your preferred hypervisor.

