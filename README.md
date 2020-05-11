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
