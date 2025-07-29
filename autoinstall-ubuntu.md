# Ubuntu autoinstall

## Liens utiles
https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html

## Pourquoi utiliser des autoinstall
### Les limites de l'installation manuelle d'un système
Vous est-il déjà arrivé d'installer un système d'exploitation ? Durant la phase d'installation, plusieurs information nous est demandé, entre chaque questions, il peut y avoir des téléchargement nous demandant d'attendre inutillement devant la machine. Une fois la phase d'installation faite, il faut faire les configurations basiques comme mettre à jour les paquets, créer les utilisateurs, installer les paquets nécéssaires, ajouter des clés ssh, ... Bref, tout ça prend du temps. Si c'est pour une unique machine, on n'a pas d'autre choix que de faire cette configuration d'une façon ou d'une autre. Le problème est quand on doit configurer un grand nombre de machines à configurer. Le temps de configuration est proportionnel au nombre de machine.

### Les automatisations d'installation de système
Pour éviter de répéter manuellement l'ensenble des étapes sans avoir besoin d'etre derrière le clavier, il serait idéal de pouvoir donner un fichier de configuration avec le fichier iso. L'idéal serait meme de pouvoir avoir un format de fichier déclaratif pour s'éviter des scripts bash qui réussisent malencontreusement à tomber en marche. Bonne nouvelle, le système existe déjà !

## Introduction à l'autoinstall d'Ubuntu
https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html
### Principe de fonctionnement
Lors de la première séquence de boot, on va préciser de lancer la séquence d'installation. Pour que l'installer est la connaissance de la configuration souhaité, il faut lui fournir un fichier au format YAML décrivant l'état du système tel qu'on le souhaite. Ce fichier peut soit etre placé dans le média d'installation, soit fournit via cloud-init. 

### Ecrire son fichier de configuration
Le fichier s'écrit au format YAML est se compose de différents modules que l'on appelle au besoin. Une primière section nommé autoinstall permet de faire des configuration basiques. Cela permet de configurer globalement l'équivalent des informations demandées lors de l'installation manuelle. Il est bon de noter que certains paramètre peuvent etre demandé en mode interractif, ce qui peut s'avérer utile pour les configuration réseau. Pour aller plus loin dans la configuration, cloud-init nous offre des options plus avancées pour la configuration. On utilisera alors la sous section user-data pour y appeler les modules de cloud-init. Parmis les plus utiles on peut citer package, apt, yum, ssh ou des outils tel que ansible, chef et puppet.

autoinstall:
	# Auto install directive
	user-data:
		#Cloud-init directive

Documentation autoinstall configuration : https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#user-data
La liste des modules cloud-init : https://docs.cloud-init.io/en/latest/reference/modules.html
Exemples cloud-init : https://docs.cloud-init.io/en/latest/reference/examples.html


### Préparer son installation
#### Installation avec le fichier fourni sur le média d'installation
Le fichier devra s'appeller autoinstall.yaml et etre copié à la racine de la partition qui contient l'iso (cette particion contient le dossier casper). Une autre méthode est de l'inclure dans l'iso mais n'est pas recommandé par Canonical.

#### Installation via un service web
Cette fois ci le fichier restera sur une machine distante qui devra ouvrir un serveur web pour délivrer le fichier de configuration avec la commande python3 -m http.server 3003. Lors du boot, il faudra aussi des informations complémentaires pour préciser qu'il faut récupérer le fichier en distant ds=nocloud-net\;s=http://IP_GATEWAY:3003/. Attention, le fichier de configuration doit avoir en première ligne #cloud-config.
Pour plus d'info : https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-quickstart.html
