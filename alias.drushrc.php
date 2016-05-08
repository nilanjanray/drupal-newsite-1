<?php

/**
 * Basic alias for d8.
 */
$aliases['d8'] = array (
  'root' => '/var/www/html/drupal',
  'uri' => 'http://localhost/drupal',
  'path-aliases' => 
  array (
    '%drush' => '/usr/bin',
    '%site' => 'sites/default/',
    '%file' => 'site/default/files',
    '%dump-dir' => 'site/default/sql-dump',
  ),
);
