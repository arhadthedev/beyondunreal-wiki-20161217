<?php
$StartTime = 0.0;
$EndTime = 0.0;

function start_count()
{
	global $StartTime;
	$iMicrotime = microtime();
	$iMicrotime = explode(' ', $iMicrotime);
	$StartTime = $iMicrotime[1] + $iMicrotime[0];
}

function stop_count()
{
	global $EndTime;
	$iMicrotime = microtime();
	$iMicrotime = explode(' ', $iMicrotime);
	$EndTime = $iMicrotime[1] + $iMicrotime[0];
}

function calculate_time()
{
	global $EndTime, $StartTime;
	return ($EndTime - $StartTime);
}
?>