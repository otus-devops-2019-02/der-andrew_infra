# der-andrew_infra
der-andrew Infra repository

[*]
Исследовать способ подключения к someinternalhost в одну команду
из вашего рабочего устройства, проверить работоспособность найденного решения и внести его в
README.md в вашем репозитории.

1. Method one.
ssh -i ~/.ssh/GCP-appuser -t appuser@35.233.10.136 -A ssh appuser@10.132.0.6
2. Method two.
ssh -J appuser@35.233.10.136 appuser@10.132.0.6
В обоих случаях агент должен работать с добавленным ключом ессесна)

Добавляем алиас на понравившийся метод
alias ssh2someinthost='ssh -J appuser@35.233.10.136 appuser@10.132.0.6'

========================================================================

bastion_IP = 35.233.10.136 someinternalhost_IP = 10.132.0.6
