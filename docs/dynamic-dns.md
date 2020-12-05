# Dynamic DNS

The lxd-manager takes full control over the delegated DNS domain and acts as authoritative server. For some applications it might however be useful add custom entries in this zone.

## Static Extra Entries

To add static entries to your delegated zone, add them in the admin panel at
[/admin/dns/zoneextra/](admin/dns/zoneextra/)

They are parsed as bind zone files, may contain multiple lines and use an ORIGIN as defined. To create a wildcard RR for anything under k3s.your-delegation.tld to 1.2.3.4 use. 

    *.k3s  3600 IN A 1.2.3.4

The description is just to keep entries organized.

## Dynamic Updates

For more complex scenarios, there is a need for API access to the resource records of the authoritative zone.
This is for example the case for wildcard ACME TLS certificates.

### Service User

To authenticate updates to the RR, first select a user, or better, create a service user at [/admin/auth/user/](/admin/auth/user/), which is local to the lxd-manager and not authenticated via gitlab oauth.

### Auth Token
Then add an access token to this user at [/admin/authtoken/tokenproxy/add/](/admin/authtoken/tokenproxy/add/). Use the magnifier icon to search the service user's id.
On the token overview [/admin/authtoken/tokenproxy/](/admin/authtoken/tokenproxy/), copy the key.

### RR Template
In this step, create the template for the dynamic entry at [/admin/dns/dynamicentry/](/admin/dns/dynamicentry/). The dynamic value is inserted by `%s`. As an example, to create a template for an ACME challenge TXT RR for the subdomain p.your-delegation, use

    _acme-challenge.p 60 IN TXT "%s"

and set the service user as the *owner*. Leave the *value* empty. Note down the ID of the template (seen in the URL admin/dns/dynamicentry**/1/**change/)

### Update Value

To set the value, use e.g. this curl command

    curl -H "Authorization: Token ${TOKEN}" -X PUT -H "Content-Type: application/json" -d "{\"value\":\"${4}\"}"  ${APIURL}/api/dynamicentry/${UPDATEID}/

where

    # the api location without trailing /
    APIURL="https://lxd-manager.tld"
    # the id of the updateable object, found on the /api/dynamicentry/ list overview
    UPDATEID= e.g. 1
    # the token of one of the owners
    TOKEN=e.g. "123987acf9871092837918279381723"

### Dehydrated Hook Script

If you use [https://dehydrated.io/](dehydrated) to obtain your certifcates, use the hook script at [dehydrated-hook.sh](https://github.com/lxd-manager/deploy/blob/master/dns_hooks/dehydrated-hook.sh) directly and adapt it with the values from above.