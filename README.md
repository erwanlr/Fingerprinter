Fingerprinter
=============

This script goal is to try to find the version of the remote application/third party script etc by using a fingerprint approach.

#### Installation
Inside the cloned repo directory:

```
$ gem install bundler
$ bundle install
```

#### Currently Supported Apps (along with some location/s of versions being disclosed)
- Apache Icons
- CKEditor [[CVEs](http://www.cvedetails.com/vendor/12058/Ckeditor.html) | [Exloit DB](https://www.exploit-db.com/search/?action=search&description=ckeditor)]
- CMS Made Simple [Experimental] [[CVEs](http://www.cvedetails.com/vendor/3206/Cmsmadesimple.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=cms+made+simple)]
- Concrete5 [[CVEs](http://www.cvedetails.com/vendor/11506/Concrete5.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=concrete5)]
- Django CMS [[CVEs](http://www.cvedetails.com/product/18211/Djangoproject-Django.html?vendor_id=10199)]
  - Version disclosed when logged as a privileged user (editor, Page Owner etc): ```<div class="cms_toolbar-item cms_toolbar-item-logo"><a href="/" title="---VERSION---">django CMS</a></div>```
- DNN CMS (DotNetNuke) [[Releases](https://dotnetnuke.codeplex.com/releases) | [Security Center](http://www.dnnsoftware.com/platform/manage/security-center) | [CVEs](http://www.cvedetails.com/product/4306/Dotnetnuke-Dotnetnuke.html?vendor_id=2486) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=dotnetnuke)]
- Drupal [[Security Advisories](https://www.drupal.org/security) | [CVEs](http://www.cvedetails.com/product/2387/Drupal-Drupal.html?vendor_id=1367) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=drupal)]
  - Version disclosed from /CHANGELOG.txt
- FCKeditor [[CVEs](http://www.cvedetails.com/vendor/2724/Fckeditor.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=fckeditor)]
- Joomla [[Version History](https://docs.joomla.org/Category:Version_History) | [Security Centre](http://developer.joomla.org/security-centre.html) | [CVEs](http://www.cvedetails.com/product/6129/Joomla-Joomla.html?vendor_id=3496) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=joomla)]
- Liferay [[CVEs](http://www.cvedetails.com/vendor/2114/Liferay.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=liferay)]
- Magento Community Edition [Experimental] [[CVEs](http://www.cvedetails.com/vendor/15393/Magento.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=magento) | [Exploits](http://www.magentoexploit.com/)]
- Mantis Bug Tracker [Experimental] [[CVEs](http://www.cvedetails.com/vulnerability-list/vendor_id-1245/product_id-2160/Mantis-Mantis.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=mantis) | [Releases](https://www.mantisbt.org/forums/viewforum.php?f=5)]
   - Version disclosed from footer (if enabled): 'Powered By MantisBT x.x.x'
   - If the copyright year in the footer is not the current year, then the version is < 1.2.13 ([related commit](https://github.com/mantisbt/mantisbt/commit/6e51d86d3c83e96f38d6f1be77f2521689005b51#diff-b1c667913de013265f22c582987aa38c))
- Mediaelement [Experimental] [[CVEs](http://www.cvedetails.com/product/27053/Mediaelementjs-Mediaelement.js.html?vendor_id=13110)]
- OpenCart [[CVEs](http://www.cvedetails.com/product/17142/Opencart-Opencart.html?vendor_id=9599) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=opencart)]
- Orchard (beware that backporting is used) [[CVEs](http://www.cvedetails.com/product/23837/Orchardproject-Orchard.html?vendor_id=12571) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=orchard)]
- PHPMyAdmin (currentlly only the manual installation versions) [[CVEs](http://www.cvedetails.com/vendor/784/Phpmyadmin.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=phpmyadmin)]
- PrestaShop [[CVEs](http://www.cvedetails.com/vendor/8950/Prestashop.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=prestashop)]
- PunBB [[CVEs](http://www.cvedetails.com/product/4868/Punbb-Punbb.html?vendor_id=2775) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=punbb)]
- TinyMCE [[CVEs](http://www.cvedetails.com/vendor/11716/Tinymce.html) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=tinymce)]
- Umbraco [[CVEs](http://www.cvedetails.com/product/30682/Umbraco-Umbraco-Cms.html?vendor_id=15064) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=umbraco)]
- WordPress [[CVEs](http://www.cvedetails.com/product/4096/Wordpress-Wordpress.html?vendor_id=2337) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=wordpress) | [WP Vuln DB](https://wpvulndb.com/)]
  - Version disclosed from:
    - / (meta generator, stylesheet numbers: ?ver=)
    - Generator tag in /feed/, /feed/rdf/, /feed/atom/, /sitemap.xml(.gz) , /wp-links-opml.php
    - /readme.html

#### Unsupported Apps (along with the reason, useful links & location/s of versions being disclosed)
- AngularJS - Fingerprints not needed for that (see below) [[Payloads](https://code.google.com/p/mustache-security/wiki/AngularJS)]
  - Version disclosed from:
    - filename or filepath
    - In the comments at the top of the file
    - By submitting angular.version in the Web Dev console of the Web browser on a page where the lib is loaded
- ExpressionEngine - Need to be registered to download the latest free core version. No page to DL them all. [[CVEs](http://www.cvedetails.com/product/12972/Expressionengine-Expressionengine.html?vendor_id=7662) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=ExpressionEngine)]
  - Version disclosed from the footer and rss link (generator tag)
- jQuery - Fingerprints not needed for that (see below) [[CVEs](http://www.cvedetails.com/product/11031/Jquery-Jquery.html?vendor_id=6538)]
  - Version disclosed from:
    - Filename of filepath
    - In the Comments at the top of the file
    - By submitting $().jquery or jQuery().jquery in the Web Dev console of the Web browser on a page where the lib is loaded
- jQuery UI - Fingerprints not needed for that (see below) [[CVEs](http://www.cvedetails.com/product/31126/Jquery-Jquery-Ui.html?vendor_id=6538)]
  - Version disclosed from:
    - Filename of filepath
    - In the Comments at the top of the file
    - By submitting $.fn.jquery or jQuery.fn.jquery in the Web Dev console of the Web browser on a page where the lib is loaded
- Kentico CMS - Need to provide personal details / register to DL the latest free version [[Exploit DB](https://www.exploit-db.com/search/?action=search&description=kentico) | [Hotfixes](http://devnet.kentico.com/download/hotfixes)]
  - Version disclosed from /CMSHelp/ (main version in title tag)
- PrettyPhoto - Fingerprints no needed for that (see below) [[CVEs](http://www.cvedetails.com/product/26726/No-margin-for-errors-Prettyphoto.html?vendor_id=13006)]
  - Version disclosed from the comments at the top of the file
- SharePoint - Not free / couldn't find a free or CE edition [[Exploit DB](https://www.exploit-db.com/search/?action=search&description=sharepoint)]
  - Version disclosed from /_vti_pvt/service.cnf (Not verified)
- Sitecore CMS - Need to be registered, not sure if all versions would then be available to DL [[CVEs](http://www.cvedetails.com/product/17161/Sitecore-CMS.html?vendor_id=9609) | [Exploit DB](https://www.exploit-db.com/search/?action=search&description=sitecore) | [Security Advisories](https://kb.sitecore.net/SearchResults#fltr=t3,p2&slider=0,11&pg=1) | [Latest Version Numbers](https://dev.sitecore.net/en/Downloads/Sitecore_Experience_Platform.aspx) | [Version numbers & revisions](https://sdn.sitecore.net/Products/Sitecore%20V5/Sitecore%20CMS%207/Update/7_0_rev_130424.aspx)]
  - Version disclosed from
    - /sitecore/login
    - /sitecore/shell/sitecore.version.xml
- vBulletin - Not free [[Sucuri](https://blog.sucuri.net/tag/vbulletin-security) | [Security Announcements](http://www.vbulletin.com/forum/search?q=Security&searchFields[title_only]=1&searchFields[channel][]=28&searchJSON={%22keywords%22%3A%22Security%22%2C%22title_only%22%3A1%2C%22channel%22%3A[%2228%22]})]
  - Version disclosed from:
    - generator meta tagand footer copyright in all pages
    - /clientscript/vbulletin_global.js
    - /clientscript/vbulletin_menu.js
    - /clientscript/vbulletin-core.js

#### Basic Usage Examples
##### Using all the Fingerprints
```
./fingerprinter.rb --app-name wordpress --fingerprint http://target.com/blog/
```

##### Using unique Fingerprints
With this mode, only the unique Fingerprints (across all the application's versions files) will be tested.
This mode is faster than the previous one, and more reliable. However it is possible that an application's version does not have any unique fingerprints (like Apache Icons, which only has 2 unique fingerprints for the version 2.4.4, and none for the others)
```
./fingerprinter.rb --app-name wordpress --unique-fingerprint http://target.com/blog/
```

##### Using passive fingerprinting mode
In this mode, the homepage of the target is scanned for included ressources such as JavaScript files, Images etc which are then checked against the DB.
```
./fingerprinter.rb --app-name wordpress --passive-fingerprint http://target.com/blog/
```

#### Options
```
-p, --proxy PROXY                   Proxy to use during the fingerprinting
    --timeout SECONDS               The number of seconds for the request to be performed, default 20s
    --connect-timeout SECONDS       The number of seconds for the connection to be established before timeout, default 5s
    --cookies-file, --cf FILE-PATH  The cookies file to use during the fingerprinting
    --cookies-string, --cs COOKIE/S The cookies string to use in requests
    --user-agent, --ua UA           User-Agent to use in all fingerprinting requests
-d, --db PATH-TO-DB                 Path to the db of the app-name (default is db/<app-name>.db)
-u, --update                        Update the db of the app-name
-m, --manual DIRECTORY-PATH         To be used along with the --update and --version options. Process the (local) DIRECTORY-PATH and compute the file fingerprints
    --version                       Used with --manual to set the version of the processed fingerprints
    --update-all,                   Update all the apps
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
        --timeout SECONDS                              The number of seconds for the request to be performed, default 20s
        --cookies-file, --cf FILE-PATH                 The cookies file to use during the fingerprinting
        --cookies-string, --cs COOKIE/S                The cookies string to use in requests
        --user-agent, --ua UA                          User-Agent to use in all fingerprinting requests
    -a, --app-name APPLICATION                         The application to fingerprint. Currently supported: apache-icons, ckeditor, cms-made-simple, concrete5, django-cms, dnn-cms drupal, fckeditor, joomla, liferay, magento-ce, mantisbt, mediaelement, phpmyadmin, prestashop, punbb, tinymce, umbraco, wordpress
    -d, --db PATH-TO-DB                                Path to the db of the app-name
    -u, --update                                       Update the db of the app-name
        --manual DIRECTORY-PATH                        To be used along with the --update and --version options. Process the (local) DIRECTORY-PATH and compute the file fingerprints
        --version VERSION                              Used with --manual to set the version of the processed fingerprints
        --update-all,                                  Update all the apps
        --list-versions, --lv                          List all the known versions in the DB for the given app
        --show-unique-fingerprints, --suf VERSION      Output the unique file hashes for the given version of the app-name
        --search-hash, --sh HASH                       Search the hash and output the app-name versions & file
        --search-file, --sf FILE                       Search the file using a LIKE method (so % can be used, e.g: readme%) and output the app-name versions & hashes
        --fingerprint URL                              Fingerprint the app-name at the given URL using all fingerprints
        --unique-fingerprint, --uf URL                 Fingerprint the app-name at the given URL using unique fingerprints
        --passive-fingerprint, --pf URL                Passively fingerprint the URL
        --db-verbose, --dbv                            Database Verbose Mode
    -v, --verbose                                      Verbose Mode
```
