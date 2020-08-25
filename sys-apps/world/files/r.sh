#!/bin/sh
cd /var/db/repos/prototype99/profiles-local
sudo curl https://api.gentoo.org/overlays/repositories.xml -o stage0.xml
cmp stage0.xml stage1.xml && sudo rm stage0.xml && exit || sudo mv stage0.xml stage1.xml || printf "To: sophietheopossum@yandex.ru\nFrom: sophietheopossum@yandex.ru\nSubject: remove failed\n\nfailed to remove stage0 check logs" | msmtp sophietheopossum@yandex.ru && exit
sudo cp stage1.xml stage2.xml
sudo patch -s stage2.xml repo.patch || printf "To: sophietheopossum@yandex.ru\nFrom: sophietheopossum@yandex.ru\nSubject: patch failed\n\npatch can't apply, try regenerating the patch" | msmtp sophietheopossum@yandex.ru && exit
printf "To: sophietheopossum@yandex.ru\nFrom: sophietheopossum@yandex.ru\nSubject: new repositories available\n\nrun\nsudo layman -f && sudo layman -a ALL\nto see them" | msmtp sophietheopossum@yandex.ru