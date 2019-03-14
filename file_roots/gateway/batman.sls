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
#     - batctl: http://ppa.launchpad.net/freifunk-mwu/freifunk-ppa/ubuntu/pool/main/b/batctl/batctl_2017.0-0ffmwu0~trusty_amd64.deb
      - batctl: http://ppa.launchpad.net/freifunk-mwu/freifunk-ppa/ubuntu/pool/main/b/batctl/batctl_2017.1-0ffmwu0~trusty_amd64.deb
#     - batman-adv-dkms: http://ppa.launchpad.net/freifunk-mwu/freifunk-ppa/ubuntu/pool/main/b/batman-adv-kernelland/batman-adv-dkms_2017.0.1-0ffmwu0~trusty_all.deb
      - batman-adv-dkms: http://ppa.launchpad.net/freifunk-mwu/freifunk-ppa/ubuntu/pool/main/b/batman-adv-kernelland/batman-adv-dkms_2017.1-0ffmwu0~trusty_all.deb
{% endif %}

# /etc/modules-load.d/salt_managed.conf
batman_adv:
  kmod.present:
    - name: batman_adv
    - persist: True
