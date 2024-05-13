# INTRO - comunicazione tra container
**ESERCIZI**: https://labs.play-with-docker.com/
- Al posto di `CTR+C` e `CTRL+V` (che non fungono in quel sito) bisogna usare `CTRL+INS` e `SHIFT+INS`

```bash
docker network ls # elenco reti disponibili
```
- La rete `host`di solito non si usa, permette al container di condividere l'IP dell'host. 
- Di default la rete di ogni container è la `bridge`. IP di container e host sono differenti

```bash
docker run --name bridge_cont -it alpine sh #`CTRL+P+Q` per lasciare in esecuzione
docker run --name host_cont --network host -it alpine sh # `CTRL+P+Q` per lasciare in esecuzione
docker ps

docker network inspect host   # c'è host_cont   tra i container connessi a questa rete
docker network inspect bridge # c'è bridge_cont tra i container connessi a questa rete
docker inspect host_cont      # mi guardo le info dentro "Network" - IP=NULL perchè in realtà è lo stesso IP dell'host
```


# MODALITA' BRIDGE - comunicazione tra container
- Di default i container eseguiti senza specificare la rete vengono eseguiti nella rete `bridge` (ottengono un IP su essa)
- I container possono comunicare in questa rete isolata. Potrei creare una web-app formata da un web-server e un DB

```bash
docker run -it --name contA ubuntu bash

# dentro ci installo ifconfig e ping
apt-get update
apt-get install net-tools    # dovrò usare ifconfig
apt-get install iputils-ping # dovrò usare anche ping
ifconfig # mi segno l'IP => 172.17.0.2
```
`CTRL+P` e `CTRL+Q` (esco lasciando in esecuzione)

```bash
docker ps
docker run -it --name contB ubuntu bash

# dentro ci installo ifconfig
apt-get update
apt-get install net-tools    # dovrò usare ifconfig
apt-get install iputils-ping # dovrò usare anche ping
ifconfig # mi segno l'IP => 172.17.0.3
```
`CTRL+P` e `CTRL+Q` (esco lasciando in esecuzione)

Ora esamino la `rete del mio docker`
```bash
docker inspect network bridge # la eth0 si chiama così sull'host
# se cerco "Subnet" trovo l'insieme degli IP
# se cerco "Containers" trovo i 2 container coi loro IP
```

Ora entro nel container `contA` e provo a pingare `contB`
```bash
docker exec -it contA bash

ifconfig
ping 172.17.0.2
```


# MODALITA' BRIDGE - meccanismo di NAT
- https://www.youtube.com/watch?v=hKrXUYTs00E&list=PLS-6DsYHk7Ndcqj-BpBO9ydW2I8awPajb&index=19
- Meccanismo fornito dall'host. Consente di navigare verso l'esterno (Internet)
```bash
docker run -it --name cont01 ubuntu bash
apt-get update
apt-get install iputils-ping # serve solo ping
ping 8.8.8.8 # posso pingare Google (lo lascio in esecuzione)
```
`CTRL+P` e `CTRL+Q` (esco lasciando in esecuzione)

- Questo perchè l'host ci stà fornendo un meccanismo di NAT. 
- Stà convertendo l'IP privato del container attraverso la sua interfaccia 
- (IP privato del host, che poi si converte in IP pubblico del host)

Con `Putty` o `Powershell` mi duplico la sessione (devo usare lo stesso container)
```bash
docker run -it --name cont01 ubuntu bash

apt-get install tcpdump
tcpdump -n host 8.8.8.8 # mi dice che il 172.17.0.2 stà facendo richiesta di DNS a 8.8.8.8

apt-get install curl
curl ifconfig.me/ip # mi restituisce l'IP pubblico => 79.35.83.194
```



# Mapping porte - esposizione verso l'esterno delle porte
Faccio un esempio con un WS Nginx già visto
```bash
docker run -d --name webserver1 -p 8082:80 nginx # fa il mapping delle porte (host:container)
docker port webserver1
wget 127.0.0.1:8082 # mi dà un 200, mi accetta la connessione
wget 127.0.0.1 # di default la porta è 80, che da me è Laragon
curl 127.0.0.1:8082 # mi restituisce l'HTML della home di nginx. Su Powershell lo fa già il comando wget
```



# Docker swarm - container management tool (orchestration)
- Docker swarm è l'orchestratore di `nodi` e `cluster`
- Ogni `nodo` è un'istanza del `Docker Engine` (può essere una macchina fisica o VM)
- Un `cluster` è un insieme/collection di `nodi connessi fra loro`
- Con lo `Swarm Orchestrator` (Docker swarm) posso gestire più `service` (sono container) dal nodo `manager` sui nodi `worker`
- Permette scaling, bilanciamento del carico, mantenimento dello stato delle applicazioni
- Non lo posso provare se non ho vari nodi, varie VM con all'interno Docker Engine installato
- Docker Swarm Visualization: cercare il repo su Github, mostra solo una visualizzazione grafica, niente di più

**Esempio**: 
ho un sito formato da FE e BE, ho studiato il traffico 
e so che mi servono N container per gestire il traffico di FE e altri M container per il traffico in BE. 
Se uno dei container di FE si stoppa non posso più gestire il traffico, 
perciò mi serve uno strumento che me ne ricrei automaticamente (manualmente non posso farlo) un altro per gestire il traffico. 
L'orchestratore monitora lo stato delle app FE e BE, sa che servono N+M container e me li mantiene attivi
```bash
docker swarm init --advertise-addr 192.168.0.18 # nodo manager - metto il mio IP
docker swarm join-token manager  # nodo manager - restituisce il comando da far lanciare a un nuovo manager 
docker swarm join-token worker   # nodo manager - restituisce il comando da far lanciare a un nuovo worker 

docker swarm join --token sldjkfwe89ourh43956   # nodo worker

docker node ls # nodo manager
docker network ls # nodo manager: di default esiste già una rete con scope=swarm, ma posso crearne un'altra
docker network create -d overlay overnet # nodo manager: creo un'altra rete per esercizio, ereditata anche dal nodo worker
docker network inspect overnet

docker service create --name mioservizio --network overnet --replicas 10 alpine sleep 10h # crea un servizio in quella rete
docker service ls
```


# Docker service
- Solo il nodo manager può creare servizi. Man mano che li crea li distribuisce tra i vari nodi
- Il nodo manager decide quale nodo worker esegue il dato service (in base alla salute del nodo)
- Se non specificato diversamente, il nodo manager può fare anche da worker all'occorrenza
- Non vado nel nodo worker specifico ad avviare il servizio, faccio tutto dal nodo manager in automatico
```bash
docker service create --name primo nginx:latest   # nodo manager
docker ps # nodo manager - è in esecuzione qui
docker service create --name secondo nginx:latest # nodo manager
docker ps # nodo manager - non è in esecuzione qui
docker ps # nodo worker  - doverbbe essere in esecuzione qui
```
Posso andare avanti creando servizi: il nodo manager dovrebbe distribuirli automaticamente tra i vari nodi disponibili

```bash
docker service create --name serviceone nginx:latest # crea un container che se stoppo viene subito reistanziato
docker service create --name serviceone --replicas=3 nginx # posso indicare quante repliche del service
docker service inspect --pretty serviceone

docker service ls # me lo lista, è in esecuzione
docker service ps serviceone # quali nodi stanno eseguendo il service (docker-desktop sul mio locale, ho solo quello)
docker ps # sul nodo che stà eseguendo serviceone, verrà listato (se ho solo docker-desktop non posso sperimentarlo)

docker service rm serviceone
```
Se digitato dal nodo manager `docker service ps serviceone` mi indica i nodi worker che lo stanno eseguendo
```bash
docker service scale serviceone=5 # posso scalare in un secondo momento
docker service scale <SERVICE>=<REPLICAS> # la sintassi è questa
```
Supponiamo di avere un servizio al quale deve essere fatto un upgrade (es: nginx:1.24 >> 1.25)
```bash
docker service create --name demo_upgrade nginx:1.24.0
docker service ls # ha la versione 1.24.0
docker service update --image nginx:1.25.1 demo_upgrade
docker service ls # ora ha la versione 1.25.1
docker inspect demo_upgrade # UpdatedAt ha il timestamp di adesso
```



# Esercizio - Jenkins - Docker Swarm
- https://www.youtube.com/watch?v=SPVJuNS2Bi4&t=100s
- https://labs.play-with-docker.com/
```bash
docker pull jenkins/jenkins:lts # forse mi funge solo la latest
docker run -d --name mio-jenk -p 8001:8080 -p 50001:50000 jenkins/jenkins:lts
docker ps

docker exec mio-jenk bash cat /var/jenkins_home/secrets/initialAdminPassword #mi stampa la password di Jenkins
```
Se apro la mia porta `8001` posso installare Jenkins inserendo la password. Non serve farlo

```bash
docker swarm
docker swarm init # non funge, manca un dato
docker swarm init --advertise-addr 192.168.0.18 # inserisco il mio IP - sarò il nodo manager
```

L'ultimo comando mi restituisce anche il comando da inserire nei nodi che devono diventare worker:
```bash
docker swarm join --token SWMTKN-1-14hnvjntwaby5x65nczrtld7rdt70csuuw41zvkqwpr30jmhfi-5n914hk5ofhxdi83axvfv1qwo 192.168.0.18:2377
```

Nel nodo manager:
```bash
docker node ls
docker service ls # per ora è vuoto
docker network ls
docker inspect ingress # è la rete usata per lo swarm
docker inspect node2 # posso visionare i nodi

docker service create -d --name serv-jenk -p 8003:8080 jenkins/jenkins # per ora lo creo con una sola replica
docker service ls
docker service ps serv-jenk # 1 replica
docker service update serv-jenk --replicas 5
docker service ls
docker service ps serv-jenk # 5 repliche
```
Ora tutti i nodi possono collegarsi allo stesso Jenkins dalla stessa porta `8003`. Posso installare Jenkins (serve la password)e usarlo con tutti













