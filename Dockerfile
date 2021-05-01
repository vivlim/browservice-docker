FROM archlinux:latest
RUN pacman -Sy
RUN pacman -S --noconfirm wget cmake make gcc pkgconf poco pango libjpeg-turbo libxcb libx11 python xorg-server-xvfb xorg-xauth fakeroot at-spi2-atk alsa-lib nss libcups libxrandr libxcursor libxss libxcomposite libxkbcommon

RUN useradd browser -m

RUN wget -c https://github.com/ttalvitie/browservice/archive/refs/tags/v0.9.2.0.tar.gz -O - | tar -xz
WORKDIR browservice-0.9.2.0

RUN ./download_cef.sh && ./setup_cef.sh && make -j8

RUN chown root:root release/bin/chrome-sandbox && chmod 4755 release/bin/chrome-sandbox

# Install MS core fonts from AUR
RUN useradd --no-create-home --shell=/bin/false build && usermod -L build
USER build
RUN pushd /tmp && wget -c https://aur.archlinux.org/cgit/aur.git/snapshot/ttf-ms-fonts.tar.gz -O - | tar -xz && pushd ttf-ms-fonts && makepkg -s
USER root
RUN pushd /tmp && pacman -U --noconfirm */*.pkg.tar.zst

USER browser
CMD ["release/bin/browservice", "--vice-opt-http-listen-addr=0.0.0.0:8080", "--data-dir=/session"]
