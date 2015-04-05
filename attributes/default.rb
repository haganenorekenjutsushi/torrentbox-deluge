default['deluge'] = {
	'repository' => 'ppa:deluge-team/ppa',
	'config' => {
		'user' => 'servicedeluge',
		'password' => 'deluge',
		'datadir' => "/home/servicedeluge/.config/deluge",
		'move_completed_path' => '/home/servicedeluge',
		'torrentfiles_location' => '/home/servicedeluge',
		'download_location' => '/home/servicedeluge',
		'plugins_location' => '/home/servicedeluge/.config/deluge/plugins',
		'autoadd_location' => '/home/servicedeluge',
		'web_port' => 8112,
		'web_password' => 'password',
		'web_password_salt' => 'c26ab3bbd8b137f99cd83c2c1c0963bcc1a35cad'
	}
}