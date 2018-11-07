# Simple ISPConfig backup

**STILL IN DEVELOPMENT**

## Description
This script helps you to make simple backups of ISPConfig. It can't restore (for now).

This script try to solves MY problem, maybe you need to make other configurations.

## How To Use
1. Copy ```src``` content to your server.
2. Edit ```makeBackup.sh``` with your paths (optional)
3. Create/mount the backup directory (/backups/ for example) - **This can be remote machine folder**
4. Make file executable ```chmod a+rx /path/to/script.sh```
5. Create a cron with ```crontab -e``` with ```root```, for example:
```bash
15 2 * * * /path/to/your/script.sh > /path/to/file.log

```

Recommended test script before using in **cron**.

