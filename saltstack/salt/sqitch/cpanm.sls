cpanm-install-packages:
  pkg.installed:
    - install_recommends: False
    - names:
      - build-essential
      - libpq-dev

cpanm-install-dependencies:
  cmd.run:
    - name: cpanm DBD::Pg

cpanm-install-sqitch:
  cmd.run:
    - unless: which sqitch
    - name: cpanm -n App::Sqitch
