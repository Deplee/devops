FROM */keys:latest AS ssh_keys
FROM jenkins/ssh-agent:latest-jdk11


COPY --from=ssh_keys /root/.ssh "${JENKINS_AGENT_HOME}/.ssh"
COPY --from=ssh_keys /root/.ssh/id_rsa.pub "${JENKINS_AGENT_HOME}/.ssh/authorized_keys"
COPY --from=ssh_keys /root/.docker "${JENKINS_AGENT_HOME}/.docker"
COPY --from=ssh_keys /etc/ansible/.vp /etc/ansible/.vp
COPY --from=ssh_keys /usr/local/share/ca-certificates/ /usr/local/share/ca-certificates/


RUN apt-get update && apt-get install --no-install-recommends mercurial python3 python3-pip sshpass ca-certificates git -y && \
    keytool -trustcacerts -import -alias te_lime_local -file /usr/local/share/ca-certificates/*.crt -storepass changeit -keystore $JAVA_HOME/lib/security/cacerts -noprompt && \
    chmod 600 "${JENKINS_AGENT_HOME}/.ssh/id_rsa" && chmod 644 "${JENKINS_AGENT_HOME}/.ssh/id_rsa.pub" && chmod 644 "${JENKINS_AGENT_HOME}/.ssh/authorized_keys" && \
    chmod 644 /etc/ansible/.vp && update-ca-certificates && \
    python3 -m pip --no-cache-dir install ansible && python3 -m pip --no-cache-dir install "pywinrm>=0.2.2" && \
    python3 -m pip --no-cache-dir install docker && apt-get clean && rm -rf /var/cache/apt

ENTRYPOINT ["setup-sshd"]
