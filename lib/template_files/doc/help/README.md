---
title: 'document work up'
authors:
  - happy
datetime: '2013-08-30 19:41'
---

# document Work up

## command

1. update codes

2. install GEMS:

```
  gem install docwu
  bundle install
```

3. development

  * bundle exec docwu server          # server start， http://127.0.0.1:5656
  * bundle exec docwu server -p 3300  # use 3300 port， http://127.0.0.1:3300

4. generate

  * bundle exec docwu generate

## Deploy

* use nginx, apache .. web server，
  root point to -> ruby_wiki/_deploy  # ！！！！

