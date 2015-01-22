Fingerprinter
=============

This script goal is to try to find the version of the remote application/third party script etc by using a fingerprint approach.

#### Currently Supported Apps
- Apache Icons
- CKEditor
- CMS Made Simple [Experimental]
- Drupal
- FCKeditor
- Liferay
- PHPMyAdmin (currentlly only the manual installation versions)
- TinyMCE
- Umbraco [Experimental]
- WordPress

#### Basic Usage Examples
##### Using all the Fingerprints
```
./fingerprinter.rb --app-name wordpress --fingerprint http://target.com/blog/
```
##### Using unique Fingerprints
With this mode, only the unique Fingerprints (accross all the application's versions files) will be tested.
This mode is faster than the previous one, and more reliable. However it is possible that an application's version does not have any unique fingerprints (like Apache Icons, which only has 2 unique fingerprints for the version 2.4.4, and none for the others)
```
./fingerprinter.rb --app-name wordpress --unique-fingerprint http://target.com/blog/
```

#### Options
```
-p, --proxy PROXY                   Proxy to use during the fingerprinting
    --cookies-file, --cf FILE-PATH  The cookies file to use during the fingerprinting
-d, --db PATH-TO-DB                 Path to the db of the app-name (default is db/<app-name>.db)
-u, --update                        Update the db of the app-name
-m, --manual DIRECTORY-PATH         To be used along with the --update and --version options. Process the (local) DIRECTORY-PATH and compute the file fingerprints
    --version                       Used with --manual to set the version of the processed fingerprints
    --update-all, --ua              Update all the apps
    --db-verbose, --dbv             Database Verbose Mode
-v, --verbose                       Verbose Mode
```
Example: Add the file fingerprints from /tmp/test into the Liferay DB for the v6.2
```
./fingerprinter -a liferay --update --manual /tmp/test --version 6.2
```

#### Search the Application Database
Along with the --app-name option (or -a), the database can be searched:
```
--list-version, --lv                       List all the known versions in the DB for the given app
--show-unique-fingerprints, --suf VERSION  Output the unique file hashes for the given version of the app-name
--search-hash, --sh HASH                   Search the hash and output the app-name versions & file
--search-file, --sf FILE                   Search the file using a LIKE method (so % can be used, e.g: readme%) and output the app-name versions & hashes
```
Example: Search all the unique Fingerprints for the version 3.8.1 of WordPress
```
./fingerprinter.rb -a wordpress --suf 3.8.1
```

#### --help
```
Usage: ./fingerprinter.rb [options]
    -p, --proxy PROXY                                  Proxy to use during the fingerprinting
        --cookies-file, --cf FILE-PATH                 The cookies file to use during the fingerprinting
        --cookies-string, --cs COOKIE/S                The cookies string to use in requests
    -a, --app-name APPLICATION                         The application to fingerprint. Currently supported: wordpress, fckeditor, apache-icons, phpmyadmin, tinymce, drupal, umbraco, cms-made-simple, ckeditor, liferay
    -d, --db PATH-TO-DB                                Path to the db of the app-name
    -u, --update                                       Update the db of the app-name
        --manual DIRECTORY-PATH                        To be used along with the --update and --version options. Process the (local) DIRECTORY-PATH and compute the file fingerprints
        --version VERSION                              Used with --manual to set the version of the processed fingerprints
        --update-all, --ua                             Update all the apps
        --list-versions, --lv                          List all the known versions in the DB for the given app
        --show-unique-fingerprints, --suf VERSION      Output the unique file hashes for the given version of the app-name
        --search-hash, --sh HASH                       Search the hash and output the app-name versions & file
        --search-file, --sf FILE                       Search the file using a LIKE method (so % can be used, e.g: readme%) and output the app-name versions & hashes
        --fingerprint URL                              Fingerprint the app-name at the given URL using all fingerprints
        --unique-fingerprint, --uf URL                 Fingerprint the app-name at the given URL using unique fingerprints
        --db-verbose, --dbv                            Database Verbose Mode
    -v, --verbose                                      Verbose Mode
```
