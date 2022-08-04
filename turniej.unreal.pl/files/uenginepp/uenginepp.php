<?php
	echo "------------------------------------------\n";
	echo "         UnralEngine PreProcessor         \n";
	echo "------------------------------------------\n";
	echo " Version : 0.1.0\n";
	echo " Build   : 24.08.2008\n";
	echo "------------------------------------------\n";

	include_once("print_help.php");
	include_once("execution_time.php");

	function print_globals($garray)
	{
		if(!is_array($garray))
		{
			$return = "The provided variable is not an array.";
		}
		else
		{
			foreach($garray as $name=>$value)
			{
				if(!is_array($value))
				{
     			                $return .= " ".$name." = ".$value."\n";
				}
			}
		}
		echo "------------------------------------------\n";
		echo " Globals: \n\n";
		echo $return;
	}

	function IsDir2($dir)
	{
		$pos =  strlen($dir);
		if(substr($dir, $pos-1) == "/" ) return $dir;
		else return $dir."/";
	}
	function IsUC($file)
	{
                $ext = pathinfo($file);
                if($ext["extension"] == "uc") return true;
                else return false;
	}

	start_count();

	$project_file = null;
	$project = null;
	$debug = false;
	$make = false;
	$make_ini = null;
	$strip = false;
	$silent = false;
	$clean = false;
	$globalsdef = array();
	$global_found = false;
	$printglobals = false;
	//process argument list
	while( list($nr,$val) = each($argv) )
	{
		if($nr > 0)
		{
			if(strtolower($val) == "-h")
			{
				print_help();
				exit;
			}
			if($nr == 1)
			{
				//we're using project file file !!
				if( strpos($val,'.upc') >-1 )
				{
					$project_file = $val;
					break;
				}
				else
				{
					$project = $val;
				}
			}
			if($make && $make_ini == null) $make_ini = $val;
			if($global_found)
			{
				$global_found = false;
				if(eregi("=", $val))
				{
					$gls = explode("=",$val);
					$globalsdef[trim($gls[0])] = $gls[1];
				}
				else
				{
					$globalsdef[$val] = "null";
				}
			}
			if(strtolower($val) == "-debug") $debug = true;
			if(strtolower($val) == "-make") $make = true;
			if(strtolower($val) == "-silent") $silent = true;
			if(strtolower($val) == "-clean") $clean = true;
			if(strtolower($val) == "-global") $global_found = true;
			if(strtolower($val) == "-printglobals") $printglobals = true;
		}
	}
	// if no arguments are not specified we have to print help and exit
	if(count($argv) <= 0)
	{
		print_help();
		exit;
	}
	//prints project details
	if($project_file != null)
	{
		echo " Using project definition: ".$project_file.".\n";	//project file
		if(!file_exists($project_file))
		{
			echo " ERROR: project file not found";
			exit;
		}
		$main = parse_ini_file($project_file, true);
		$vars = $main['project'];
		$project = ( !empty($vars['path']) ) ? $vars['path'] : null;
		$debug = ( !empty($vars['debug']) ) ? $vars['debug'] : false;
		$silent = ( !empty($vars['silent']) ) ? $vars['silent'] : false;
		$make = ( !empty($vars['make']) ) ? $vars['make'] : false;
		$clean = ( !empty($vars['clean']) ) ? $vars['clean'] : false;
		$make_ini = ( !empty($vars['make_ini']) ) ? $vars['make_ini'] : "";
		$output_dir = ( !empty($vars['output']) ) ? $vars['output'] : 'classes';
		$input_dir = ( !empty($vars['input']) ) ? $vars['input'] : 'classes_ucp';
		$printglobals = ( !empty($vars['printglobals']) ) ? $vars['clean'] : false;
		if(array_key_exists('globals', $main)) $globalsdef = $main['globals'];
	}
	if($project != null)
		echo " Using project directory ".$project.".\n"; //project folder
	else
	{
		echo " ERROR: directory not specified";
		exit();
	}
	//debug mode
	echo " Debug mode: ";
	if( $debug )
		echo "on.\n";
	else
		echo "off.\n";
	//make ini
	if($make)
		echo " Run ucc make with ".$make_ini."\n";
		
	if($printglobals && is_array($globalsdef)) print_globals($globalsdef);

	echo "------------------------------------------\n";
	
	$silent = true;
	include("process_file.php");

	echo "------------------------------------------\n";
	echo $file_cnt." uc files found.\n";
	echo $file_pr." uc files parsed.\n";
	stop_count();
	$exec_time = calculate_time();
	echo "Execution time: ";
	printf("%0.2f", $exec_time);
	echo " seconds.";
	
	if($make && file_exists("./uenginepp.ini"))
	{
		$options = parse_ini_file("./uenginepp.ini");
		if( IsSet($option['ucc_dir']) && file_exists(IsDir2($option['ucc_dir'])."ucc.exe") )
		{
                        $param = ( $make_ini != "" ) ? " make ini=".IsDir2($project).$make_ini : " make";
			$_cmd = IsDir2($option['ucc_dir'])."ucc.exe".$param;
			echo "\n------------------------------------------\n";
			echo " Executing: ".$_cmd."\n";
			system($_cmd);
		}
		else
		{
			$_ucc = "ucc.exe";
			$param = ( $make_ini != "" ) ? " make ini=".IsDir2($project).$make_ini : " make";
			if(file_exists($dir_ucc."ucc.exe"))
			{
				$_cmd = $_ucc.$param;
				echo "\n------------------------------------------\n";
				echo " Executing: ".$_cmd."\n";
				system($_cmd);
			}
		}
	}
	else if($make)
	{
		$_ucc = "ucc.exe";
		$param = ( $make_ini != "" ) ? " make ini=".IsDir2($project).$make_ini : " make";
		if(file_exists($dir_ucc."ucc.exe"))
		{
			$_cmd = $_ucc.$param;
			echo "\n------------------------------------------\n";
			echo " Executing: ".$_cmd."\n";
			system($_cmd);
		}
	}
?>