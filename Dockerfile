FROM debian:11
RUN apt update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt install -y --no-install-recommends \
    dialog \
    apt-utils \
    sudo \
    python3 \
    openssh-server
RUN sed -r -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
RUN sed -r -i 's/^#PermitRootLogin(.*)$/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -r -i 's/^#PasswordAuthentication(.*)$/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -r -i 's/^#PermitEmptyPasswords(.*)$/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
RUN mkdir -p /run/sshd
CMD ["/usr/sbin/sshd", "-D"]
