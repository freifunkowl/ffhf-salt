# B.A.T.M.A.N. - Better Approach To Mobile Adhoc Networking

{% set batman = salt['grains.filter_by']({
  'Debian': {'pkgs': ['batctl', 'batman-adv-dkms']},
}, default='Debian') %}

{% if grains['os'] == 'Ubuntu' and grains['osrelease'] != '16.04' %}
batman:
  pkgrepo.managed:
    - ppa: freifunk-mwu/freifunk-ppa
    - keyid_ppa: True
    - require_in:
      - pkg: batman
  pkg.installed:
    - pkgs:
      {% for pkg in batman.pkgs %}
      - {{ pkg }}
      {% endfor %}
    # - fromrepo: ppa:freifunk-mwu/freifunk-ppa
    - refresh: True
    - unless: test -f /usr/sbin/batctl
{% endif %}

{% if grains['os'] == 'Ubuntu' and grains['osrelease'] == '16.04' %}
batman:
  pkg.installed:
    - sources:
      - batctl: http://ppa.launchpad.net/freifunk-mwu/freifunk-ppa/ubuntu/pool/main/b/batctl/batctl_2016.2-0ffmwu0~trusty_amd64.deb
      - batman-adv-dkms: http://ppa.launchpad.net/freifunk-mwu/freifunk-ppa/ubuntu/pool/main/b/batman-adv-kernelland/batman-adv-dkms_2016.2-0ffmwu0~trusty_all.deb
{% endif %}

# /etc/modules-load.d/salt_managed.conf
batman_adv:
  kmod.present:
    - name: batman_adv
    - persist: True

# sysfsutils: System Utilities Based on Sysfs

{% set sysfsutils = salt['grains.filter_by']({
  'Debian': {'pkg': 'sysfsutils'},
}, default='Debian') %}

{{ sysfsutils.pkg }}:
  pkg.installed:
    - name: {{ sysfsutils.pkg }}

/etc/sysfs.d/99-batman-hop-penalty.conf:
  file.managed:
    - name: /etc/sysfs.d/99-batman-hop-penalty.conf
    - contents: class/net/{{ pillar['network']['batman']['interface'] }}/mesh/hop_penalty = 60
    - require:
      - pkg: {{ sysfsutils.pkg }}