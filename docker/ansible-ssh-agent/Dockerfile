FROM *:latest AS ssh_keys
# from jenkins/ssh-agent:latest-jdk11
FROM *:latest

COPY --from=ssh_keys /root/.ssh /root/.ssh
COPY --from=ssh_keys /root/.docker /root/.docker
COPY --from=ssh_keys /etc/ansible/.vp /etc/ansible/.vp
COPY --from=ssh_keys /usr/local/share/ca-certificates/ /usr/local/share/ca-certificates/

RUN apk add --no-cache \
    mercurial \
    python3 \
    py3-pip \
    sshpass &&  \
    ln -sf python3 /usr/bin/python && \
    pip3 install --no-cache --upgrade pip setuptools && \
    keytool -trustcacerts -import -alias te_lime_local -file /usr/local/share/ca-certificates/*.crt -storepass changeit -keystore $JAVA_HOME/lib/security/cacerts -noprompt && \
    chmod 600 /root/.ssh/id_rsa && chmod 644 /root/.ssh/id_rsa.pub && chmod 644 /etc/ansible/.vp && update-ca-certificates && \
    python3 -m pip --no-cache-dir install ansible && python3 -m pip --no-cache-dir install "pywinrm>=0.2.2" && \
    python3 -m pip --no-cache-dir install docker && \
    ln -sf /usr/bin/ansible-playbook /usr/local/bin/ansible-playbook && \
    chown -R 0:0 /root/.ssh


ENTRYPOINT ["setup-sshd"]
