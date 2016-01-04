#Sknservice
---

This application demonstrates and explores methods for Authentication, Access Authorizations,
and Content Authorizations.  Referred to as UserProfiles, AccessProfiles, and ContentProfiles in
this application.

* UserProfiles deal with userid, password, password resets, and some preferences management.
* AccessProfiles deal with what each user is allowed to access, click, or view.
* ContentProfiles deal with specific content access privileges; which document, etc.
    
UserProfiles and AccessProfiles have many different implementations available, and are well handled processes. Java Class AccessController, and related classes,
 were the original template for the AccessRegistry or AccessProfile capability; This now is an enhanced Ruby port of those capabilites. However,
ContentProfiles are the main focus of exploration in this app, which has proven to be a significant 
engineering challenge to handle the dynamics of Electronic Delivery.  

AccessProfile i.e (Secure::AccessRegistry)
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

##ContentProfile
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

data-package=
    {
        &quot;username&quot;:&quot;skoona&quot;,
        &quot;display_name&quot;:&quot;Employee Primary User: Developer&quot;,
        &quot;package&quot;:{
            &quot;success&quot;:true,
            &quot;message&quot;:&quot;&quot;,
            &quot;accessible_content_url&quot;:&quot;/accessible_content?id=access&quot;,
            &quot;page_user&quot;:&quot;skoona&quot;,
            &quot;access_profile&quot;:[
                {&quot;name&quot;:&quot;Services.Action.Admin&quot;,&quot;description&quot;:&quot;Super User&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.Primary&quot;,&quot;description&quot;:&quot;Super User&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.Developer&quot;,&quot;description&quot;:&quot;Developer&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.ResetPassword&quot;,&quot;description&quot;:&quot;Reset Forgotten Password via EMail&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.Admin.ContentProfile&quot;,&quot;description&quot;:&quot;Administer Authorization Content Profile&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.Admin.UserAuthorizationGroups&quot;,&quot;description&quot;:&quot;Administer Authorization Group&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.Admin.UserRecords&quot;,&quot;description&quot;:&quot;Administer User Records&quot;,&quot;type&quot;:&quot;EmployeePrimary&quot;},
                {&quot;name&quot;:&quot;Services.Action.Developer&quot;,&quot;description&quot;:&quot;Developer&quot;,&quot;type&quot;:&quot;Assigned Role&quot;},
                {&quot;name&quot;:&quot;EmployeePrimary&quot;,&quot;description&quot;:&quot;BMI Admin User&quot;,&quot;type&quot;:&quot;Assigned Group&quot;}
                                       ]
                            }
    }

```

###Final Content Package on Users List

```json

data-package=
    {
        &quot;username&quot;:&quot;skoona&quot;,
        &quot;display_name&quot;:&quot;Employee Primary User: Developer&quot;,
        &quot;package&quot;:{
            &quot;success&quot;:true,
            &quot;message&quot;:&quot;&quot;,
            &quot;accessible_content_url&quot;:&quot;/accessible_content?id=content&quot;,
            &quot;page_user&quot;:&quot;skoona&quot;,
            &quot;content_profile&quot;:{
                &quot;username&quot;:&quot;skoona&quot;,
                &quot;display_name&quot;:&quot;Employee Primary User: Developer&quot;,
                &quot;entries&quot;:[
                    { &quot;description&quot;:&quot;Determine which agency documents can be seen&quot;,
                      &quot;topic_value&quot;:&quot;Agency&quot;,
                      &quot;content_value&quot;:[
                                         &quot;68601&quot;,
                                         &quot;68602&quot;,
                                         &quot;68603&quot;
                                                ],
                      &quot;content_type&quot;:&quot;Commission&quot;,
                      &quot;content_type_description&quot;:&quot;Monthly Commission Reports and Files&quot;,
                      &quot;topic_type&quot;:&quot;Agency&quot;,
                      &quot;topic_type_description&quot;:&quot;Agency Actions&quot;
                    },
                    {&quot;description&quot;:&quot;Determine which accounts will have notification sent&quot;,&quot;topic_value&quot;:&quot;Account&quot;,&quot;content_value&quot;:[&quot;AdvCancel&quot;,&quot;FutCancel&quot;,&quot;Cancel&quot;],&quot;content_type&quot;:&quot;Notification&quot;,&quot;content_type_description&quot;:&quot;Email Notification of Related Events&quot;,&quot;topic_type&quot;:&quot;Account&quot;,&quot;topic_type_description&quot;:&quot;Account Actions&quot;},
                    {&quot;description&quot;:&quot;Determine which States agent may operate in.&quot;,&quot;topic_value&quot;:&quot;LicensedStates&quot;,&quot;content_value&quot;:[&quot;21&quot;,&quot;9&quot;,&quot;23&quot;],&quot;content_type&quot;:&quot;Operations&quot;,&quot;content_type_description&quot;:&quot;Business Operational Metric&quot;,&quot;topic_type&quot;:&quot;LicensedStates&quot;,&quot;topic_type_description&quot;:&quot;Agent Actions&quot;}
                                    ],
                &quot;pak&quot;:&quot;eafbf74d395cd68e1b5743bad33a82b4&quot;,
                &quot;profile_type&quot;:&quot;EmployeePrimary&quot;,
                &quot;profile_type_description&quot;:&quot;BMI Admin User&quot;,
                &quot;provider&quot;:&quot;BCrypt&quot;,
                &quot;email&quot;:&quot;skoona@gmail.com&quot;
                                        }
                           }
    }

```

