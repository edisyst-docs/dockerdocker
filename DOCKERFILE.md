# Dockerfile
- https://linuxhub.it/articles/howto-creare-un-Dockerfile/
- https://docs.docker.com/reference/dockerfile/#from
- https://github.com/mcicolella/docker-examples


```bash
FROM <nome-immagine> # specifica l’immagine di partenza (viene prima verificato se si trova nei repo locali altrimenti la scarica dal Dockerhub)

RUN <comando> # esegue uno o più comandi prima della creazione del container

ADD <file/dir> <path>  # copia un file dell’host (o un file remoto, tramite URL) in una cartella del container.

COPY <file/dir> <path> # copia un file dell’host in una cartella del container

CMD ["<comando>", "<param1>","<param2>", ...] # specifica uno o più comandi da eseguire (si mettono fra "doppi apici"). Può esserci un solo CMD

WORKDIR <path> # specifica la directory nel quale i comandi settati su CMD devono essere eseguiti (sennò li esegue nella `root`)
```

### Nota:
La differenza tra ADD e COPY è che il primo ha funzionalità maggiori tra cui il poter copiare file remoti all’interno del container tramite URL oppure estrarre un file compresso all’interno del container mentre COPY copia solo i file locali dall’host al container. COPY è stato introdotto per problemi di funzionalità del comando ADD che per via delle sue troppe funzionalità può avere comportamenti inaspettati quando si cerca di copiare un file su un container.


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

