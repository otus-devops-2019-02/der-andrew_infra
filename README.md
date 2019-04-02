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
      "project_id": "{{user `var_project_id`}}",
      "image_name": "reddit-base-{{timestamp}}",
      "image_family": "reddit-base",
      "source_image_family": "{{user `var_source_image_family`}}",
      "zone": "europe-west1-d",
      "ssh_username": "appuser",
      "machine_type": "{{user `var_machine_type`}}"
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
- Создан файл с описанием переменных **variables.json**
```
{
 "var_project_id": "infra-451193",
 "var_source_image_family": "ubuntu-1604-lts",
 "var_machine_type": "f1-micro"
}
```
- Проведена проверка на ошибки. Команда:
-- **packer validate -var-file variables.json ./ubuntu16.json**
- Запущен build  образа. Команда:
-- **packer build -var-file variables.json ubuntu16.json**
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
(http://35.195.185.92:9292)

## Задача со звездой

- Создан шаблон для immutable  инфраструктуры.
```
{
  "variables": {
    "var_image_family": "reddit-full",
    "var_source_image_family": "reddit-base",
    "var_source_image": "reddit-base-1553971626"
  },
"builders": [
    {
      "type": "googlecompute",
      "project_id": "{{user `var_project_id`}}",
      "image_name": "{{user `var_image_family`}}-{{timestamp}}",
      "image_family": "{{user `var_image_family`}}",
      "source_image_family": "{{user `var_source_image_family`}}",
      "source_image": "{{user `var_source_image`}}",
      "zone": "europe-west1-d",
      "ssh_username": "appuser",
      "machine_type": "{{user `var_machine_type`}}",
      "image_description": "Puma Application",
      "disk_type": "pd-standard",
      "disk_size": "11",
      "network": "default",
      "labels": {
        "image_family": "redditfull",
        "inst_type": "pumaapp"
        },
      "tags": [
        "tredditfull",
        "tpumaapp"
      ],
      "on_host_maintenance": "MIGRATE",
      "preemptible": "false"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "script": "scripts/deploy.sh",
      "execute_command": "sudo {{.Path}}"
    }
  ]
}
```
- Проведена проверка на ошибки. Команда:
-- **packer validate -var-file variables.json immutable.json**
- Запущен build  образа. Команда:
-- **packer build -var-file variables.json immutable.json**
- Создана виртуальная машина из кастомного образа. Для этого создан скрипт **create-reddit-vm.sh**
```
#!/bin/bash
set -e

echo "---=== Creating reddit VM... ===---"
gcloud compute --project=infra-451193 instances create reddit-app-full \
--zone=europe-west1-d --machine-type=g1-small \
--subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE \
--service-account=735155033088-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/trace.append \
--tags=puma-server --image=reddit-full-1553980024 --image-project=infra-451193 \
--boot-disk-size=11GB --boot-disk-type=pd-standard --boot-disk-device-name=reddit-app-full
```
- После создания машины, подключились по ссылке:
-- http://35.233.97.151:9292

## Terraform  instances

- удалили ssh ключ.
- установили terraform.
- в .gitignore поместили
```
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```
- подключили провайдера google и инициализировали terraform командой
**terraform init**
- описали ресурсы для создания в GCP.
- параметризовали ресурсы
- настроили вывод переменных (out vars)
- настроили провизионеров с параметрами
- проверили что должно получится командой
**terraform plan**\
- применили изменения командой
**terraform apply -auto-approve**
- для проверки зашли по адресу
http://35.195.185.92:9292/

## Задание со звездой

- добавлены коючи в метаданные проекта через ресурсы
- проверили что должно получится командой
**terraform plan**\
- применили изменения командой
**terraform apply -auto-approve**
