<details>
    <summary>ДЗ-6: PV/PVC</summary>

* Задеплоен `minio` c headless-сервисом
* Логопасс упрятаны в сикреты

</details>

<details>
    <summary>ДЗ-5: Networks</summary>

* Добавили readinessProbe 80/tcp - получили болт, ведь сервис слушает на 8000, а не на 80
* Добавили livenessProbe 8000/tcp
* Вопрос для самопроверки: описанная конфигурация не имеет смысла в случае, если процесс в контейнере - единственный. Если процесс упадёт, то контейнер точно упадёт. Если процесс зависнет, то проба всё равно скажет, что всё хорошо. Если процесс веб-сервиса в контейнере - не единственный, и если его зависание - нормальная ситуация, то проба сойдёт, но такую ситуацию сложно смоделировать
* Сделали манифест для деплоймента, а не просто для пода. Поды не переходят в ready - ведь проба не исправлена
* Поменяли порт на 8000 и сделали три реплики - работает. Кондишны выполнились
* Добавили уже знакомую нам стратегию `RollingUpdate`
* Установили `kubespy`, чтобы трейсить деплойменты
* `maxUnavailable: 0, maxSurge: 100%`: новые поды создаются вдобавок к старым, затем старые удаляются, так что не бывает недоступных подов меньше заданного количества реплик
* `maxUnavailable: 0, maxSurge: 0%`: кубер не даст так сделать, потому что либо какие-то поды будут недоступны, либо придётся создавать новые поды сверх желаемого количества реплик
* `maxUnavailable: 100%, maxSurge: 0%`: старые поды удаляются, при этом мы не заботимся о количестве доступных подов, а только о том, чтобы общее количество подов не было больше заданного количества реплик
* `maxUnavailable: 100%, maxSurge: 100%`: не экономим поды и не паримся о доступности, самый быстрый способ
* Создали сервис типа `ClusterIP`
* Убедились, что кубер реализует это через `iptables`
* Переключились на `ipvs`, но мусор в правилах остался
* Почистили мусор, восстановившись из псевдобэкапа `iptables`
* Хитрым способом через контейнер `toolbox` поглядели конфигурацию `ipvsadm`
* Убедились, что теперь есть виртуальный интерфейс с нашим ClusterIP
* Установили `MetalLB` (манифест из презы нихьт арбайтен, ругается на `PodSecurityPolicy`, взял из мастер-ветки `metallb/metallb`)
* Увидели, что под `speaker` говорит нам: `Error: secret "memberlist" not found`
* Добавили сикрет: `kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"`
* Задеплоили `ConfigMap` для нашего нового балансёра
* Переделали `ClusterIP` на `LoadBalancer`. В логах увидели, как выделился новый IP для нашего сервиса:

```json
{"caller":"service.go:114","event":"ipAllocated","ip":"172.17.255.1","msg":"IP address assigned by controller","service":"default/web-svc-lb","ts":"2020-05-12T20:16:03.377441199Z"}
```

* Добавили статический маршрут на рабочий ноутбук `route add 172.17.255.0/24  172.29.113.81 -p`, и у нас стал открываться наш мини-сайт в браузере
* Убедились, что работает Round Robin: `curl http://172.17.255.1/ | findstr HOSTNAME` несколько раз
* Сделали балансировщик для DNS и проверили: `nslookup web-svc-lb.default.svc.cluster.local 172.17.255.2`
* Задеплоили `ingress-nginx` (ссылка в презе тухлая, использовал вот эту: <https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml>)
* Создали LoadBalancer для ингресса (из манифеста нужно убрать селектор по метке `app.kubernetes.io/part-of: ingress-nginx`, потому что в `ingress-nginx-controller` нет такой метки)
* Курланули и получили 404
* Подключили `web-svc` к ингрессу с помощью соответствующего ресурса и убрали `ClusterIP`, ведь ингресс получает узлы из эндпойнтов
* Ура, приложение курлится
* Катнули дашборд отсюда: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml` (он может быть уже существует у нас в кластере, надо сперва удалить)
* И забалансили его через ингресс

Всё!

</details>

<details>
    <summary>ДЗ-4: RBAC</summary>

* Сделали аккаунт `bob` с правами кластер-админа
* Чекнули привилегии `kubectl auth can-i create pods --as=system:serviceaccount:default:bob`
* Сделали аккаунт `dave` вообще без прав
* Сделали неймспейс `prometheus`, аккаунт `carol` в нём и дали всем SA из этого неймспейса право читать поды
* Сделали неймспейс `dev`, создали роли `admin` и `view`, дали их аккаунтам `jane` и `ken`

</details>

<details>
    <summary>ДЗ-3: Pods and Deployments</summary>

* Не запустилось с более 1 control plane нод. Есть [ишью](https://github.com/kubernetes-sigs/kind/issues/1555). КМК не хватает производительности по диску, т.к. в момент поднятия кластера дико растёт очередь записи на диск.
* `kubectl describe pod frontend` для диагностики, почему не взлетает
* `kubectl scale replicaset frontend --replicas=3`: отмасштабировали на 3 реплики
* Убили поды и проверили, что они восстановились
* `kubectl get rs frontend`: убедились, что контроллер создал нужное количество реплик
* Применили повторно манифест, и он создал снова одну реплику
* Изменили значение аттрибута `replicas: 3`, и реплик стало снова 3
* Дали имейджу новый тэг `docker tag evgeniyberendyaev/frontend evgeniyberendyaev/frontend:v0.0.2` и запушили
* Передеплоили, используя новый тэг. А ничего не изменилось
* `kubectl get replicaset frontend -o=jsonpath='{.spec.template.spec.containers[0].image}'` и
* `kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'` показывают разные имейджи
* ...потому что ReplicaSet и не предназначен для отслеживания изменений шаблона (не умеет обновлять поды), а только лишь масштабирует поды by design. Чтобы было и то и другое, нужен Deployment-контроллер
* Соответственно, если **И** поменять образ, **И** увеличить количество реплик, ReplicaSet-контроллер просто добавит ещё один под **НОВОЙ** версии
* Забилдили новый имейдж `docker build -t evgeniyberendyaev/paymentservice .`
* Дали два разных тэга и запушили под ними
* Написали манифест для `paymentservice` и задеплоили его для проверки, что он валиден
* Переделали `ReplicaSet` в `Deployment`
* Убедились, что теперь у нас создан деплоймент и реплика сет для него
* Обновили образ в шаблоне и насладились передеплоем
* И теперь у нас два реплика сета - один пустой, другой с новым образом
* Проверили, что всё действительно деплойнулось с нового образа
* Посмотрели историю роллаутов `kubectl rollout history deployment paymentservice`
* Откатили версию на 0.0.1. Теперь поды отправлены обратно в старый реплика сет
* С помощью стратегии `rollingUpdate` сделали имитацию Reverse Rolling Update - `maxSurge: 1` и `maxUnavailable: 1`
* С помощью стратегии `rollingUpdate` сделали имитацию Blue-Green Deployment - `maxSurge: 3` и `maxUnavailable: 0`
* Создали Deployment и для `frontend`
* Задеплоили с пробой готовности
* Изменили версию образа, сознательно испортили probe URL и увидели, что новая версия не деплоится - Deployment не даёт удалять старое, пока не заработает новое
* Посмотрели, как можно устроить проверку на успешность такого деплоймента (и использовать в CI/CD): `kubectl rollout status deployment/frontend --timeout=60s` - при провале завершится с ошибкой
* Написали простой манифест для DaemonSet `node-exporter` (не заморачиваясь с пробросом хостовых ресурсов внутрь контейнеров)
* Убедились, что при форвардинге 9100 порта метрики курлятся
* Путём добавления `tolerations` добились, чтоб `node-exporter` деплоился и на мастер-ноды

Всё!

</details>

<details>
    <summary>ДЗ-2: Знакомство с Kubernetes</summary>

### Почему системные поды не падают

1. kube-apiserver is a static pod. That means it is controlled directly by kubectl.
2. core-dns is controlled by Deployment, which tracks it's state.
3. kube-proxy is controlled by DaemonSet, which ensures that each node has a copy of a pod.

### Почему падает frontend-под

Because environment variables were not set. We should define at least these:
```yaml
    env:
    - name: PRODUCT_CATALOG_SERVICE_ADDR
    value: "productcatalogservice:3550"
    - name: CURRENCY_SERVICE_ADDR
    value: "currencyservice:7000"
    - name: CART_SERVICE_ADDR
    value: "cartservice:7070"
    - name: RECOMMENDATION_SERVICE_ADDR
    value: "recommendationservice:8080"
    - name: SHIPPING_SERVICE_ADDR
    value: "shippingservice:50051"
    - name: CHECKOUT_SERVICE_ADDR
    value: "checkoutservice:5050"
    - name: AD_SERVICE_ADDR
    value: "adservice:9555"
```
</details>
