#!/bin/bash

source ~/.gmail
(test -z "$user" || test -z "$pass") && exit 1

echo "Torrent download $TR_TORRENT_NAME is complete" | mailx -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login -S smtp=smtp.gmail.com:587 -S from=pi@alarmpi.me -S smtp-auth-user=$user -S smtp-auth-password=$pass -s "$TR_TORRENT_NAME downloaded" $user@gmail.com
