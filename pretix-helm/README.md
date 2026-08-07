# Pretix Helm chart

This is an unofficial Helm chart for the Pretix event ticketing software.

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
* postgres (via the [groundhog2k/postgres](https://github.com/groundhog2k/helm-charts) chart, using the official `postgres` image)
* valkey (via the [groundhog2k/valkey](https://github.com/groundhog2k/helm-charts) chart, using the official `valkey/valkey` image)

To disable this dependency during installation, set `postgres.enabled` and `valkey.enabled` to `false`.

# Uninstall chart
```
helm uninstall pretix
```

This removes all the Kubernetes components and deletes the release, it is worthy to note that Postgresql still leaves your database as PVC, you might have to remove this manually if you desire so.

# Upgrading chart
```
helm upgrade pretix techwolf12/pretix --install
```

Breaking changes will be listed below.

## 2026.x
Bitnami discontinued its free public Helm chart catalog, so the bundled `postgresql` and `redis` dependencies
(previously from `charts.bitnami.com`) were replaced with `postgres` and `valkey` from
[groundhog2k/helm-charts](https://github.com/groundhog2k/helm-charts), which wrap the plain upstream `postgres`
and `valkey/valkey` Docker images. This is a breaking change:
* The `postgresql.*` values key is now `postgres.*`, with a different structure (see below).
* The `redis.*` values key is now `valkey.*`. Valkey is a BSD-licensed, drop-in-compatible fork of Redis.
* The default database hostname changed from `pretix-postgresql` to `pretix-postgres`.
* The default cache/broker hostname changed from `pretix-redis-master` to `pretix-valkey`.
* If you were relying on the default `env.PRETIX_REDIS_LOCATION` / `PRETIX_CELERY_BACKEND` / `PRETIX_CELERY_BROKER`
  values, update them to point at `pretix-valkey` (or set your own if you use `fullnameOverride`).

# Parameters

## Image
| Name              | Description                                                                               | Default Value                                           |
|-------------------|-------------------------------------------------------------------------------------------|---------------------------------------------------------|
| image.repository  | The Pretix Docker repository you want to use, useful if you want custom plugins installed | pretix/standalone                                       |
| image.tag         | The Pretix Docker tag you want to use, useful if you want custom plugins installed        | Helm chart version, matching the Pretix release version |
| image.pullPolicy  | When you want Kubernetes to pull the Docker image                                         | IfNotPresent                                            |
| image.pullSecrets | Docker secret names as array, if your custom repo needs authentication to read            | []                                                      |

## Replicas
| Name                  | Description                                       | Default Value |
|-----------------------|---------------------------------------------------|---------------|
| replicas.pretixWeb    | How many Pretix Web instances you want running    | 1             |
| replicas.pretixWorker | How many Pretix Worker instances you want running | 1             |

## Cron
| Name         | Description                              | Default Value |
|--------------|------------------------------------------|---------------|
| cronSchedule | Schedule for when to run the Pretix cron | */30 * * * *  |

## Environment variables
See all possible config variables [on the Pretix documentation site](https://docs.pretix.eu/en/latest/admin/config.html).
The syntax is `PRETIX_SECTION_CONFIG`. For example, to configure the setting `password_reset` from the `[pretix]` section, set `PRETIX_PRETIX_PASSWORD_RESET: off` in your environment.
| Name                                      | Description                                                                                        | Default Value                 |
|-------------------------------------------|----------------------------------------------------------------------------------------------------|-------------------------------|
| env.NUM_WORKERS                           | Gunicorn worker count for the web pod. Not `PRETIX_`-prefixed - read directly by the container entrypoint. Defaults to 2x the *node's* CPU count if unset, which can spin up more workers than resources.limits.memory can hold and OOM-loop the pod on multi-core nodes; scale this together with resources.limits.memory (roughly 150-200Mi per worker) | 4 |
| env.PRETIX_PRETIX_INSTANCE_NAME           | Name of your Pretix instance                                                                       | Pretix Helm                   |
| env.PRETIX_PRETIX_URL                     | URL on how to access it                                                                            | http://localhost              |
| env.PRETIX_PRETIX_CURRENCY                | Currency to use                                                                                    | EUR                           |
| env.PRETIX_PRETIX_DATADIR                 | Data directory, should stay on /data unless you change the helm chart as the PVC is mounted here   | /data                         |
| env.PRETIX_PRETIX_TRUST_X_FORWARDED_FOR   | Trust ingress proxy forwarded IP                                                                   | on                            |
| env.PRETIX_PRETIX_TRUST_X_FORWARDED_PROTO | Trust ingress proxy protocol                                                                       | on                            |
| env.PRETIX_MAIL_FROM                      | Mail send from                                                                                     | test@example.com              |
| env.PRETIX_MAIL_HOST                      | SMTP server                                                                                        |                               |
| env.PRETIX_MAIL_USER                      | SMTP Username                                                                                      |                               |
| env.PRETIX_MAIL_PASSWORD                  | SMTP Password                                                                                      |                               |
| env.PRETIX_MAIL_PORT                      | SMTP port                                                                                          | 587                           |
| env.PRETIX_MAIL_TLS                       | Use TLS                                                                                            | True                          |
| env.PRETIX_DATABASE_BACKEND               | Database backend, defaults to postgresql                                                           | postgresql                    |
| env.PRETIX_DATABASE_NAME                  | Database name, if using dependecy postgresql, make sure that it matches                            | pretix                        |
| env.PRETIX_DATABASE_USER                  | Database user, if using dependecy postgresql, make sure that it matches                            | pretix                        |
| env.PRETIX_DATABASE_PASSWORD              | Database password, if using dependecy postgresql, make sure that it matches                        | pretix                        |
| env.PRETIX_DATABASE_HOST                  | Database Hostname, if using dependecy postgres, this is `helm release name-postgres`               | pretix-postgres               |
| env.PRETIX_REDIS_LOCATION                 | Redis/Valkey server, if using embedded Valkey, this is `helm release name-valkey`                  | redis://pretix-valkey/0       |
| env.PRETIX_REDIS_SESSIONS                 | Should we use Redis/Valkey for sessions                                                            | true                          |
| env.PRETIX_CELERY_BACKEND                 | Redis/Valkey server for Celery backend, if using embedded Valkey, this is `helm release name-valkey` | redis://pretix-valkey/1     |
| env.PRETIX_CELERY_BROKER                  | Redis/Valkey server for Celery Broker, if using embedded Valkey, this is `helm release name-valkey`  | redis://pretix-valkey/2     |

## Labels
| Name   | Description                              | Default Value |
|--------|------------------------------------------|---------------|
| labels | Custom labels you want to apply as array | []            |

## Resources
| Name                      | Description                                    | Default Value |
|---------------------------|------------------------------------------------|---------------|
| resources.limits.memory   | Memory limit until Kubernetes restarts the pod | 4096Mi        |
| resources.requests.cpu    | CPU request for Kubernetes                     | 0.5           |
| resources.requests.memory | Memory request for Kubernetes                  | 1024Mi        |

## Persistence
| Name                         | Description                                          | Default Value |
|------------------------------|------------------------------------------------------|---------------|
| persistence.enabled          | If Pretix data should be persistence across upgrades | true          |
| persistence.storageClassName | Storage class name                                   | local-path    |
| persistence.accessMode       | PVC access mode                                      | ReadWriteOnce |
| persistence.size             | PVC disk size                                        | 5Gi           |

## Postgres
More options can be overridden from the [postgres chart](https://github.com/groundhog2k/helm-charts/tree/master/charts/postgres) here.

| Name                                  | Description                                                               | Default Value            |
|----------------------------------------|---------------------------------------------------------------------------|--------------------------|
| postgres.enabled                       | If the dependency Postgres is enabled, set to false if you use your own  | true                     |
| postgres.settings.superuser.value      | Superuser (admin) account name                                            | postgres                 |
| postgres.settings.superuserPassword.value | Password for the `postgres` admin user                                | supersecureadminpassword |
| postgres.userDatabase.name.value       | Pretix database name, make sure it matches in the env                    | pretix                   |
| postgres.userDatabase.user.value       | Pretix database username, make sure it matches in the env                | pretix                   |
| postgres.userDatabase.password.value   | Pretix database password, make sure it matches in the env                | pretix                   |

## Valkey
More options can be overridden from the [valkey chart](https://github.com/groundhog2k/helm-charts/tree/master/charts/valkey) here.
| Name           | Description                                                            | Default Value |
|-----------------|-------------------------------------------------------------------------|---------------|
| valkey.enabled | If the dependency Valkey is enabled, set to false if you use your own  | true          |


## Ingress
| Name                               | Description                                                                   | Default Value          |
|------------------------------------|-------------------------------------------------------------------------------|------------------------|
| ingress.enabled                    | If the ingress is enabled                                                     | false                  |
| ingress.annotations                | Annotations to be added to the ingress                                        | {}                     |
| ingress.ingressClassName           | Class name to use for the ingress                                             | ""                     |
| ingress.hosts[0].host              | The host name to be used for the ingress, make sure it matches the Pretix env | pretix.example.com     |
| ingress.hosts[0].paths[0].path     | The path under the host                                                       | /                      |
| ingress.hosts[0].paths[0].pathType | The pathType of the path under the host                                       | ImplementationSpecific |
| ingress.tls                        | TLS configuration for the ingress                                             | []                     |