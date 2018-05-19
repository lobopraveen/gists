Remove the comma from the values in a CSV file where the values may have one comma.

```sh
sed 's/\("[^,]\{1,\}\),\([^,^"]\{1,\}"\)/\1\2/g' filename
```

Remove the commas from the values in a csv file where the values may have none or two commas.

```sh
sed 's/\("[^,]\{1,\}\),\([^,^"]\{1,\}\),\([^,^"]\{1,\}"\)/\1\2\3/g' filename 
```

Remove the commas from the values in a csv file where the values may have up to two commas. Combine the two from above. 

```sh
sed -e 's/\("[^,]\{1,\}\),\([^,^"]\{1,\}"\)/\1\2/g' \
    -e 's/\("[^,]\{1,\}\),\([^,^"]\{1,\}\),\([^,^"]\{1,\}"\)/\1\2\3/g' filename
```
