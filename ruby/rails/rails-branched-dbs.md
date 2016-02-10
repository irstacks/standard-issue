http://jordanhollinger.com/2014/07/30/rails-migration-etiquette/

>When I was first introduced to branched databases, rainbows appeared, unicorns flew through the air, all those songs on the radio suddenly made sense, and Clarence Odbody from It’s a Wonderful Life finally got his wings.

>In your development and testing environments each git branch should have its own isolated database. This keeps database changes in branch A from breaking branch B’s code. It also helps you keep your db/schema.rb in pristine condition. Here’s a simple example with git:

```yml
<% branch = `git symbolic-ref HEAD 2>/dev/null`.chomp.sub('refs/heads/', '') %>

development:
  ...
  database: myapp_development_<%= branch %>

test:
  ...
  database: myapp_test_<%= branch %>
  ...
```
