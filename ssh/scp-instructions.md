`rake db:seed:dump MODELS=School FILE=db/seeds/schools.rb`


# production -> local -> staging

## COPY FROM REMOTE SSH TO LOCAL 
`scp remoteuser@remotehost:/remote/dir/file /local/dir/`

```bash
rathack:.ec2 roho$ scp -i gsg-keypair4 root@ec2-52-24-58-239.us-west-2.compute.amazonaws.com:/mnt/rstacks-production/current/db/seeds/schools.rb ../Desktop/ 
scp -i gsg-keypair4 -r root@ec2-52-24-58-239.us-west-2.compute.amazonaws.com:/mnt/rstacks-production/current/solr ../Desktop/solr/
```

## COPY FROM LOCAL TO REMOTE SSH
`scp /tmp/file user@example.com:/home/name/dir`

```bash
scp -i gsg-keypair4 ../Desktop/schools.rb root@ec2-52-89-15-44.us-west-2.compute.amazonaws.com:/mnt/rstacks-staging/current/db/seeds.rb
scp -i gsg-keypair4 -r ../Desktop/solr/ root@ec2-52-89-15-44.us-west-2.compute.amazonaws.com:/mnt/rstacks-staging/current/solr/
```

`scp -i gsg-keypair4 ../Desktop/schools.rb root@ec2-52-27-198-224.us-west-2.compute.amazonaws.com:/mnt/rstacks-staging/current/db/seeds.rb`


## UPLOAD GOOGLE HTML API CRED THINGEY TO STAGING

`scp -i gsg-keypair4 ../Desktop/google01fc8103ba49e2f4.html root@ec2-52-27-198-224.us-west-2.compute.amazonaws.com`

