# Pretix Helm chart

This is an unofficial Helm chart for the Pretix event ticketing software.

Still in the setup progress! Soon there will be more info on how to use it.

# Install chart
You can install this using Helm, make sure you have the repo setup. 
You likely want to change your values as well.

```
helm repo add techwolf12 https://helm.techwolf12.nl/
helm repo update
helm install pretix techwolf12/pretix
```

## Working with plugins
If you want to install custom plugins, your best bet is to create a custom docker image for now.
A example Dockerfile for this is:
```docker
FROM pretix/standalone:stable
USER root
RUN pip3 install pretix-passbook
USER pretixuser
RUN cd /pretix/src && make production
```
You can then override `image.repository` and `image.tag` with your values.

# Dependencies
By default, this chart installs additional, dependent charts:
* postgresql
* redis

To disable this dependency during installation, set `postgresql.enabled` and `redis.enabled` to `false`.

# Uninstall chart
```
helm uninstall pretix
```

This removes all the Kubernetes components and deletes the release

# Upgrading chart
```
helm upgrade pretix techwolf12/pretix --install
```

Breaking changes will be listed below.

