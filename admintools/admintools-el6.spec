Summary: Admintools scripts
Name: admintools
Version: 3.44
Release: 1.el6
Source0: %{name}-%{version}.tgz
License: GPL
Group: Networking/Remote access
BuildRoot: %{_builddir}/%{name}-root
%define admintools_home      /opt
%define software_home  %{admintools_home}/admintools

%description
General administration Tools

%prep
%setup -n %{name}-%{version}
#%setup -q

%build

%install
#make DESTDIR=$RPM_BUILD_ROOT install
%{__rm} -rf %{buildroot}
%{__mkdir_p} %{buildroot}/%{admintools_home}
%{__mkdir_p} %{buildroot}/etc
%{__mkdir_p} %{buildroot}/etc/sysconfig
%{__mkdir_p} %{buildroot}/var/log/admintools
%{__cp} -a admintools  %{buildroot}/%{admintools_home}
%{__cp} -a admintools/etc/admintools.src.config %{buildroot}/etc/admintools.src

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root)
%{software_home}
/etc/admintools.src
/var/log/admintools

