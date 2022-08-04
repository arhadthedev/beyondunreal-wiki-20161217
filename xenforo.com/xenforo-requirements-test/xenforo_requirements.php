<?php
	header('Content-type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>XenForo System Requirements Test</title>
	<style>
		html
		{
			background-color: rgb(240,240,240);
			margin: 0;
			padding: 0;
		}

		body
		{
			font: 11pt 'Trebuchet MS', Helvetica, Arial, sans-serif;
			color: rgb(20,20,20);
			line-height: 1.6;
			margin: 0;
			padding: 0;
		}

		.pageWidth
		{
			max-width: 760px;
			margin: 0 auto;
		}

		#header
		{
			background-color: #176093;
			border-bottom: 1px solid #2B485C;
		}

		h1
		{
			font-size: 24pt;
			font-weight: normal;
			color: white;
			padding: 20px;
			margin: 0;
		}

		.contents
		{
			padding: 20px;
			background-color: rgb(252, 252, 255);
		}

		h2
		{
			margin: 0;
		}

		.success h2
		{
			font: 20pt Georgia, "Times New Roman", Times, serif;
			color: rgb(0, 120, 0);
		}

		.failure h2
		{
			font: 20pt Georgia, "Times New Roman", Times, serif;
			color: rgb(120, 0, 0);
		}

		.mysql
		{
			color: rgb(100, 100, 100);
		}

		#footer
		{
			max-width: 760px;
			height: 24px;
			margin: 0 auto;

			background: #176093;

			border-bottom-left-radius: 10px;
			border-bottom-right-radius: 10px;

			-webkit-border-bottom-left-radius: 10px;
			-webkit-border-bottom-right-radius: 10px;

			-moz-border-radius-bottomleft: 10px;
			-moz-border-radius-bottomright: 10px;
		}

	</style>
</head>
<body>

<div id="header">
	<div class="pageWidth"><h1>XenForo System Requirements Test</h1></div>
</div>

<div class="pageWidth">
	<div class="contents">
<?php

$errors = array();

$phpVersion = phpversion();
if (version_compare($phpVersion, '5.2.11', '<'))
{
	$errors['phpVersion'] = 'PHP 5.2.11 or newer is required. ' . $phpVersion . ' does not meet this requirement. Please ask your host to upgrade PHP.';
}

if (@ini_get('safe_mode'))
{
	$errors['safe_mode'] = 'PHP must not be running in safe_mode. Please ask your host to disable the PHP safe_mode setting.';
}

if (!function_exists('mysqli_connect'))
{
	$errors['mysqlPhp'] = 'The required PHP extension MySQLi could not be found. Please ask your host to install this extension.';
}

if (!function_exists('iconv'))
{
	$errors['iconv'] = 'The required PHP extension Iconv could not be found. Please ask your host to install this extension.';
}

if (!function_exists('ctype_alnum'))
{
	$errors['ctype'] = 'The required PHP extension Ctype could not be found. Please ask your host to install this extension.';
}

if (!function_exists('gd_info'))
{
	$errors['gd'] = 'The required PHP extension GD could not be found. Please ask your host to install this extension.';
}
else if (!function_exists('imagecreatefromjpeg'))
{
	$errors['gdJpeg'] = 'The required PHP extension GD was found, but JPEG support is missing. Please ask your host to add support for JPEG images.';
}

if (!function_exists('preg_replace'))
{
	$errors['pcre'] = 'The required PHP extension PCRE could not be found. Please ask your host to install this extension.';
}

if (!function_exists('spl_autoload_register'))
{
	$errors['spl'] = 'The required PHP extension SPL could not be found. Please ask your host to install this extension.';
}

if (!function_exists('json_encode'))
{
	$errors['json'] = 'The required PHP extension JSON could not be found. Please ask your host to install this extension.';
}

if (!class_exists('DOMDocument') || !class_exists('SimpleXMLElement'))
{
	$errors['xml'] = 'The required PHP extensions for XML handling (DOM and SimpleXML) could not be found. Please ask your host to install this extension.';
}

if ($errors)
{
?>
<div class="failure">
	<h2>Requirements Not Met</h2>
	<p>The following XenForo requirements were not met. Please contact your host for help.</p>
	<ol>
	<?php foreach ($errors AS $error) { echo "<li>$error</li>"; } ?>
	</ol>
</div>
<?php
}
else
{
?>
<div class="success">
	<h2>Requirements Met</h2>
	<p>Your server meets all of XenForo's PHP requirements.</p>
</div>
<?php
}

?>
	<p class="mysql">XenForo also requires MySQL 5.0 or newer. Please manually check that you meet this requirement.</p>

	</div>
</div>
<div id="footer"></div>

</body>
</html>