# start_stopp

L'application Start & Stopp Scanner est une application mobile qui scanne une ordonnance et en retire les médicaments avec les critères STOPP correspondants.

Elle a été codée en Dart avec le framework Flutter.

## Consignes d'utilisation

L'application est intuitive. Pour s'en servir, il suffit de clicker sur l'icone Caméra. Cela ouvre ensuite l'appareil photo et on peut ensuite prendre une photo de l'ordonnance. L'analyse va durer quelques secondes et ensuite afficher les médicaments trouvés.
Les médicaments avec un critère stopp seront mis en évidence. Les médicaments classiques 

## Explication du fonctionnement

L'analyse de la photo se fait par OCR grâce au kit de machine learning développé par Google, MLKit.
La reconnaissance des mots correspondants à des médicaments est assez complexe, dû à la multitude d'appelations des médicaments (laboratoires, etc). Il existe cependant une norme RXCUI qui pourrait être exploitable pour garantir une exactitude des reconnaissances.
L'accès aux critères stopp se fait par une base de données dynamique, Firebase.

## Reprise du Projet

Ce projet a été concu pour pouvoir être repris par un prochain groupe de développement.
La version actuellement pushée sur GitHub est simplifiée (sans authentification).
La version précedemment enregistrée possède un module d'authentification.

## Ce qu'il reste à faire

Il reste à implémenter les interactions médicamenteuses et l'affichage des critères start dans l'application.