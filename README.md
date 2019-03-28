# der-andrew_infra
der-andrew Infra repository

asterisc
Исследовать способ подключения к someinternalhost в одну команду
из вашего рабочего устройства, проверить работоспособность найденного решения и внести его в
README.md в вашем репозитории.

1. Method one.
ssh -i ~/.ssh/GCP-appuser -t appuser@35.233.10.136 -A ssh appuser@10.132.0.6
2. Method two.
ssh -J appuser@35.233.10.136 appuser@10.132.0.6
В обоих случаях агент должен работать с добавленным ключом ессесна

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

# Packer task
- Создана новая ветка packer-base.
- Установлен Packer для Linux.
- Созданы Application Default Credentials для API. Команда:
-- **gcloud auth application-default login**
- Создан  packer template
```
{                                                                                                                                                                                                           
  "builders": [                                                                                                                                                                                             
    {                                                                                                                                                                                                       
      "type": "googlecompute",                                                                                                                                                                              
      "project_id": "infra-451193",                                                                                                                                                                         
      "image_name": "reddit-base-{{timestamp}}",                                                                                                                                                            
      "image_family": "reddit-base",                                                                                                                                                                        
      "source_image_family": "ubuntu-1604-lts",                                                                                                                                                             
      "zone": "europe-west1-d",                                                                                                                                                                             
      "ssh_username": "appuser",                                                                                                                                                                            
      "machine_type": "f1-micro"                                                                                                                                                                            
    }                                                                                                                                                                                                       
  ],                                                                                                                                                                                                        
  "provisioners": [                                                                                                                                                                                         
    {                                                                                                                                                                                                       
      "type": "shell",                                                                                                                                                                                      
      "script": "scripts/install_ruby.sh",                                                                                                                                                                  
      "execute_command": "sudo {{.Path}}"                                                                                                                                                                   
    },                                                                                                                                                                                                      
    {                                                                                                                                                                                                       
      "type": "shell",                                                                                                                                                                                      
      "script": "scripts/install_mongodb.sh",                                                                                                                                                               
      "execute_command": "sudo {{.Path}}"                                                                                                                                                                   
    }                                                                                                                                                                                                       
  ]                                                                                                                                                                                                         
}                                                                                                                                                                                                           
```
- Проведена проверка на ошибки. Команда:
-- **packer validate ./ubuntu16.json**
- Запущен build  образа. Команда:
-- **packer build ubuntu16.json**
- Создана виртуальная машина из кастомного образа.
- Подключились командой
-- **ssh appuser@35.195.185.92**
- Задеплоили приложение. Команды:
```sh
#!/bin/bash

echo "---=== Application deploy in progress... ===---"
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit/
bundle install
puma -d
ps aux | egrep puma
```
- Добавили метку фаервола для разрешения tcp/9292
- Для проверки необходимо зайти по ссылке:
(http://http://35.195.185.92:9292)
