# nlpf
Back : Crystal

CircleCI

## Run le site

#### MacOS

- `brew install crystal`
- `git clone git@github.com:AubSs/nlpf.git`
- `shards install`
- `crystal run main.cr`
- Aller sur `localhost:8080`

#### Hot Reload
On install => npm i nodemon -g

Puis => nodemon -e cr,ecr --exec "crystal run" main.cr

##### En cas de problèmes :

`ld: library not found for -lssl` => `brew install openssl`

Si le problème persiste : `ln -s /usr/local/Cellar/openssl/1.0.2p/lib/libssl.dylib /usr/local/lib/`

`ld: library not found for -lcrypto` => `ln -s /usr/local/opt/openssl/lib/libcrypto.dylib /usr/local/lib/`

Google Account
Email : bob.nlpf@gmail.com
Pwd : bob-nlpf75

Google Calendar
Client ID : 262112190673-gq64aiegasfunrf8754e0q3mpvi2lrrf.apps.googleusercontent.com
Client Secret : 6W2tTwBQOcn7ed5mj-lsdVfC

