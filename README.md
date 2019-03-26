# der-andrew_infra
der-andrew Infra repository

[asterisc]
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

```
bastion_IP = 35.233.10.136
someinternalhost_IP = 10.132.0.6
```

В данном ДЗ мы:
Установим и настроим gcloud для работы с нашим аккаунтом;
Создадим хост с помощью gcloud;
Установим на нем ruby для работы приложения;
Установим MongoDB и запустим;
Задеплоим тестовое приложение, запустим и проверим его
работу.

testapp_IP = 35.195.185.92
testapp_port = 9292
