The following script ensures that all the files that match a specific pattern have ".pgp" extension. This will not touch a matching file which already has ".pgp" extension. Note that if a non ".pgp" extension already exists, it still appends ".pgp".

```ksh
#!/usr/bin/ksh
for filename in pattern*
do
    test "${filename}" = "${filename%.pgp}" && mv "$filename" "${filename}.pgp"
done
```

This can be easily tweaked to change one extension to another. The below script changes extension to ".gpg" on all ".pgp" files that match a pattern.


```ksh
#!/usr/bin/ksh
for filename in pattern*
do
    test "${filename}" != "${filename%.pgp}" && mv "$filename" "${filename%.pgp}.gpg"
done
```

The above two scripts can be combined when the goal is to change the extension to ".gpg" on all ".pgp" files that match a pattern along with adding ".gpg" extension on extensionless files.

```ksh
#!/usr/bin/ksh
for filename in pattern*
do
  echo "Changing .pgp extension, if any, to .gpg : ${filename}"

  modifiedfilename="${filename}"
  test "${filename}" != "${filename%.pgp}" && mv "$filename" "${filename%.pgp}.gpg"  && modifiedfilename="${filename%.pgp}.gpg"

  echo "Append .gpg extension if not present already: ${modifiedfilename}"

  test "${modifiedfilename}" = "${modifiedfilename%.gpg}" && mv "$modifiedfilename" "${modifiedfilename}.gpg" && modifiedfilename="${modifiedfilename}.gpg"

  echo "Final name: ${modifiedfilename}"
done
```

[shell's parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- `%` in below scripts match shortest from the end of the string.
- `%%` matches longest from the end
- `#` shortest from the beginning
- `##` longest from the beginning
