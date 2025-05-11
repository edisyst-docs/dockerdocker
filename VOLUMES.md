# VOLUMI: persistenza e condivisione
Creo un container ubuntu contenente una cartella /test mappata con un volume `volumeuno` di Docker
```bash
docker run -it --name container1 -v volumeuno:/test ubuntu bash
ls       # ha creato la cartella /test dentro il container
touch /test/primofile.txt
```
`CTRL+P` e `CTRL+Q` (esco lasciando in esecuzione)
```bash
docker ps        # container1 in esecuzione
docker volume ls # volumeuno è segnalato
```

Creo un secondo container ubuntu che condivide lo stesso volume `volumeuno` di Docker
```bash
docker run -it --name container2 -v volumeuno:/test2 ubuntu bash
ls # c'è già la cartella /test2 e c'è anche il file primofile.txt
touch /test/secondofile.txt
```
`CTRL+P` e `CTRL+Q` (esco lasciando in esecuzione)

```bash
docker ps                       # due container
docker volume ls                # sempre un volume (è condiviso tra i due container)
docker exec -it container1 bash # rientro nel container1 e se controllo, in /test ci son 2 file
```


# VOLUMI: condivisione con Jenkins
- https://hub.docker.com/_/jenkins
```bash
docker pull jenkins/jenkins:lts

:lts
# mi deve restituire la password di accesso per la config - f772b6836f15487d9f3c27e7089e14cc
```
Potrei fare inizialmente `docker volume create volumeTest` ma posso fare anche tutto in un'unica riga

- Su `localhost:8080` inserisco la password
- installo senza selezionare componmenti aggiuntivi
- anche l'user posso non farlo, seleziono "Continua come amministratore"
- alla fine creo un job jobProva senza selezionare niente

Non chiudo il browser, apro un nuovo cmd/powershell e digito
```bash
docker run -p 8081:8080 -p 50001:50000 --name jenkins2 -v volumeJenkins:/var/jenkins_home jenkins/jenkins:lts
# non mi deve restituire la password se ho scritto tutto correttamente perchè è lo stesso Jenkins, stessa password quindi
```
Su `localhost:8081` non mi chiede la config, faccio login con `Admin` - `password_restituita` e trovo lo stesso job di prima


# VOLUMI: Bind mount = mapping location fisica del nostro host
- Per la persistenza dei dati posso usare i `VOLUMI` oppure una `cartella fisica` del mio host/macchina
- In questi esempi uso una cartella fisica della mia macchina
```bash
pwd # sono dentro ubuntu o dentro C:\Users\Edoardo
mkdir cartellaTest # userò questa
ls

docker run -it --name container1 -v C:\Users\Edoardo\cartellaTest:/test ubuntu bash
# mappo la cartella creata con la cartella /test del container1 e dentro di esso faccio:
touch /test/uno.txt
ls /test # ho creato il file uno.txt dentro la cartella del container1
```
`CTRL+P` e `CTRL+Q` (esco lasciando in esecuzione)

```bash
docker ps
docker volume ls # c'è la mia cartella fisica usata come volume
ls cartellaTest

touch cartellaTest/due.txt     # creo un file dalla mia macchina - BASH
$null > .\cartellaTest\due.txt # creo un file dalla mia macchina - POWERSHELL
ls cartellaTest

docker exec -it container1 bash # rientro nel container1 e se controllo, in /test ci son 2 file
```


# Altri esempi
```bash
# Serve Microsoft SQL Server Management Studio, Laragon di default non ce l'ha
# Volendo posso fare un esempio simile con MySQL
docker run `
--name sql2022 `
-p 1433:1433 `
-v sqlvolume:/var/opt/mssql `
-e ACCEPT_EULA=Y -e SA_PASSWORD=a1234567890! `
-d --rm `
mcr.microsoft.com/mssql/server:2022-latest

docker volume ls
docker volume inspect sqlvolume
docker stop sql2022
```
L'opzione `--rm` alla fine distrugge il container automaticamente una volta stoppato

```bash
# Bind mount - posso far la prova con o senza la riga del volume per vedere cosa cambia
docker run `
--name ng `
-p 8080:80 `
-v C:\Users\Edoardo\cartellaTest:/usr/share/nginx/html `
-d --rm `
nginx:latest
```
- Se dentro cartellaTest creo un `index.html` e lo modifico, in tempo reale vedo le modifiche sul container
- Al posto di `C:\Users\Edoardo\cartellaTest` potrei metterci `$(pwd)` se lancio il comando da dentro quella cartella

