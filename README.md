# Signo - Katello SSO Rails app

This applications was developed as a part of Katello project. However it can be used with any other
application that would benefit from same schema. To find out information about how it works checkout
wiki page https://fedorahosted.org/katello/wiki/SingleSignOn

# Setup

There are currently two authentication backends. First is using Katello application and second
is using LDAP. You can use all backends at the same time. You just configure which you want to use
in configuration file under key backends.enabled. It's an array, user is authenticated when first
of them responds with success.

## Katello backend

You must configure Katello authentication URL in configuration file. Use config/sso.yml and set
key backends.katello.url with URL of your Katello installation. Note that this applications sends
credentials unencrypted so make sure you use HTTPS in production.

## LDAP backend

We are using ldap_fluff gem, checkout it's documentation for more details about configuration
options
https://github.com/jsomara/ldap_fluff

At time of writing it should support OpenLDAP, FreeIPA and AD ldaps. You can configure it in main
Signo configuration file under key backends.ldap

## Enforce SSL option

You should use HTTPS whenever possible. Some relay parties (Signo clients) may use old rack which
has problems detecting HTTPS request behind proxy. E.g. Katello is usually installed behind Apache
which works as reverse proxy server.

If this is your case you must enable enforce_ssl option in configuration file. This will make sure
all redirects outside Signo are using HTTPS protocol.

Also if you want to make sure your relay party verifies Signo's cert properly, you should configure
you OpenID client to trust your CA. You can add code like this to your config/environment.rb

    # Load certificate
    OpenID.fetcher.ca_file = "#{Rails.root}/config/ca-bundle.crt"

# Tests

To run tests you can use rake task
    rake minitest:unit

