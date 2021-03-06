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
**terraform plan**
- применили изменения командой
**terraform apply -auto-approve**
- для проверки зашли по адресу
http://35.195.185.92:9292/

## Задание со звездой

- добавлены ключи в метаданные проекта через ресурсы
- проверили что должно получится командой
**terraform plan**\
- применили изменения командой
**terraform apply -auto-approve**


# Terraform-2

- Создан ресурс для файервола
```
resource "google_compute_firewall" "firewall_ssh" {
name = "default-allow-ssh"
network = "default"
allow {
protocol = "tcp"
ports = ["22"]
}
source_ranges = ["0.0.0.0/0"]
}
```
- После ошибки сделали импорт дефолтных правил
***terraform import google_compute_firewall.firewall_ssh default-allow-ssh***
- Создали ресурс со статическим адресом
```
resource "google_compute_address" "app_ip" {
name = "reddit-app-ip"
}
```
- Базу данных и приложение разбили на отделные VM.
- Создали отдельную конфигурацию для ресурсов фаервола.
- Создали модули.
- Ввели для моделуй параметры из переменных.
- Проверили, что на ресурсы можно подключаться только с заданного хоста.
- Создали две инфраструктуры stage и prod посредством переиспользования модулей.
- Параметризовали эти инфраструктуры.
- Используя реестр модулей создали два бакета
```
provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"

  # Имена поменяйте на другие
  name = ["storage-bucket-product", "storage-bucket-stages"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
```
- Уничтожили все поделки.

# Ansible-1 task
- Создали ветку и необходимые папки с файлами
- Установили pip
***pip install -r requirements.txt***
- Подняли инфраструктуру stage:
```
app_external_ip = 35.187.12.34
db_external_ip = 35.195.232.23
```
- Создали файл inventory и проверили доступность хостов командой
***ansible appserver -i ./inventory -m ping***
```
appserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
***ansible dbserver -i ./inventory -m ping***
```
dbserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
- Создали конфигурацию ansible и проверили хосты:
***ansible dbserver -m command -a uptime***
```dbserver | CHANGED | rc=0 >>
 19:40:10 up 29 min,  1 user,  load average: 0.06, 0.01, 0.00
```
***appserver -m command -a uptime***
```
appserver | CHANGED | rc=0 >>
 19:40:18 up 29 min,  1 user,  load average: 0.00, 0.00, 0.00
```
- Создали группы хостов.
- Создали inventory.yml и проверили доступность хостов:
***ansible all -i inventory.yml -m ping***
```
dbserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}***

appserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
- Создали плейбук и запустили:
***ansible-playbook clone.yml***
- Удалили клон
***ansible app -i inventory.yml -m shell -a "rm -dfr ~/reddit"***
- Выполнили плейбук ещё раз. Состояние поменялось, т.к. репозитория не было.
```
appserver                  : ok=2    changed=1    unreachable=0    failed=0
```

# Расширенные возможности  Ansible
## Настройка инстанса ДБ
- Создали плейбук reddit_app.
- Создали шаблон mongod.conf.j2 в папке templates.
- Определили переменную mongo_bind_ip: 0.0.0.0
- Сделали пробный прогон командой.
***ansible-playbook reddit_app.yml --check --limit db***
- Добавили handler для перезапуска moglod.
## Настройка инстанса приложения
- Добавили unit file  для сервиса puma.
- Добавили handler для перезапуска сервиса puma.
- Добавили шаблон и переменную для сервиса puma.
- Добавили внутренний адрес ДБ в output Terraform
- Сделали пробный прогон и применили плейбук:
***ansible-playbook reddit_app.yml --limit app --tags app-tag***
```
PLAY [Configure hosts & deploy application] ****************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Add unit file for Puma] ******************************************************************************************************************************************************************************
changed: [appserver]

TASK [Add config for DB connection] ************************************************************************************************************************************************************************
changed: [appserver]

TASK [enable puma] *****************************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] ******************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=5    changed=4    unreachable=0    failed=0
```
## Deploy
- Добавили такси для деплоя свежего приложения
- Сделали тестовый прогон и раскатали таски с тегом деплоя:
***ansible-playbook reddit_app.yml --limit app --tags deploy-tag***
```
PLAY [Configure hosts & deploy application] ****************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ********************************************************************************************************************************************************
ok: [appserver]

TASK [Bundle install] **************************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=3    changed=1    unreachable=0    failed=0
```
- Проверили работу приложения, перейдя по ссылке и создав пост:
http://35.187.12.34:9292/

## Один плейбук, несколько сценариев.
- Создали сценарии отдельно для приложения и дб.
- Пересоздали окружение ***stage*** командами:
***terraform destroy
terraform apply -auto-approve=false***
- Актуализировали ip адреса хостов.
- Проверили и раскатали плей для дб:
***ansible-playbook reddit_app2.yml --tags db-tag***
```
PLAY [Configure MongoDB] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [dbserver]

TASK [Change mongo config file] ****************************************************************************************************************************************************************************
changed: [dbserver]

RUNNING HANDLER [restart mongod] ***************************************************************************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=1    changed=0    unreachable=0    failed=0
dbserver                   : ok=3    changed=2    unreachable=0    failed=0
```
- То же для приложения:
***ansible-playbook reddit_app2.yml --tags app-tag***
```
PLAY [Configure MongoDB] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [dbserver]

PLAY [Configure App] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Add unit file for Puma] ******************************************************************************************************************************************************************************
changed: [appserver]

TASK [Add config for DB connection] ************************************************************************************************************************************************************************
changed: [appserver]

TASK [enable puma] *****************************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] ******************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=5    changed=4    unreachable=0    failed=0
dbserver                   : ok=1    changed=0    unreachable=0    failed=0
```
- То же для деплоя.
- Проверили работоспособность по ссылке:
http://104.199.54.253:9292/

## Нескольо плейбуков
- Разбили приложение, дб и деплой по разным файлам.
- Создали общий файл site.yml.
- Пересоздали окружение ***stage*** командами:
***terraform destroy
terraform apply -auto-approve=false***
- Актуализировали ip адреса хостов.
- Проверили и раскатали плейбуки:
***ansible-playbook site.yml***
```
PLAY [Configure MongoDB] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [dbserver]

TASK [Change mongo config file] ****************************************************************************************************************************************************************************
changed: [dbserver]

RUNNING HANDLER [restart mongod] ***************************************************************************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Add unit file for Puma] ******************************************************************************************************************************************************************************
changed: [appserver]

TASK [Add config for DB connection] ************************************************************************************************************************************************************************
changed: [appserver]

TASK [enable puma] *****************************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] ******************************************************************************************************************************************************************************
changed: [appserver]

PLAY [Deploy App] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ********************************************************************************************************************************************************
changed: [appserver]

TASK [bundle install] **************************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [restart puma] *****************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=9    changed=7    unreachable=0    failed=0
dbserver                   : ok=3    changed=2    unreachable=0    failed=0
```
- Проверили работоспособность по ссылке:
http://35.187.12.34:9292/
## Провижининг в Packer
- Создали packer_app.yml для установки окружения ruby.
- Создали packer_db.yml для установки окружения mongod.
- Create images by:
***packer build -var-file packer/variables.json packer/app.json***
***packer build -var-file packer/variables.json packer/db.json***
- Recreate stage by:
***terraform destroy***
***terraform apply -auto-approve***
-

# Ansible-3 Роли, окружения и лучшие практики
- Создали папки с ролями для апп и дб.
***mkdir roles; cd roles***4
***ansible-galaxy init app***
***ansible-galaxy init db***
- Подготовили конфиги для апп и дб.
- Пересоздали stage.
- Обновили айпишники
- Проверили работу:
***http://35.195.101.219:9292/***
## Окружения
- Создали окружения стадж и прод стадж определили как дефолтное.
- Определили переменные для окружений
- Привели структуру к бестпрактис
- Проверили конфиги пакера и исправили пути к плейбукам)
- Пересоздали окружение stage
- Актуализировали айпишники
- Проверили доступность сервиса:
http://104.155.85.92:9292/

## Работа с Community-ролями
- Add jdauphant.nginx and make config
- Add vpc rule for tcp/80 for app
- Add role jdauphant.nginx
- Apply playbook
- Проверили приложение по порту 80:
http://104.155.85.92/

## Работа с Ansible Vault
- Создали конфиги для шифрования данных
- Зашивровали файлы
- Проверили а запустили плейбук


# Разработка и тестирование Ansible ролей и плейбуков

## Локальная разработка с Vagrant
- Install virtualbox, vagrant.
- Form Vagrantfile from gist
- create vmachines by
`vagrant up`
- Check accessible each machines.
`vagrant ssh (app|db)server`

### Доработка ролей. Провижининг.
- Add python install as base.yml playbook
- Divide tasks by files.
- Run provision and test connection:
```
vagrant@appserver:~$ telnet 10.10.10.10 27017
Trying 10.10.10.10...
Connected to 10.10.10.10.
Escape character is '^]'.
^]
telnet> quit
Connection closed.
```
- Do the same with app.
- Parametries app and add extra vars to Vagrantfile
- Check if app working.
http://10.10.10.20:9292
- Recreate project and check app.
`vagrant destroy -f`
`vagrant up`
http://10.10.10.20:9292

## Тестирование ролей
- Install virtuelenv

```
pip install --user pipenv
PATH=$(python -m site --user-base)/bin:$PATH
cd /home/andrew/work/OTUS-201902-git/der-andrew_infra
pipenv install requests
virtualenv venv
source venv/bin/activate
pip install virtualenvwrapper
source $(command -v virtualenvwrapper.sh)
```
- Activate virtenv.

`source ../venv/bin/activate`
- Install requirements. 
`pip install -r requirements.txt`

### Тестирование db роли
- Initialise molecule:
`cd ansible/roles/db`
`molecule init scenario --scenario-name default -r db -d vagrant`
- Create Vmachine for tests:
`cd ansible/roles/db`
`molecule create`
- Instances list:
```
ansible/roles/db$ molecule list
--> Validating schema /home/andrew/work/OTUS-201902-git/der-andrew_infra/ansible/roles/db/molecule/default/molecule.yml.
Validation completed successfully.
Instance Name    Driver Name    Provisioner Name    Scenario Name    Created    Converged
---------------  -------------  ------------------  ---------------  ---------  -----------
instance         vagrant        ansible             default          true       false
```
- Apply molecule playbook
`molecule converge`
- Go tests!
`molecule verify`
- Add to test mongo port
```
# check if port tcp/27017 is listening
def test_mongo_port_listening(host):
    mongo_port = host.socket("tcp://0.0.0.0:27017")
    assert mongo_port.is_listening
```
- Got tests!
`molecule verify`
