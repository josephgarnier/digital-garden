- [x] rédiger conditions de services
- [ ] ajouter carte à droite avec les noeuds des arbres (comme ici https://publish.obsidian.md/alexisrondeau/Digital+Garden+Fruits)
- [ ] ajouter système de référence en bas
- [ ] ajouter les images de MN
- [ ] ajouter date de création et date de dernière modification
- [x] comment gérer les notes privées et publiques : avec une instruction yaml ou avec des dossiers
- [ ] list d'emoj https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md
- [ ] variable pour gitbook https://github.com/GitbookIO/gitbook/blob/master/docs/templating/variables.md
- [ ] variable pour zettlr https://docs.zettlr.com/fr/core/yaml-frontmatter/
- [ ] variables pour pandoc https://pandoc.org/MANUAL.html#variables
- [ ] réorganiser les répertoires (ajouter un répertoire asset où mettre les images et autres documents ? média ?)
- [x] créer un script d'export en bash pour le mettre en une action github (appelé build ou workflow) => En s'inspirant de ce lien (https://jekyllrb.com/docs/continuous-integration/github-actions/), il devra copier le contenu de le branch master dans une branche git_book, puis remplacer les liens internes sous forme d'ID (ceux comme [[...]]) par des liens markdown vers les nom de fichiers correspondants. Le script remplacera les ID par des liens et n'exportera que les notes avec le statut public.
- [ ] sur le site, indiquer l'état d'avancement des articles.