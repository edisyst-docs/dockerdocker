# Dockerfile
- https://linuxhub.it/articles/howto-creare-un-Dockerfile/
- https://docs.docker.com/reference/dockerfile/#from
- https://github.com/mcicolella/docker-examples

### Struttura base
```dockerfile
FROM <nome-immagine> 
# specifica l’immagine di partenza (viene prima verificato se si trova nei repo locali altrimenti la scarica dal Dockerhub)

WORKDIR <path> 
# specifica la directory nel quale i comandi settati su CMD devono essere eseguiti (sennò li esegue nella `root`)

COPY <file/dir> <path> 
# copia un file dell’host in una cartella del container. Un esempio classico è COPY . .

RUN <comando> 
# esegue dei comandi prima di creare il container (durante la build dell'immagine): tipicamente installazione di pacchetti

ADD <file/dir> <path>  
# copia un file dell’host (o un file remoto, tramite URL) in una cartella del container.

EXPOSE 4000 
# espone la porta 4000

CMD ["<comando>", "<param1>","<param2>", ...] 
# esegue dei comandi in fase di run container (si mettono fra "doppi apici"). Può esserci un solo CMD. 
# è anche il comando che viene eseguito di default se non ce ne sono altri 
# (es.: il classico /bin/bash per eseguire un container ubuntu)

ENTRYPOINT ["<comando>", "<param1>","<param2>", ...] 
# simile a CMD, solo che questo comando non si sovrascrive (a meno di non specificare docker run --entrypoint)
```

### Note:
- `ADD` rispetto a `COPY` ha funzionalità maggiori, tra cui il poter copiare file remoti all’interno del container tramite URL oppure estrarre un file compresso all’interno del container mentre `COPY` copia solo i file locali dall’host al container.
  - `COPY` è stato introdotto per problemi di funzionalità del comando `ADD` che per via delle sue troppe funzionalità può avere comportamenti inaspettati quando si cerca di copiare un file su un container.
- `RUN` si può mettere anche più volte, ma l'ideale è combinare tutti i RUN in un'unica riga, perchè ogni RUN genera un nuovo layer che appesantisce l'immagine
- `CMD` si usa per comandi che possono essere sostiutuiti a runtime; `ENTRYPOINT` per comandi che devono sempre essere eseguiti. 
  - Le due istruzioni possono anche essere combinate (vedi esempio) 

### Esempio
```dockerfile
ARG  CODE_VERSION=stable
FROM debian:${CODE_VERSION}
WORKDIR /src
COPY test.txt relativeDir/
COPY test.txt /absoluteDir/
RUN apt-get update && apt-get install -y --force-yes apache2
ADD git@git.example.com:foo/bar.git /bar
EXPOSE 80 443
VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]
ENTRYPOINT ["echo"]
CMD ["Stò eseguendo il container"]
```



# Crea immagine da un Dockerfile
```bash
docker build -t <nome-immagine> <path>
```

```bash
-t # per aggiungere un tag all’immagine
<nome-immagine> # il nome che vogliamo dare alla nostra immagine
<path> # è la directory nel quale si trova il Dockerfile
```

Poi con  `docker run <nome-immagine>` creiamo ed eseguiamo un container dell'immagine (anche qui specifichiamo tag e nome per comodità)


# Esercizio Python
```bash
docker pull python:3
docker pull node 
```

Creo nella stessa cartella del `Dockerfile` il file `app.py` e ci scrivo dentro `print('Hello, world')` 

Nel Dockerfile scrivo:
```bash
FROM python:3
COPY ./app.py /
CMD ["python", "./app.py"]
```
Da terminale:
```bash
docker build -t hello-python .
docker run hello-python
```


# Esercizio Python bis
Nel file `app.py` scrivo il codice per un webserver python
```bash
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"
```

Nel file `requirements.txt` scrivo le librerie utilizzate da python (in questo caso solo Flask):
```bash
Flask==2.0.0
```

Nel Dockerfile scrivo:
```bash
FROM python:3
RUN mkdir /webserver
WORKDIR /webserver
COPY requirements.txt /webserver/
RUN pip install -r requirements.txt
COPY ./app.py /webserver/
CMD ["flask", "run", "--host=0.0.0.0"]
```

```bash
FROM python:3 # Specifico di utilizzare l’immagine di python3
RUN mkdir /webserver # Esegue il comando mkdir che crea una sottocartella della root denominata webserver
WORKDIR /webserver # Sposta la directory di lavoro del container in /webserver
COPY ./requirements.txt /webserver/ # Copia il file requirements.txt nella cartella /webserver
RUN pip install -r requirements.txt # Esegue il comando pip install -r che crea installa tutte le librerie specificate nel requirements.txt
COPY ./app.py /webserver/ # Copia app.py dall’host e lo salva nella cartella /webserver del container
CMD ["flask", "run", "--host=0.0.0.0"] # Esegue il comando flask run --host=0.0.0.0 che esegue app.py e crea il webserver sul localhost (che in questo caso è il localhost del container 172.17.0.x)
```

Da terminale:
```bash
docker build -t flask-webserver 
docker run flask-webserver
```


# Esercizio Node JS Express JS
```bash
cd mio-node-api
npm init
npm install --save express
node index.js # se vado in localhost:3000 vedo la mia app

docker build -t mio-node-api:latest .
docker run --name node1 -d mio-node-api -p 3333:3000
docker run --name node1 -d -p 3333:3000 mio-node-api:latest

docker pull python:3
docker pull node 
```




