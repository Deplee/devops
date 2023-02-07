FROM */keys:latest AS ssh_keys
FROM jenkins/ssh-agent:latest-jdk11

COPY --from=ssh_keys /root/.ssh/id_rsa.pub "${JENKINS_AGENT_HOME}/.ssh/authorized_keys"

RUN apt-get update && apt-get install --no-install-recommends git -y && chmod 644 "${JENKINS_AGENT_HOME}/.ssh/authorized_keys" && \
    apt-get clean && rm -rf /var/cache/apt

ENTRYPOINT ["setup-sshd"]
