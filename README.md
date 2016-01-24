#SknService
---

Author: James Scott
Date: Dec 2015


##Installation
---

You will need to install PostGreSQL, and add/edit database credentials:
 
    config/settings.yml, 
    config/settings/development.yml or create and edit config/settings/development.local.yml
    config/settings/test.yml or create and edit config/settings/test.local.yml
 
It might be helpful to set these environment parms too:
    
    export COVERAGE=true
    export JRUBY='--server --debug'
    export BUNDLE_PATH='vendor/bundle'
    
Then execute;
 
```Bash

$ bin/setup
$ rspec

```

    Note: Ruby 2.2.+ is also supported with database adapter change. JRuby 9.0.40.+ is the default 


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


###ContentProfile and AccessProfile are implementations of the same core idea, with side benefits.  For lack of a better term: ContentProfile is the label adopted to represent that core idea.

##Core Idea

In general anything that can be accessed is considered a CONTENT TYPE.  The specific entity that content is related to is considered a
TOPIC TYPE.  Both types must be fully qualified with their respective Identifiers. Once qualified the two are combined into a holding object 
called a Content Profile Entry, and given a descriptive title.

One Content Profile Entry describes one permission, through the combination of a fully qualified content type and topic type.  It is expected that a
user's collection would have many of these specialized entries, and that some entries may be shareable (reducing redundancy) with other users.  Entries
are themselves assigned to a wrapper object called a Content Profile which maintains the collection.

Content Profiles are the anchor back to the User Profile, via the person authentication key(PAK) or UUID they rely on as THE primary identifier.


##Objective
---

The system shall offer methods to:

1. Clearly indicate an employee, vendor, manager, customer service representative, or any business ACTORs role!
    * by identifying the person(s) using a permanent and persistent identifier from a trusted authentication source.
2. Ensure user is authenticated and that user has specific access to the requested page, api, and click-ables on that page; unless the target page is public.
    * by using the permission roles assigned to each authenticated user and the Secure::AccessProfile access class.
3. Ensure user is constrained to interact with processes or view information they were specifically authorized for!
    * by identifying the person(s) identifier, and applying their Secure::ContentProfile collection of permissions to control access to both processes and information.
4. Have no hard Rails dependencies, and serve as a technology platform for building secure web applications.
    * Outside of keeping its private tables in AR, it supplies its services independent of Rails.
    * It is assumed that user records and most displayable information is not solely housed locally in Rails; but sourced from external systems or computed.


##AccessProfile i.e (Secure::AccessRegistry)
---
The current implementation of AccessProfile contains an XML Secure::AccessRegistry file which could embody the specific requirements of
the ContentProfile.  It would do this by creating an entry for each content type uri; like:

* Description => 'URI'
*    Document Access => 'Commission/Agency/0024'
* Process Constraint => 'Quoting/LicensedStates/USA'
*         Operations => 'Notifications/Account/1003'
    
The URI syntax thinking is A/B/C.  Where A is the content(What), B is the entity type(Who), and C is the entity identifier(Who's ID). A <userdata> field contains
the identifiers for A content(What's IDs).  Example: Commission documents for Agency 24, where the list of document type ids is contained in userdata.  

This translates to AccessRegistry XML like the following:

```Xml

<resource secured="true" content="true">
    <uri>Commission/Agency/0024</uri>
    <description>Agency 24 Commision Reports in Imaging System Storage</description>
    <userdata>"drawerid:27655173|filetype:27635476|foldertype:27637844|doctype:[955,956,957]"</userdata>
    <permission type="READ">
        <authorizedRoles>
            <authorizedRole options="0024">ContentProfile.Access.Agency.Commission</authorizedRole>
        </authorizedRoles>
    </permission>
</resource>

<resource secured="true" content="true">
    <uri>Quoting/LicensedStates/USA</uri>
    <description>Licensed to produce Quote in Michigan, Indiana, Ohio, and Illinois</description>
    <userdata>"MI,IN,OH,IL"</userdata>
    <permission type="READ">
        <authorizedRoles>
            <authorizedRole options="AGENT,CSR">ContentProfile.Operational.Process.Quoting</authorizedRole>
        </authorizedRoles>
    </permission>
</resource>

<resource secured="true" content="true">
    <uri>Notifications/Account/1003</uri>
    <description>Change Notification for Account 1003</description>
    <userdata>"Payments|Invoices|Cancels|Claims|Approvals"</userdata>
    <permission type="READ">
        <authorizedRoles>
            <authorizedRole options="1003">ContentProfile.Operations.Notifications</authorizedRole>
        </authorizedRoles>
    </permission>
</resource>

```


Each role would be assigned to one or more individuals via the normal assignment method.  With the
 role assigned to a user, and that user having agency '0024' in their 
user profile options, they would be allowed to view/download commission reports for that agency, and all agency in their user profile.  

Implementations of AccessProfile would evaluate these entries when accessing secured content.  Programmatic calls to the AccessProfile will need
to include a user's list of assigned agencies (options), and assigned roles for validation of their access privileges. 


###If the permission has options, at least one user options must match! 

This allows for the options attribute to override the one value specified in the URI.  When XML options attribute list all agencies for with this 
service enabled, the user will be required to have at least one option in their profile and the specific authorizedRole.


```Ruby

def has_access? (resource_uri, options=nil)
  rc = Secure::AccessRegistry.check_access_permissions?( access_roles_all, resource_uri, options)
  Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
  rc
end

def has_create? (resource_uri, options=nil)
  Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "CREATE", options)
end
def has_read? (resource_uri, options=nil)
  Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "READ", options)
end
def has_update? (resource_uri, options=nil)
  Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "UPDATE", options)
end
def has_delete? (resource_uri, options=nil)
  Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "DELETE", options)
end

def get_resource_description(resource_uri)
  Secure::AccessRegistry.get_resource_description(resource_uri)
end
def get_resource_userdata(resource_uri)
  Secure::AccessRegistry.get_resource_userdata(resource_uri)
end
def get_resource_content_entries(opt=nil)
  opts = opt || self[:user_options] || nil
  Secure::AccessRegistry.get_resource_content_entries(self[:roles], opts)
end
def get_resource_content_entry(resource_uri, opt=nil)
  opts = opt || self[:user_options] || nil
  Secure::AccessRegistry.get_resource_content_entry(self[:roles], resource_uri,  opts)
end

```

    AccessControl API Examples: 
      hash_result = get_resource_content_entries(user_object.agencies)
      hash_result = get_resource_content_entry("Commission/Agency/0024", user_object.agencies)
      
      hash_result has been standardized to be same as alternate method being proposed.


##ContentProfile (i.e. The preferred Approach )
---

Preferred as in reference to getting the job done.  We could implement both the xml and the db strategies.  XML version for program assets, DB for business information and processes.  But I need to be clear we can use either strategy.

![ContentProfile](app/assets/images/SknService-CoreComponents.jpg "ContentProfile")

An alternate approach would be to use a specifically implemented ContentProfile. Capable of encoding
a persons privileges across a reasonable spectrum of content types.  This can be accomplished with
about eight data tables, and a admin ui.   Both approaches require programmatic extension to AccessProfile
to evaluate a users access to a specific bit of content.  

This is where we begin.


## Full Application Data Model
---

![App Data Model](app/assets/images/SknService-DataModel.png "Application Data Model")


###ContentProfile Data Model Resulting Transactions ( WIP )
---

####Access Package listing: One for each user is available in the API

```json 

{
  "user_options":["Manager","0024","0037","0040"],
  "username":"developer",
  "display_name":"Employee Primary User: Developer",
  "package":{
    "success":true,
    "message":"AccessProfile Entries for developer:Employee Primary User: Developer Options=Manager,0024,0037,0040",
    "user_options":["Manager","0024","0037","0040"],
    "accessible_content_url":"/profiles/accessible_content.json?id=access",
    "page_user":"developer",
    "access_profile":{
        "username":"developer","entries":[
           {"user_options":["Manager","0024","0037","0040"],
            "topic_value":"PDF",
            "content_value":{"doctype":"954"},
            "content_type":"Commission",
            "content_type_description":"Agency Commission Statements",
            "topic_type":"Agency",
            "topic_type_description":"Agency Commission Statements",
            "description":"Agency Commission Statements",
            "username":"developer",
            "uri":"Commission/Agency/PDF"
           },
           {"user_options":["Manager","0024","0037","0040"],"topic_value":"CSV","content_value":{"doctype":"955"},"content_type":"Commission","content_type_description":"Agency Commission CSV Datafiles","topic_type":"Agency","topic_type_description":"Agency Commission CSV Datafiles","description":"Agency Commission CSV Datafiles","username":"developer","uri":"Commission/Agency/CSV"},
           {"user_options":["Manager","0024","0037","0040"],"topic_value":"PDF","content_value":{"doctype":"956"},"content_type":"Experience","content_type_description":"Agency Experience Statements","topic_type":"Agency","topic_type_description":"Agency Experience Statements","description":"Agency Experience Statements","username":"developer","uri":"Experience/Agency/PDF"}
                                     ],
        "pak":null,
        "profile_type":"",
        "profile_type_description":"",
        "provider":"UserProfile",
        "display_name":"Employee Primary User: Developer",
        "email":"developer@gmail.com"
    }
  }
}

```

###Access Package on Users List

```json

REQUEST:  { AccessProfile
    "user_options":["Manager","0024","0037","0040"],
    "topic_value":"PDF",
    "content_value":{"doctype":"954"},
    "content_type":"Commission",
    "content_type_description":"Agency Commission Statements",
    "topic_type":"Agency",
    "topic_type_description":"Agency Commission Statements",
    "description":"Agency Commission Statements",
    "uri":"Commission/Agency/PDF",
    "username":"developer"
    }
    
RESPONSE: {
    "success":true,
    "content":"access"
    "message":"",
    "username":"developer",
    "display_name":"Employee Primary User: Developer",
    "package":[
        {"source":"datafiles","filename":"someFile.dat","created":"2016-01-05T16:18:57.881-05:00","size":"0"},
        {"source":"images","filename":"somePic.png","created":"2016-01-05T16:18:57.881-05:00","size":"0"},
        {"source":"pdfs","filename":"someFile.pdf","created":"2016-01-05T16:18:57.881-05:00","size":"0"}
              ]
    }

```

###ContentProfile Package on Users List

```json

REQUEST: { 
    "user_options":["Manager","0024","0037","0040"],
    "topic_value":"Agency",
    "content_value":["68601","68602","68603"],
    "content_type":"Commission",
    "content_type_description":"Monthly Commission Reports and Files",
    "topic_type":"Agency",
    "topic_type_description":"Agency Actions",
    "description":"Determine which agency documents can be seen",
    "username":"developer"
    }
    
RESPONSE: {
    "content":"content"
    "success":true,
    "message":"",
    "username":"developer",
    "display_name":"Employee Primary User: Developer",
    "package":[
        {"source":"datafiles","filename":"someFile.dat","created":"2016-01-05T16:24:12.066-05:00","size":"0"},
        {"source":"images","filename":"somePic.png","created":"2016-01-05T16:24:12.066-05:00","size":"0"},
        {"source":"pdfs","filename":"someFile.pdf","created":"2016-01-05T16:24:12.066-05:00","size":"0"}
              ]
    }


```

##Todos
---

1. Create a Authorizing Menu Manager View Class
    * Should Authorize a full menu, removing non-authorized items at Warden's :after_authentication callback
    * Cache itself to Session or ObjectStore via Controller before_action/After_action
    * Have a flexible initialization Hash, that specifies all levels including submenus
2. Create a PageAction Class View Class: DONE 1/20/2016
    * Should generate on-demand based on presence of :page_actions key's presence in @page_controls
    * Should handle sub-menus, headers, icons, and dividers.
    * Should resolve router path and url symbols, with all options (:id, :text:, and :html_options)
    * Sub-menus should be hover sensitive
3. Create ContentProfile Creation Screen
    * Allow creation of full profiles, or components as needed.
4. Refactor Rails Controllers into Domain/Service model for Users, UserGroups, and UserRoles
    * Simular to ContentProfile tables
5. Write AccessRegistry XML Class to CRUD xml entries
6. Write ContentProfile Executor
    * to render results from 'controlled' directory to demo assessable table
7. Review and update text top level pages, also improve their structure
8. Complete design guidance page
9. Roll application into a Rails Engine for delivery
10. Upgrade to Rails 5.0
11. Implement Warble War for Tomcat Execution
12. Consider a Rack UnAuthenticated Application for repeated violations.
13. Build a Registration Feature to enroll user locally.
    * Presume user does not exist
    * Capture or generate a PAK
    * Assign default Public Groups
    * Assign default ContentProfile
    * Create Local User record
    * Email user a ChangePassword to complete registration

    
    
##License
---

The MIT License (MIT)

Copyright (c) 2016 James Scott, Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   