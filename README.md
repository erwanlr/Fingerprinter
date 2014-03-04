Fingerprinter
=============

This script goal is to try to find the version of the remote application/third party script etc by using a fingerprint approach.

#### Currently Supported Apps
- Apache Icons
- CMS Made Simple [Experimental]
- Drupal
- FCKeditor
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
./fingerprinter.rb --app-name wordpress --unique-fingerprint http://traget.com/blog/
```

#### Options
```
-p, --proxy PROXY                   Proxy to use during the fingerprinting
    --cookies-file, --cf FILE-PATH  The cookies file to use during the fingerprinting
-d, --db PATH-TO-DB                 Path to the db of the app-name (default is db/<app-name>.db)
-u, --update                        Update the db of the app-name
    --db-verbose, --dbv             Database Verbose Mode
-v, --verbose                       Verbose Mode
```
#### Search the Application Database
Along with the --app-name option (or -a), the database can be searched:
```
--show-unique-fingerprints, --suf VERSION  Output the unique file hashes for the given version of the app-name
--search-hash, --sh HASH                   Search the hash and output the app-name versions & file
--search-file, --sf RELATIVE-FILE-PATH     Search the file and output the app-name versions & hashes
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
    -a, --app-name APPLICATION                         The application to fingerprint. Currently supported: wordpress, fckeditor, apache-icons, phpmyadmin, tinymce, drupal, umbraco, cms-made-simple
    -d, --db PATH-TO-DB                                Path to the db of the app-name
    -u, --update                                       Update the db of the app-name
        --show-unique-fingerprints, --suf VERSION      Output the unique file hashes for the given version of the app-name
        --search-hash, --sh HASH                       Search the hash and output the app-name versions & file
        --search-file, --sf RELATIVE-FILE-PATH         Search the file and output the app-name versions & hashes
        --fingerprint URL                              Fingerprint the app-name at the given URL using all fingerprints
        --unique-fingerprint, --uf URL                 Fingerprint the app-name at the given URL using unique fingerprints
        --db-verbose, --dbv                            Database Verbose Mode
    -v, --verbose                                      Verbose Mode
```
