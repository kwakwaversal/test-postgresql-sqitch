cpanm-install-sqitch:
  cmd.run:
    - unless: which sqitch
    - name: cpanm -n App::Sqitch
