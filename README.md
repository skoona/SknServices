#SknService
---

Author: James Scott
Date: Dec 2015

#Introduction
---

This is a Rails 4.2, Ruby 2.3 (JRuby capable), PostgreSQL Application, which demonstrates Authentication and Authorization strategies.  

My original need was to demonstrate this methodology, rather than to continue open-ended theoretical discussions.  To end the conversations I needed
to create two model implementations, one based on an existing XML file; modeled after Java's Security Manager and permission.  The other implementation would
be a Database driven model that represented the same goal.  It is my observation that they both meet my objective, and could both
be used successfully in any application base.  

Of the two implementation strategies the database model is my preference, as it would be easier to create a UI to support it and to maintain as new permissions are added. The demonstration
of the final algorithmic result, is the 'ContentProfile Demo' page.  It lists all the systems users, and when one is selected it displays
both the XML AccessProfile, and the matching DB ContentProfile.

The algorithm and point being made was: Create a two-factor authorization per user, that precisely identifies the business entities a user is assigned, and precisely identifies the
types of content that user is authorized to interact with on behalf of business entity. I.e For Account number 1104, user UUID can view Commission Document type:96033

After having proven my point, I've decided to share the body of this work and complete it by implementing Corporate and Branch Office domain model.  The initial context of the application 
was to provide protection of important business documents like commission statements, and capturing operational attributes like, which states is a branch licensed to quote new business.

The basic security and authorization features are fully implemented and I think quite usable as a secure starter application.
  

James,


##Installation
---

You will need to install PostGreSQL, and add/edit PostgreSQL credentials:
 
    config/settings.yml, 
    config/settings/development.yml or create and edit config/settings/development.local.yml
    config/settings/test.yml or create and edit config/settings/test.local.yml
 
It might be helpful to set these environment params too:
    
    export COVERAGE=true
    export BUNDLE_PATH='vendor/bundle'     Note: use of rvm wipes out all these values, you may need to reset them
    
	note: demo userids are documented in the seeds.rb file.
	
    
The default Ruby for this package is 2.3.1  If you want to use a different version of ruby; Edit

```Bash

$ vim .ruby-version             # change to 'ruby-2.3.1'

```

    
    
Then execute;
 
```Bash

$ mkdir tmp
$ bin/setup
$ rspec

```

 
    Also: db/seeds.rb contains test user credentials
          lib/tasks/profile_tools_task.rake contain creates the initial database version of the content profile, during 'bin/setup'


![App Data Model](app/assets/images/SknService-Warden.jpg "Application Data Model")

##Overview
---

This application demonstrates and explores methods for Authentication, Access Authorizations,
and Content Authorizations.  Referred to as UserProfiles, AccessProfiles, and ContentProfiles in
this application.

* UserProfiles deal with userid, password, password resets, and some preferences management.
* AccessProfiles deal with what each user is allowed to access, click, or view.
* ContentProfiles deal with specific content access privileges; which document, etc.
    
UserProfiles and AccessProfiles have many different implementations available, and are well handled processes. The [Java Access Controller](http://www.cs.ait.ac.th/~on/O/oreilly/java-ent/security/ch05_01.htm "Java Access Controller"), and related classes,
 were the original template for the AccessRegistry or AccessProfile capability; This now is an enhanced Ruby port of those permission capabilities. However,
ContentProfiles are the main focus of exploration in this app, which has proven to be a significant 
engineering challenge when it comes to handling the dynamics of Electronic Delivery.  


###Core Idea
---

####ContentProfile and AccessProfile are implementations of the same core idea, with side benefits.  For lack of a better term: ContentProfile is the label adopted to represent that core idea.

In general anything that can be accessed is considered a CONTENT TYPE.  The specific entity that content is related to is considered a
TOPIC TYPE.  Both types must be fully qualified with their respective Identifiers. Once qualified the two are combined into a holding object 
called a Content Profile Entry, and given a descriptive title.

One Content Profile Entry describes one permission, through the combination of a fully qualified content type identifiers and topic type identifiers.  It is expected that a
user's collection would have many of these specialized entries, and that some entries may be shareable (reducing redundancy) with other users.  Entries
are themselves assigned to a wrapper object called a Content Profile which maintains a users unique collection.

Content Profiles are the anchor back to the User Profile, via the person authentication key(PAK) or UUID they rely on as THE primary identifier.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

        
##License
---

[The MIT License (MIT)](http://opensource.org/licenses/MIT)

Copyright (c) 2015-2016 James Scott, Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   
