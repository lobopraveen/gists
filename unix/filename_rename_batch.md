Rename all ".CR2" files to "YYYYMMDD_COUNTER_EVENT.CR2" format with the counter starting at 1000

```bash
count=1000; for i in *CR2; do ((++count));  mv "${i}" "20150805_${count}_AbcBirthday.CR2"; done
```

Rename all ".JPG" files to "YYYYMMDD_COUNTER_EVENT.JPG" format with the counter starting at 1000

```bash
count=1000; for i in *JPG; do ((++count));  mv "${i}" "20150805_${count}_AbcBirthday.JPG"; done
```

Update the filenames to start the counter at 001 with leading zeroes.

```bash
rename "20150805_1" "20150805_" *`
```

To rename based on filename pattern but to keep the filename extension intact replace the extension part in the `mv` command with

```bash
echo "${i}" | awk -F. '{print $NF}'
```
