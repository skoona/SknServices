#Sknservice
---

##Installation
---

You will need to install PostGreSQL locally first. Then execute;
 
```Bash

$ bin/setup
$ rspec

```

##Overview
---

This application demonstrates and explores methods for Authentication, Access Authorizations,
and Content Authorizations.  Referred to as UserProfiles, AccessProfiles, and ContentProfiles in
this application.

* UserProfiles deal with userid, password, password resets, and some preferences management.
* AccessProfiles deal with what each user is allowed to access, click, or view.
* ContentProfiles deal with specific content access privileges; which document, etc.
    
UserProfiles and AccessProfiles have many different implementations available, and are well handled processes. The [Java Access Controller](http://www.cs.ait.ac.th/~on/O/oreilly/java-ent/security/ch05_01.htm "Java Access Controller"), and related classes,
 were the original template for the AccessRegistry or AccessProfile capability; This now is an enhanced Ruby port of those capabilities. However,
ContentProfiles are the main focus of exploration in this app, which has proven to be a significant 
engineering challenge to handle the dynamics of Electronic Delivery.  


##AccessProfile i.e (Secure::AccessRegistry)
---

The current implementation of
AccessProfile contains an XML Secure::AccessRegistry file which could embody the specific requirements of
the ContentProfile.  It would do this by creating an entry for each content type uri; like:

* 'Agency/Commission-STMT/0034'
* 'Agency/Commission-CSV/0034'
* 'Agency/Experience-STMT/0034'
* 'Agency/Commission-STMT/1003'
* 'Agency/Commission-CSV/1003'
* 'Agency/Experience-STMT/1003'
    
The above would need to be repeated for each agency, and content type. Security roles for administrating
who has access to each URI will need to be created.  Something like:

```Xml

<resource secured="true">
    <uri>Agency/Commission-STMT/0034</uri>
    <description>Agency Commision Report in ImageRight</description>
    <userdata>"drawerid:27655173|filetype:27635476|foldertype:27637844|doctype:955"</userdata>
    <permission type="READ">
        <authorizedRoles>
            <authorizedRole options="0034">ContentProfile.Access.Agency.Commission-STMT</authorizedRole>
        </authorizedRoles>
    </permission>
</resource>
<resource secured="true">
    <uri>Agency/Commission-CSV/0034</uri>
    <description>Agency Commision Report in csv format from ImageRight</description>
    <userdata>"drawerid:27655173|filetype:27635476|foldertype:27637844|doctype:955"</userdata>
    <permission type="READ">
        <authorizedRoles>
            <authorizedRole options="0034">ContentProfile.Access.Agency.Commission-CSV</authorizedRole>
        </authorizedRoles>
    </permission>
</resource>
<resource secured="true">
    <uri>Agency/Experience-STMT/0034</uri>
    <description>Agency Experience Report in ImageRight</description>
    <userdata>"drawerid:27655173|filetype:27635476|foldertype:27637844|doctype:955"</userdata>
    <permission type="READ">
        <authorizedRoles>
            <authorizedRole options="0034">ContentProfile.Access.Agency.Experience-STMT</authorizedRole>
        </authorizedRoles>
    </permission>
</resource>

```

Each role would be assigned to one or more individuals via the normal assignment method, Domino in our case.  With the
'ContentProfile.Access.Agency.Commission-RPT' role assigned to a user, and that user having agency '0034' in their 
user profile options, they would be allowed to view/download commission reports for that agency, and all agency in their user profile.  

Implementations of AccessProfile would be extended to 
evaluate these entries when accessing secured content.  Programmatic calls to the AccessProfile will need
to include a user's list of assigned agencies (options) for validation of their access privileges. 

    AccessControl API Examples: 
      boolean_result = AccessProfile.has_access?(user.roles, "Agency/Commission-STMT/0034", user_object.agencies)
      hash_result    = AccessProfile.get_userdata("Agency/Commission-STMT/0034")


##ContentProfile (i.e. The preferred Approach )
---

![ContentProfile](app/assets/images/AccessProfile-AccessRegistry.png "ContentProfile")

An alternate approach would be to use a specifically implemented ContentProfile. Capable of encoding
a persons privileges across a reasonable spectrum of content types.  This can be accomplished with
about eight data tables, and a admin ui.   Both approaches require programmatic extension to AccessProfile
to evaluate a users access to a specific bit of content.  

This is where we begin.


## Full Application Data Model
---

![App Data Model](app/assets/images/sknService-DataModel.png "Application Data Model")


## ContentProfile Data Model Resulting Transactions
---

###Final Access Package on Users List

```json

{
    "username":"skoona",
    "display_name":"Employee Primary User: Developer",
    "package":{
        "success":true,
        "message":"",
        "accessible_content_url":"/accessible_content?id=access",
        "page_user":"skoona",
        "access_profile":[
            {"name":"Services.Action.Admin","description":"Super User","type":"EmployeePrimary"},
            {"name":"Services.Action.Primary","description":"Super User","type":"EmployeePrimary"},
            {"name":"Services.Action.Developer","description":"Developer","type":"EmployeePrimary"},
            {"name":"Services.Action.ResetPassword","description":"Reset Forgotten Password via EMail","type":"EmployeePrimary"},
            {"name":"Services.Action.Admin.ContentProfile","description":"Administer Authorization Content Profile","type":"EmployeePrimary"},
            {"name":"Services.Action.Admin.UserAuthorizationGroups","description":"Administer Authorization Group","type":"EmployeePrimary"},
            {"name":"Services.Action.Admin.UserRecords","description":"Administer User Records","type":"EmployeePrimary"},
            {"name":"Services.Action.Developer","description":"Developer","type":"Assigned Role"},
            {"name":"EmployeePrimary","description":"BMI Admin User","type":"Assigned Group"}
                                   ]
                        }
}

```

###Final Content Package on Users List

```json

{
    "username":"skoona",
    "display_name":"Employee Primary User: Developer",
    "package":{
        "success":true,
        "message":"",
        "accessible_content_url":"/accessible_content?id=content",
        "page_user":"skoona",
        "content_profile":{
            "username":"skoona",
            "display_name":"Employee Primary User: Developer",
            "entries":[
                { "description":"Determine which agency documents can be seen",
                  "topic_value":"Agency",
                  "content_value":[
                                    "68601",
                                    "68602",
                                    "68603"
                                  ],
                  "content_type":"Commission",
                  "content_type_description":"Monthly Commission Reports and Files",
                  "topic_type":"Agency",
                  "topic_type_description":"Agency Actions"
                },
                {"description":"Determine which accounts will have notification sent","topic_value":"Account","content_value":["AdvCancel","FutCancel","Cancel"],"content_type":"Notification","content_type_description":"Email Notification of Related Events","topic_type":"Account","topic_type_description":"Account Actions"},
                {"description":"Determine which States agent may operate in.","topic_value":"LicensedStates","content_value":["21","9","23"],"content_type":"Operations","content_type_description":"Business Operational Metric","topic_type":"LicensedStates","topic_type_description":"Agent Actions"}
                                ],
            "pak":"eafbf74d395cd68e1b5743bad33a82b4",
            "profile_type":"EmployeePrimary",
            "profile_type_description":"BMI Admin User",
            "provider":"BCrypt",
            "email":"skoona@gmail.com"
                                    }
                       }
}

```

