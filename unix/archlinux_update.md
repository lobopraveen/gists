This script updates Arch Linux system

```bash
echo "Running system update..."

printf  "\n\naurman -Syuu\n\n"
sleep 1
aurman -Syuu

printf "\n\npaccache -r\n\n"
sleep 1
paccache -r

printf "\n\npaccache -ruk0\n\n"
sleep 1
paccache -ruk0

#printf "\n\nstupid geeqie downgrade\n\n"
#sleep 1
#sudo pacman -U /var/cache/pacman/pkg/geeqie-1.3-3-x86_64.pkg.tar.xz

echo "Bye!"
```
