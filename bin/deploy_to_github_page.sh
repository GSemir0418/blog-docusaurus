#!/usr/bin/env bash
rm -rf build
npm run build
cd build
git init
git add .
git commit -m deploy
git remote add origin git@github.com:GSemir0418/blog-docusaurus-preview.git
git push -f origin master
cd -