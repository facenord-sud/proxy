# A HTTP proxy for anonymous and fast browsing
### What it does ?

- Proxy: Handle incomming HTTP requests, redirect the request to the desired host and give the result back to the client.
- Chaching: A visited page is stored in a Redis databse. When visiting a page already cached, the cached page is returned
- Blacklisting: Block some request based on the host. Ruby regex can be used
- Logging: To logstash which parse it, save it to elasticsearch. After that, logs can be visualized with kibana.

### How ?
The proxy is based on the ruby rack library. Rack allow to create Web server with ease.

The cached pages are saved to a redis databse. To determine if a page is cached or not we generate the md5 of the uri request and search if already exist in the database.

The blacklisting is done using Ruby regex stored in a textfile. Each line of the file are evaluated as a Ruby regex.

The application server is Puma a powerful multi-threaded Ruby server. Is light and easy to configure

### Working?
Quite working! But... Some site have strange behaviour. For example browsing to Wikipedia don't return the CSS. Other sites are making strange request that must be taking in account

### What next?
- implementing a strong logging system for tracking errors. The idea is to make the proxy running, find some people to brows through for some hours, to collect and analyze logs to find which request was wrong and so imporve the proxy. For now, all logs are managed by the triplet (logstash, elasticsearch and kibana. Google it for more infos)
- developping the caching system. The key is to determine wich request to put in cache, for how long and for how. The way the cached page are stored and retrived must be imporved, too. A cached page can be in a lot of diffrent file format(utf-8, binary, ascii, etc)
- proposition: a system for user authtifications
- developping a way that many people can register host to blacklist
- optimizing blacklisting
- Write unit tests to imporve the development time (fatser after some unit tests are written). RSpec could be a good way.
- Write powerful integration test to verify that our proxy is working. The idea is that to use capybara with selenium through a proxy and to browse to a big amount of site. If all request are served correctly (compared when browsing outside of a proxy, the tests are passed). travis.io could be useful in this case.

### Developping
- install rvm
- install the latest ruby version
- install redis (redis.io)
- download logstash
- download kibana version 3
- clone this project
- start the proxy with `rackup`
- start logstash with the command `rake logs:logstash` (it assumes that logstash is located a dir up to the profy folder)
- start Kibana: In the Kibana folder run: `python SimpleHttpServer 8000`
- configure your computer to use the proxy
- browse to some sites
- visite localhost:8000 to see the logs
- 
