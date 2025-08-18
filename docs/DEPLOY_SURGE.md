# Deploy Alternativo - Surge.sh

## Instalação
```bash
npm install -g surge
```

## Deploy do PDV
```bash
cd "c:\Users\crism\Desktop\PDV Allimport\Pdv-Allimport"
npm run build
cd dist
surge . pdv-allimport.surge.sh
```

## URL Final
https://pdv-allimport.surge.sh

## Comandos Rápidos
```bash
# Build + Deploy em um comando
npm run build && cd dist && surge . pdv-allimport.surge.sh
```
