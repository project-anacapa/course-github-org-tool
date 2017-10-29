# jenkins

The scripts here were taken in part from: https://technologyconversations.com/2017/06/16/automating-jenkins-docker-setup/

# updating plugins.txt

```sh
curl -s -k "http://admin:admin@localhost:8080/pluginManager/api/json?depth=1" \
  | jq -r '.plugins[].shortName' | tee plugins.txt
```

# Security
TODO: further restrict default access to jenkins. Right now it is far from particularly secure - users have read only access by default.

 - https://wiki.jenkins.io/display/JENKINS/Slave+To+Master+Access+Control
