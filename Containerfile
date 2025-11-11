FROM registry.opensuse.org/opensuse/tumbleweed:latest

RUN zypper install -y \
      binutils \
      btrfs-progs \
      cpio \
      dosfstools \
      dracut \
      e2fsprogs \
      glib2 \
      kernel-default \
      kernel-firmware-all \
      skopeo \
      systemd \
      systemd-boot \
      udev \
      xfsprogs \
      zstd && \
    zypper clean -a

ENV DEV_DEPS="git rust make cargo gcc-devel glib2-devel libzstd-devel openssl-devel ostree-devel"
RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
    zypper install -y ${DEV_DEPS} && \
    git clone "https://github.com/bootc-dev/bootc.git" /tmp/bootc && \
    make -C /tmp/bootc bin install-all install-initramfs-dracut && \
    sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
    dracut --force --no-hostonly --force-drivers erofs --reproducible --zstd --verbose --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"' && \
    zypper remove -y ${DEV_DEPS} && \
    zypper clean -a
ENV DEV_DEPS=""

# Necessary for general behavior expected by image-based systems
RUN echo "HOME=/var/home" | tee "/etc/default/useradd" && \
    rm -rf /boot /home /root /usr/local /srv && \
    mkdir -p /var /sysroot /boot /usr/lib/ostree && \
    ln -s var/opt /opt && \
    ln -s var/roothome /root && \
    ln -s var/home /home && \
    ln -s sysroot/ostree /ostree && \
    echo "$(for dir in opt usrlocal home srv mnt ; do echo "d /var/$dir 0755 root root -" ; done)" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    echo "d /var/roothome 0700 root root -" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    echo "d /run/media 0755 root root -" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    printf "[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n" | tee "/usr/lib/ostree/prepare-root.conf"

# Setup a temporary root passwd (changeme) for dev purposes
# TODO: Replace this for a more robust option when in prod
RUN usermod -p '$6$AJv9RHlhEXO6Gpul$5fvVTZXeM0vC03xckTIjY8rdCofnkKSzvF5vEzXDKAby5p3qaOGTHDypVVxKsCE3CbZz7C3NXnbpITrEUvN/Y/' root

# If you want a desktop :)
# RUN zypper install -y -t pattern kde && zypper install -y konsole sddm-qt6 vim dolphin

# Necessary labels
LABEL containers.bootc 1
