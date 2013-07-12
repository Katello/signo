# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
%else
    %global scl_ruby /usr/bin/ruby
%endif

%global homedir %{_datarootdir}/%{name}
%global datadir %{_localstatedir}/lib/%{name}
%global confdir deploy

Name:           signo
Version:        0.0.9
Release:        1%{?dist}
Summary:        A package for web based SSO for various applications
BuildArch:      noarch

Group:          Applications/Internet
License:        GPLv2
URL:            https://fedorahosted.org/katello/wiki/SingleSignOn
Source0:        https://github.com/Katello/signo/archive/%{name}-%{version}.tar.gz

BuildRequires:  %{?scl_prefix}rubygems
BuildRequires:  %{?scl_prefix}rubygem(logging) >= 1.8.0
BuildRequires:  %{?scl_prefix}rubygem(rails) >= 3.2
BuildRequires:  %{?scl_prefix}rubygem(haml) >= 3.1.2
BuildRequires:  %{?scl_prefix}rubygem(haml-rails)
BuildRequires:  %{?scl_prefix}rubygem(compass-rails)
BuildRequires:  %{?scl_prefix}rubygem(coffee-rails) >= 3.2.1
BuildRequires:  %{?scl_prefix}rubygem(uglifier) >= 1.0.3
BuildRequires:  %{?scl_prefix}rubygem(jquery-rails) >= 1.0.3
BuildRequires:  %{?scl_prefix}rubygem(net-ldap)
BuildRequires:  %{?scl_prefix}rubygem(i18n_data) >= 0.2.6
BuildRequires:  %{?scl_prefix}rubygem(therubyracer)
BuildRequires:  %{?scl_prefix}rubygem(gettext_i18n_rails)
BuildRequires:  %{?scl_prefix}rubygem(ldap_fluff)
BuildRequires:  %{?scl_prefix}rubygem(ui_alchemy-rails) >= 1.0.4
BuildRequires:  %{?scl_prefix}rubygem(ruby-openid)
BuildRequires:  %{?scl_prefix}rubygem(thin)
BuildRequires:  %{?scl_prefix}rubygem(webmock)
BuildRequires:  %{?scl_prefix}rubygem(minitest)
BuildRequires:  %{?scl_prefix}rubygem(minitest-rails)

BuildRequires:  gettext
BuildRequires:  translate-toolkit

Requires:  %{?scl_prefix}rubygem(ruby-openid)
Requires:  %{?scl_prefix}rubygem(sass-rails) >= 3.2.3
Requires:  %{?scl_prefix}rubygem(coffee-rails) >= 3.2.1
Requires:  %{?scl_prefix}rubygem(uglifier) >= 1.0.3
Requires:  %{?scl_prefix}rubygem(compass-rails)
Requires:  %{?scl_prefix}rubygem(ui_alchemy-rails) >= 1.0.4
Requires:  %{?scl_prefix}rubygem(jquery-rails) >= 1.0.3
Requires:  %{?scl_prefix}rubygem(net-ldap)
Requires:  %{?scl_prefix}rubygem(logging) >= 1.8.0
%if 0%{?rhel} == 6
Requires:  lsof
%endif

BuildRequires: %{?scl_prefix}ruby(abi) = 1.9.1
BuildRequires: %{?scl_prefix}ruby

Requires(pre):    shadow-utils
Requires(postun): coreutils sed

%if 0%{?rhel} == 6
Requires(preun):  chkconfig
Requires(preun):  initscripts
Requires(post):   chkconfig
Requires(postun): initscripts
%else
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
%endif

%description
Web based SSO for various applications

%package   katello
Summary:   Signo integration to Katello
BuildArch: noarch
Requires:  katello-common 

%description katello
Signo-Katello integration configuration. It sets Apache configuration file that
Katello includes into its virtual host.

%package devel
Summary:         Signo devel support
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
Requires:        %{?scl_prefix}rubygem(gettext) >= 1.9.3

%description devel
Rake tasks and dependecies for Signo developers

%package devel-test
Summary:         Signo devel support (testing)
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
Requires:        %{name}-devel = %{version}-%{release}
# dependencies from bundler.d/test.rb
BuildRequires:        %{?scl_prefix}rubygem(webmock)
BuildRequires:        %{?scl_prefix}rubygem(minitest)
BuildRequires:        %{?scl_prefix}rubygem(minitest-rails)

%description devel-test
Rake tasks and dependecies for Signo developers, which enables
testing.

%prep
%setup -n %{name}-%{version} -q

%build
export RAILS_ENV=build

#replace shebangs for SCL
%if %{?scl:1}%{!?scl:0}
    sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X' script/*
%endif

# create empty sso.yml config file
echo "# overwrite config options in this file instead of changing sso_defaults.yml" > config/sso.yml

%if ! 0%{?fastbuild:1}
    #generate Rails JS/CSS/... assets
    echo Generating Rails assets...
%{?scl:scl enable %{scl} "}
    LC_ALL="en_US.UTF-8" rake assets:precompile
%{?scl:"}

    echo Generating gettext files...
%{?scl:scl enable %{scl} "}
    make -C locale check all-mo %{?_smp_mflags}
%{?scl:"}
%endif

%install
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{datadir}
install -d -m0755 %{buildroot}%{datadir}/tmp
install -d -m0755 %{buildroot}%{datadir}/tmp/pids
install -d -m0755 %{buildroot}%{datadir}/config
install -d -m0755 %{buildroot}%{datadir}/openid-store
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}

install -d -m0755 %{buildroot}%{_localstatedir}/log/%{name}

# clean the application directory before installing
[ -d tmp ] && rm -rf tmp

#copy the application to the target directory
mkdir .bundle
cp -R .bundle Gemfile bundler.d Rakefile app config config.ru db lib locale public script test vendor %{buildroot}%{homedir}

#copy MO files
pushd locale
for MOFILE in $(find . -name "*.mo"); do
    DIR=$(dirname "$MOFILE")
    install -d -m 0755 %{buildroot}%{_datadir}/signo/locale/$DIR
    install -d -m 0755 %{buildroot}%{_datadir}/signo/locale/$DIR/LC_MESSAGES
    install -m 0644 $DIR/*.mo %{buildroot}%{_datadir}/signo/locale/$DIR/LC_MESSAGES
done
popd

# default empty config file
touch %{buildroot}%{_sysconfdir}/%{name}/sso.yml
chmod 600 %{buildroot}%{_sysconfdir}/%{name}/sso.yml

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0644 %{confdir}/%{name}.httpd.conf %{buildroot}%{_sysconfdir}/httpd/conf.d/katello.d/%{name}.conf
install -Dp -m0644 %{confdir}/thin.yml %{buildroot}%{_sysconfdir}/%{name}/
%if 0%{?rhel} == 6
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initddir}/%{name}
%else
install -Dp -m0755 %{confdir}/%{name}.service %{buildroot}/usr/lib/systemd/system/%{name}.service
%endif

# we must remove Require all granted line from Apache config for RHEL in order to serve static assets
# however on Fedora 18 this line must be present
%if 0%{?rhel} == 6
  sed -i '/Require all granted/d' %{buildroot}%{_sysconfdir}/httpd/conf.d/katello.d/%{name}.conf
%endif

#overwrite config files with symlinks to /etc/signo
ln -svf %{_sysconfdir}/%{name}/sso.yml %{buildroot}%{homedir}/config/sso.yml

#create symlinks for data
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{homedir}/log
ln -sv %{datadir}/openid-store %{buildroot}%{homedir}/db/openid-store
ln -sv %{datadir}/tmp %{buildroot}%{homedir}/tmp

#remove files which are not needed in the homedir
find %{buildroot}%{homedir} -name .gitkeep -exec rm -f {} \;

#correct permissions
find %{buildroot}%{homedir} -type d -print0 | xargs -0 chmod 755
find %{buildroot}%{homedir} -type f -print0 | xargs -0 chmod 644
chmod +x %{buildroot}%{homedir}/script/*

%pre
# Add the "signo" user and group
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d %{homedir} -s /sbin/nologin -c "Signo" %{name}
exit 0

%post

%if 0%{?rhel} == 6
# let katello-configure do this
# /bin/systemctl enable signo
%else
#Add /etc/rc*.d links for the script
/sbin/chkconfig --add %{name}
%endif

#Generate secret token if the file does not exist
#(this must be called both for installation and upgrade)
TOKEN=/etc/signo/secret_token
# this file must not be world readable at generation time
umask 0077
test -f $TOKEN || (echo $(</dev/urandom tr -dc A-Za-z0-9 | head -c128) > $TOKEN \
    && chmod 600 $TOKEN && chown signo:signo $TOKEN)

%posttrans
/sbin/service %{name} condrestart >/dev/null 2>&1 || :

%files
%ghost %attr(600, signo, signo) %{_sysconfdir}/%{name}/secret_token
%dir %{homedir}/app
%{homedir}/app/controllers
%{homedir}/app/helpers
%{homedir}/app/mailers
%dir %{homedir}/app/models
%dir %{homedir}/app/models/backends
%{homedir}/app/models/backends/*.rb
%{homedir}/app/models/*.rb
%{homedir}/app/assets
%{homedir}/app/views
%{homedir}/config
%{homedir}/db
%{homedir}/db/seeds.rb
%{homedir}/lib
%{homedir}/locale
%{homedir}/log
%{homedir}/public/*.html
%{homedir}/public/*.txt
%{homedir}/public/assets
%{homedir}/public/javascripts
%{homedir}/public/stylesheets
%{homedir}/script
%{homedir}/test
%{homedir}/tmp
%{homedir}/vendor
%exclude %{homedir}/.bundle
%{homedir}/config.ru
%{homedir}/Gemfile
%{homedir}/Rakefile
%attr(600, signo, signo) %{_sysconfdir}/%{name}/thin.yml
%attr(600, signo, signo) %{_sysconfdir}/%{name}/sso.yml

%if 0%{?rhel} == 6
%{_sysconfdir}/rc.d/init.d/%{name}
%else
/usr/lib/systemd/system/%{name}.service
%endif

%{_sysconfdir}/sysconfig/%{name}


%defattr(-, signo, signo)
%dir %{homedir}
%attr(750, signo, signo) %{_localstatedir}/log/%{name}
%{datadir}
%ghost %attr(640, signo, signo) %{_localstatedir}/log/%{name}/production.log

%files katello
%{_sysconfdir}/httpd/conf.d/katello.d/%{name}.conf

%files devel
# this package just installs dependencies for I18n

%files devel-test
%{homedir}/bundler.d/test.rb

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi


