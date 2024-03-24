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
* postgresql
* redis

To disable this dependency during installation, set `postgresql.enabled` and `redis.enabled` to `false`.

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

# Parameters

## Image
| Name              | Description                                                                               | Default Value                                           |
|-------------------|-------------------------------------------------------------------------------------------|---------------------------------------------------------|
| image.repository  | The Pretix Docker repository you want to use, useful if you want custom plugins installed | pretix/standalone                                       |
| image.tag         | The Pretix Docker tag you want to use, useful if you want custom plugins installed        | Helm chart version, matching the Pretix release version |
| image.pullPolicy  | When you want Kubernetes to pull the Docker image                                         | IfNotPresent                                            |
| image.pullSecrets | Docker secret names as array, if your custom repo needs authentication to read            | []                                                      |

## Replicas
| Name               | Description                                       | Default Value |
|--------------------|---------------------------------------------------|---------------|
| replicas.pretixWeb | How many Pretix Web instances you want running    | 1             |
| replicas.pretixWeb | How many Pretix Worker instances you want running | 1             |

## Environment variables
See all possible config variables [on the Pretix documentation site](https://docs.pretix.eu/en/latest/admin/config.html).
The syntax is `PRETIX_SECTION_CONFIG`. For example, to configure the setting `password_reset` from the `[pretix]` section, set `PRETIX_PRETIX_PASSWORD_RESET: off` in your environment.
| Name                                      | Description                                                                                        | Default Value                 |
|-------------------------------------------|----------------------------------------------------------------------------------------------------|-------------------------------|
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
| env.PRETIX_DATABASE_HOST                  | Database Hostname, if using dependecy postgresql, this is `helm release name-postgresql`           | pretix-postgresql             |
| env.PRETIX_REDIS_LOCATION                 | Redis server, if using embedded Redis, this is `helm release name-redis-master`                    | redis://pretix-redis-master/0 |
| env.PRETIX_REDIS_SESSIONS                 | Should we use Redis for sessions                                                                   | true                          |
| env.PRETIX_CELERY_BACKEND                 | Redis server for Celery backend, if using embedded Redis, this is `helm release name-redis-master` | redis://pretix-redis-master/1 |
| env.PRETIX_CELERY_BROKER                  | Redis server for Celery Broker, if using embedded Redis, this is `helm release name-redis-master`  | redis://pretix-redis-master/2 |

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

## Postgresql
More options can be overridden from the Postgresql chart here.

| Name                             | Description                                                               | Default Value            |
|----------------------------------|---------------------------------------------------------------------------|--------------------------|
| postgresql.enabled               | If the dependency Postgresql is enabled, set to false if you use your own | true                     |
| postgresql.auth.database         | Pretix database name, make sure it matches in the env                     | pretix                   |
| postgresql.auth.username         | Pretix database username, make sure it matches in the env                 | pretix                   |
| postgresql.auth.password         | Pretix database password, make sure it matches in the env                 | pretix                   |
| postgresql.auth.postgresPassword | Password for the `postgres` admin user                                    | supersecureadminpassword |

## Redis
More options can be overridden from the Redis chart here.
| Name               | Description                                                          | Default Value |
|--------------------|----------------------------------------------------------------------|---------------|
| redis.enabled      | If the dependency Redis is enabled, set to false if you use your own | true          |
| redis.architecture | If Redis should run in replica or standalone                         | standalone    |
| redis.auth.enabled | If Redis authentication is enabled                                   | false         |


## Ingress
| Name                               | Description                                                                   | Default Value          |
|------------------------------------|-------------------------------------------------------------------------------|------------------------|
| ingress.enabled                    | If the ingress is enabled                                                     | false                  |
| ingress.annotations                | Annotations to be added to the ingress                                        | {}                     |
| ingress.hosts[0].host              | The host name to be used for the ingress, make sure it matches the Pretix env | pretix.example.com     |
| ingress.hosts[0].paths[0].path     | The path under the host                                                       | /                      |
| ingress.hosts[0].paths[0].pathType | The pathType of the path under the host                                       | ImplementationSpecific |
| ingress.tls                        | TLS configuration for the ingress                                             | []                     |