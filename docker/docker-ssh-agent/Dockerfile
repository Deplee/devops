FROM *:latest AS ssh_keys
# from jenkins/ssh-agent:latest-jdk11
FROM *:latest

COPY --from=ssh_keys /root/.ssh /root/.ssh
COPY --from=ssh_keys /root/.docker /root/.docker
COPY --from=ssh_keys /etc/ansible/.vp /etc/ansible/.vp
COPY --from=ssh_keys /usr/local/share/ca-certificates/ /usr/local/share/ca-certificates/

ENTRYPOINT ["setup-sshd"]
