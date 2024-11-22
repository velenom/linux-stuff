# systemd timer & service to create system backups before installing software updates 

### Add a script and a systemd service

- Add `backup-update.service` and `backup-update.timer` to `/etc/systemd/user`. Change the path to the script as needed.

### Enable the timer

Enable the service

```
~ > systemctl --user enable backup-update.timer
```
