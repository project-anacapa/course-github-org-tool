# jenkins

The scripts here were taken in part from: https://technologyconversations.com/2017/06/16/automating-jenkins-docker-setup/

# setting jenkins user and password
echo "admin" | docker secret create jenkins-user -
echo "admin" | docker secret create jenkins-pass -

# updating plugins.txt

```sh
curl -s -k "http://admin:admin@localhost:8080/pluginManager/api/json?depth=1" \
  | jq -r '.plugins[].shortName' | tee plugins.txt
```

# Security
TODO: restrict access to jenkins to only logged in users
