common-profile-append:
  file.append:
    - name: /home/vagrant/.bash_profile
    - source: salt://common/files/bash_profile
    - defaults:
        folder: /home/vagrant
