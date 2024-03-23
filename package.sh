#!/bin/bash
git checkout main
mkdir /tmp/helm-package
helm package pretix-helm -d charts
helm repo index charts --url https://helm.techwolf12.nl
mv charts/* /tmp/helm-package
git checkout gh-pages
mv /tmp/helm-package/* .
git add *.tgz index.yaml
git commit -m "Update charts"
git push origin gh-pages
git checkout main