<?php

/**
 * implements hook_install_form_alter()
 */
function articlesite_form_alter(&$form, &$form_state, $form_id) {
	switch ($form_id) {
		case 'install_configure_form':
			$form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
			$form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
			$form['admin_account']['account']['name']['#default_value'] = 'admin';
			$form['admin_account']['account']['mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
	    break;
		case 'install_select_profile_form':
		  //can we alter this one ??
			break;
	}
}

/**
 * Implements hook_install_tasks_alter().
 */
function articlesite_install_tasks_alter(&$tasks, $install_state) {
	// Preselect the English language, so users can skip the language selection
  if (!isset($_GET['locale'])) {
    $_POST['locale'] = 'en';
  }
}

/**
 * hook_install_tasks()
 */
function articlesite_install_tasks() {
  $task['admin_theme'] = array(
    'display_name' => st('Set admin theme'),
    'display' => TRUE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'articlesite_enable_admin_theme',
  );
	$task['basic_roles'] = array(
    'display_name' => st('Install extra role(s)'),
    'display' => TRUE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'articlesite_create_basic_roles_perms',
  );
  $task['other_setup_tasks'] = array(
    'display_name' => st('Other setup tasks'),
    'display' => TRUE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'articlesite_other_setup_tasks',
  );
  return $task;
}

/**
 * Create 2 default roles
 */
function articlesite_create_basic_roles_perms() {
  //1) Create an editor role with some default permissions
  $admin_role = new stdClass();
  $admin_role->name = 'editor';
  $admin_role->weight = 3;
  user_role_save($admin_role);

	//TODO - add permissions for strongarm, better_formats, cck, flag, i18n, views_slideshow
	$permissions = array(
    'access administration pages',
    'access all views',
		'access content',
    'access content overview',
    'access site in maintenance mode',
    'access site reports',
		'access administration menu',
		'flush caches',
		'display drupal links',
    'access user profiles',
    'administer comments',
    'administer menu',
    'administer search',
    'administer taxonomy',
    'administer url aliases',
    'bypass node access',
    'create page content',
    'create article content',
    'create url aliases',
    'delete any page content',
    'delete any article content',
    'delete own page content',
    'delete own article content',
    'delete revisions',
    'edit any page content',
    'edit any article content',
    'edit own page content',
    'edit own article content',
    'edit own comments',
    'revert revisions',
    'search content',
    'skip comment approval',
		'post comments',
		'access comments',
    'use advanced search',
    'use text format filtered_html',
    'use text format full_html',
    'view own unpublished content',
    'view revisions',
    'view the administration theme',
  );
  user_role_grant_permissions($admin_role->rid, $permissions);
  // Set this as the editor role.
  variable_set('user_editor_role', $admin_role->rid);

}

/**
* Set Rubik as the Admin Theme
*/
function articlesite_enable_admin_theme() {
  // Enable the admin theme.
  db_update('system')
    ->fields(array('status' => 1))
    ->condition('type', 'theme')
    ->condition('name', 'seven')
    ->execute();
  db_update('system')
    ->fields(array('status' => 1))
    ->condition('type', 'theme')
    ->condition('name', 'rubik')
    ->execute();
  variable_set('admin_theme', 'rubik');
  variable_set('node_admin_theme', '1');
}

/**
 *
 */
function articlesite_other_setup_tasks() {
	// set various system variables
  variable_set('pathauto_node_pattern', '[node:type]/[node:title]');
  variable_set('pathauto_punctuation_underscore', '1');
}
