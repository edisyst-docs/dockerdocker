# Esecizio solo col Jenkinsfile
Qui l'idea sarebbe:
- Installa Jenkins su un VPS acquistato (io stò usando un Docker per gioco)
- Clona un mio repo da Github (contiene il Dockerfile)
- Crea l'immagine sul mio Docker Hub
- Deploya l'immagine sul VPS
- Crea il container sul VPS
- Se faccio modifiche in locale sul repo, le committo e con la pipeline mi ricreo il container aggiornato



# Esercizio con docker-compose multi-agente
```bash
# Build inizialmente solo del master
docker-compose up -d jenkins-master

# Recupero password iniziale
docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

# Visualizzare logs
docker-compose logs -f jenkins-master

# Fermare tutto
docker-compose down

# Riavviare
docker-compose restart
``` 

Setup dopo l'avvio:
1. Accedi a http://localhost:8080
2. Installa plugin manualmente:
   - Vai in "Manage Jenkins" → "Plugins" → "Available plugins"
   - Cerca e installa: Pipeline, Git, GitHub, Docker Pipeline
   - Riavvia Jenkins dopo l'installazione
3. Configura agenti:
   - Vai in "Manage Jenkins" → "Nodes" → "New Node"
   - Per ogni agente (agent1, agent2, agent3):
     - Nome: agent1, agent2, agent3
     - Tipo: Permanent Agent
     - Labels: agent1, agent2, agent3
     - Remote root directory: `/home/jenkins/agent`
     - Launch method: "Launch agent via execution of command on the master"
   - Dopo averlo creato, recuperare il `secret` e incollarlo nel `docker-compose.yml

```groovy
pipeline {
    agent none
    stages {
        stage('Build on Agent1') {
            agent { label 'agent1' }
            steps { 
                echo "Building on agent1"
                sh 'hostname'
            }
        }
        stage('Test on Agent2') {
            agent { label 'agent2' }
            steps { 
                echo "Testing on agent2"
                sh 'hostname'
            }
        }
        stage('Deploy on Agent3') {
            agent { label 'agent3' }
            steps { 
                echo "Deploying on agent3"
                sh 'hostname'
            }
        }
    }
}
```



# Esercizio con docker-compose (da scrivere ancora, vorrei fare un docker più complesso coi volumi condivisi)
```bash
# Build e avvio
docker-compose up -d --build

# Visualizzare logs
docker-compose logs -f

# Fermare tutto
docker-compose down

# Riavviare
docker-compose restart
``` 
### Configurazione iniziale
1. Accedi a http://localhost:8080
2. La password iniziale si trova in: jenkins_home/secrets/initialAdminPassword
3. Configura gli agenti dalla web UI (Manage Jenkins → Manage Nodes)



# Introduzione a Groovy per Jenkinsfile
Groovy è un linguaggio di scripting dinamico per la Java Virtual Machine (JVM) che combina 
caratteristiche di Python, Ruby e Smalltalk con una sintassi simile a Java. 
Jenkins utilizza Groovy per la definizione delle pipeline (Jenkinsfile).

1. Variabili e Tipi di Dato
```groovy
// Dichiarazione di variabili
def stringa = "Hello World"
def intero = 42
def decimale = 3.14
def booleano = true
def lista = [1, 2, 3, 4]
def mappa = [nome: "Mario", età: 30]

// Stringhe con interpolazione
def nome = "Edoardo"
def saluto = "Ciao, ${nome}!" // Risulta: "Ciao, Edoardo!"
```

2. Strutture di Controllo
```groovy
// Condizionale if-else
if (booleano) {
    println("È vero")
} else {
    println("È falso")
}

// Ciclo for
for (int i = 0; i < 5; i++) {
    println("Iterazione: ${i}")
}

// Ciclo each sulle liste
lista.each { elemento ->
    println("Elemento: ${elemento}")
}

// Ciclo each sulle mappe
mappa.each { chiave, valore ->
    println("${chiave}: ${valore}")
}
```

3. Metodi
```groovy
// Definizione di un metodo
def somma(a, b) {
    return a + b
}

// Metodo senza return esplicito (restituisce l'ultima espressione)
def saluta(nome) {
    "Ciao, ${nome}!"
}
```




# Jenkinsfile - Esempi Pratici


Esempio 1: Pipeline Semplice
```groovy
pipeline {
    agent any // Esegue su qualsiasi agent disponibile

    stages {
        stage('Build') {
            steps {
                echo 'Building the project...'
                sh "date '+%d-%m-%Y --- %H:%M:%S'" // Esegue comando shell
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh "date '+%d-%m-%Y --- %H:%M:%S'" // Esegue comando shell
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh "date '+%d-%m-%Y --- %H:%M:%S'" // Esegue comando shell
            }
        }
    }

    post {
        always {
            echo 'Pipeline completata'
        }
        success {
            echo 'Tutto ok!'
        }
        failure {
            echo 'Qualcosa è andato storto'
        }
    }
}
```


Esempio 2: Pipeline con Parametri
```groovy
pipeline {
    agent any

    parameters {
        string(name: 'VERSION', defaultValue: '1.0', description: 'Version to deploy')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'stage', 'prod'], description: 'Select environment')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests?')
    }

    stages {
        stage('Setup') {
            steps {
                echo "Deploying version ${params.VERSION} to ${params.ENVIRONMENT}"
                script {
                    // Blocco script per codice Groovy più complesso
                    if (params.ENVIRONMENT == 'prod') {
                        echo 'Attenzione: ambiente di produzione!'
                    }
                }
            }
        }

        stage('Test') {
            when {
                expression { return params.RUN_TESTS }
            }
            steps {
                echo 'Running tests...'
            }
        }
    }
}
```



Esempio 3: Pipeline con Parallelismo
```groovy
pipeline {
    agent none

    stages {
        stage('Build and Test') {
            parallel {
                stage('Build Linux') {
                    agent {
                        label 'linux'
                    }
                    steps {
                        sh 'make linux'
                    }
                }
                stage('Build Windows') {
                    agent {
                        label 'windows'
                    }
                    steps {
                        bat 'build.bat' // Comando specifico per Windows
                    }
                }
                stage('Test Unit') {
                    agent any
                    steps {
                        sh 'make test-unit'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }
}
```



Esempio 4: Pipeline Avanzata con Librerie Shared
```groovy
// Questo esempio assume che sia stata configurata una Shared Library in Jenkins
@Library('my-shared-library')_

pipeline {
    agent any

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeep: 5))
    }

    triggers {
        pollSCM('H/5 * * * *') // Controlla SCM ogni 5 minuti
    }

    environment {
        // Variabili d'ambiente
        PROJECT_NAME = 'my-app'
        CREDENTIALS_ID = credentials('my-credentials') // Credenziali bindate automaticamente
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // Checkout del codice sorgente
            }
        }

        stage('Build') {
            steps {
                script {
                    // Utilizzo di metodi dalla shared library
                    def builder = new com.mycompany.Builder()
                    builder.buildProject()
                }
            }
        }

        stage('Static Analysis') {
            steps {
                // Integrazione con SonarQube
                withSonarQubeEnv('sonar-server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    // Utilizzo di Docker
                    docker.image('node:14').inside {
                        sh 'npm run deploy:staging'
                    }
                }
            }
        }
    }

    post {
        success {
            // Notifica di successo
            slackSend channel: '#builds', message: "Build ${currentBuild.fullDisplayName} succeeded"
        }
        failure {
            // Notifica di fallimento
            slackSend channel: '#builds', message: "Build ${currentBuild.fullDisplayName} failed"
            emailext body: "Check la build: ${env.BUILD_URL}", subject: "BUILD FAILED: ${env.JOB_NAME}", to: 'team@example.com'
        }
        always {
            // Pulizia
            cleanWs()
            // Archivazione artefatti
            archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
        }
    }
}
```


# Elementi Specifici di Jenkinsfile

Agent
Definisce dove eseguire la pipeline:
```groovy
agent {
    docker {
        image 'node:14'
        args '-v /tmp:/tmp'
    }
}

agent {
    kubernetes {
        label 'my-k8s-agent'
        yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: node
    image: node:14
'''
    }
}
```


When
Condizioni per l'esecuzione degli stage:
```groovy
stage('Deploy Prod') {
    when {
        branch 'main'
        environment name: 'DEPLOY_TO_PROD', value: 'true'
        not { changeRequest() }
    }
    steps {
        echo 'Deploying to production'
    }
}
```


Tools
Integrazione con tool installati in Jenkins:
```groovy
tools {
    maven 'M3'
    jdk 'JDK11'
}

stage('Build') {
    steps {
        sh 'mvn clean package'
    }
}
```

# Best Practices

1. Mantieni il Jenkinsfile nella radice del repository
2. Usa la sintassi Declarative per maggiore leggibilità
3. Estrai logica complessa in Shared Libraries
4. Utilizza le credenziali in modo sicuro con credentials()
5. Mantieni gli stage atomici e focalizzati su un compito specifico

Questi esempi mostrano progressione dalla base ad concetti avanzati. Per approfondire, consulta la documentazione ufficiale di Jenkins.