#Sknservice
====

This application demonstrates and explores methods for Authentication, Access Authorizations,
and Content Authorizations.  Referred to as UserProfiles, AccessProfiles, and ContentProfiles in
this application.

    * UserProfiles deal with userid, password, password resets, and some preferences management.
    * AccessProfiles deal with what each user is allowed to access, click, or view.
    * ContentProfiles deal with specific content access priviledges; which document, etc.
    
UserProfiles and AccessProfiles have many options, and are well handled processes.  However,
ContentProfiles are the main focus of exploration in this app.  The current implementation of
AccessProfiles contains an XML AccessRegistry file which could embody the specific requirements of
the ContentProfile.  It would do this by creating an entry for each content type uri; like:

    * 'Agency/Commission-RPT/0034'
    * 'Agency/Commission-CSV/0034'
    * 'Agency/Experience-RPT/0034'
    * 'Agency/Commission-RPT/1003'
    * 'Agency/Commission-CSV/1003'
    * 'Agency/Experience-RPT/1003'
    
The above would need to be repeated for each agency, content type. A Security Role of say
'Content.Profile.Agency.Access' would be assigned to a given user, who has that Agency ID as
a part of their assigned agencies.  Implementations of AccessProfile would be extended to 
evaluate these entries when accessing secured content.

An alternate approach would be to use a specifically implemented ContentProfile. Capable of encoding
a persons priviledges.


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


