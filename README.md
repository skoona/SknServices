#Sknservice
====


### Prep test db with seed data
```bash
    
    $ RAILS_ENV=test rake db:setup
    $ RAILS_ENV=test rake db:seed

```

### Document DB Tables
```bash
    Gem 'annotate'
    bundle exec annotate --exclude tests,fixtures,factories,serializers
```

### Model Templates
```bash

    rails generate model NAME [field[:type][:index] field[:type][:index]] [options]
    rails generate scaffold NAME [field[:type][:index] field[:type][:index]] [options]
    
```

### Model Generation (SimpleForm UI)
    ***Make sure you edit config/initializers/generators.rb first***


