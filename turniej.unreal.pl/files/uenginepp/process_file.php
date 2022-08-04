<?php

	function CheckType($value)
	{
		if(is_string($value)) return (string) $value;
		else if(is_float($value)) return (float) $value;
		else if(is_int($value)) return (int) $value;
	}
	/**
	   searches for keys. priority
	   1. Global values
	   2. defined values
	   3. if no value in global and defined array is found, wee have to assume that key is value

	*/
	function CheckKey($keyx)
	{
		global $define, $globalsdef;
		if( array_key_exists($keyx, $globalsdef) )
			return $globalsdef[$keyx];
		else if( array_key_exists($keyx, $define) )
			return $define[$keyx];
		else
			return $keyx;
	}

	function KeyExists($keyx)
	{
		global $define, $globalsdef;
		if( array_key_exists($keyx, $globalsdef) )
			return true;
		else if( array_key_exists($keyx, $define) )
			return true;
		else
			return false;
	}

	$input_dir=IsDir2($project).IsDir2($input_dir);
	$output_dir=IsDir2($project).IsDir2($output_dir);
	$dir=opendir($input_dir);
	$file_cnt=0;
	$file_pr=0;
	$bln[0] = "false";
	$bln[1] = "true";
	while ($input=readdir($dir))
	{
		if(!is_dir($input) && IsUC($input))
		{
			$file_cnt++;
			if(!$silent) echo "Processing file: ".$input."...";
			$handle = file($input_dir.$input);
			if( eregi("`process", $handle[0]) )
			{
				$file_pr++;
				$handle[0] = str_replace("`process", '//`#process', $handle[0]);
				if($silent) echo "Processing file: ".$input."...";
				if($debug)
				{
					echo "\n";
				}
				if(is_array($define))
				{
					unset($define);
				}
				$define = array();
				$nested = 0;
				$process_nested = false;

				for($i=0; $i<count($handle); $i++)
				{
					if( eregi("`process", $handle[$i]) && !eregi('`#',$handle[$i]) )
					{
						$handle[$i] = str_replace('`','`#', $handle[$i]);
						if(!$clean)
							$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
					}
					//ifdef directive
					if (preg_match('/`ifdef (.*)/', $handle[$i], $m) && !eregi('`#',$handle[$i]))
					{
						$vls = trim($m[1]);
						$nested ++;
						if( KeyExists($vls) ) $process_nested = true;
						$handle[$i] = str_replace('`','`#', $handle[$i]);
						if(!$clean)
							$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
						if($debug) echo "...directive `ifdef found\n......evaluates to ".$bln[$process_nested].". Nest level: ".$nested."\n";
					}
					//ifndef directive
					if (preg_match('/`ifndef (.*)/', $handle[$i], $m) && !eregi('`#',$handle[$i]))
					{
						$vls = trim($m[1]);
						$nested ++;
						if(!KeyExists($vls)) $process_nested = true;
						$handle[$i] = str_replace('`','`#', $handle[$i]);
						if(!$clean)
							$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
						if($debug) echo "...directive `ifndef found\n......evaluates to ".$bln[$process_nested].". Nest level:  ".$nested."\n";
					}
					//eval directive
					if (preg_match('/`check (.*)/', $handle[$i], $m) && !eregi('`#',$handle[$i]))
					{
						$vls = trim($m[1]);

						if(eregi("==", $vls))
						{
							$values = explode("==",$vls);
							$first = trim($values[0]);
							$second = trim($values[1]);
//							$first = ( !empty($define[$first]) ) ? $define[$first] : $first;
//							$second = ( !empty($define[$second]) ) ? $define[$second] : $second;
							$first = CheckKey($first);
							$second = CheckKey($second);
							$nested ++;
							if(CheckType($first) == CheckType($second))
							{
								$process_nested = true;
							}
						}
						else if(eregi("<>", $vls))
						{
							$values = explode("<>",$vls);
							$first = trim($values[0]);
							$second = trim($values[1]);
//							$first = ( !empty($define[$first]) ) ? $define[$first] : $first;
//							$second = ( !empty($define[$second]) ) ? $define[$second] : $second;
							$first = CheckKey($first);
							$second = CheckKey($second);
							$nested ++;
							if(CheckType($first) != CheckType($second))
							{
								$process_nested = true;
							}
						}
						else if(eregi(">", $vls))
						{
							$values = explode(">",$vls);
							$first = trim($values[0]);
							$second = trim($values[1]);
//							$first = ( !empty($define[$first]) ) ? $define[$first] : $first;
//							$second = ( !empty($define[$second]) ) ? $define[$second] : $second;
							$first = CheckKey($first);
							$second = CheckKey($second);
							$nested ++;
							if(CheckType($first) > CheckType($second))
							{
								$process_nested = true;
							}
						}
						else if(eregi("<", $vls))
						{
							$values = explode("<",$vls);
							$first = trim($values[0]);
							$second = trim($values[1]);
//							$first = ( !empty($define[$first]) ) ? $define[$first] : $first;
//							$second = ( !empty($define[$second]) ) ? $define[$second] : $second;
							$first = CheckKey($first);
							$second = CheckKey($second);
							$nested ++;
							if(CheckType($first) < CheckType($second))
							{
								$process_nested = true;
							}
						}
						$handle[$i] = str_replace('`','`#', $handle[$i]);
						if(!$clean)
							$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
						if($debug) echo "...directive `check found\n......evaluates to ".$bln[$process_nested].". Nest level:  ".$nested."\n";
					}

					//else directive
					if( eregi("`else", $handle[$i]) && !eregi('`#',$handle[$i]))
					{
						$vls = trim($m[1]);
						if($nested > 0)
						{
							$process_nested = !$process_nested;
							if($debug) echo "...directive `else found\n......evaluates to ".$bln[$process_nested].". Nest level:  ".$nested."\n";
						}
						$handle[$i] = str_replace('`','`#', $handle[$i]);
						if(!$clean)
							$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
					}
					//endif directive
					if( eregi("`endif", $handle[$i]) && !eregi('`#',$handle[$i]))
					{
						if($nested > 0)
						{
							$nested --;
							$process_nested = false;
							if($debug) echo "...directive `endif found...nest level: ".$nested."\n";
						}
						$handle[$i] = str_replace('`','`#', $handle[$i]);
						if(!$clean)
							$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
					}
					if( $nested > 0 && !$process_nested )
					{
						//we're deleting some directives
						if( eregi("`inc_process", $handle[$i]) || eregi("`include", $handle[$i]) || eregi("`define", $handle[$i]) || eregi("`write", $handle[$i]) )
						{
							if($debug) echo "...directive skipped: statement evaluates to false \n";
							$handle[$i] = str_replace('`','`#', $handle[$i]);
							if(!$clean)
								$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
						}
						else
						{
							if($debug) echo "...code deleted: statement evaluates to false \n";
							$handle[$i] = str_replace('`','`#', $handle[$i]);
							if(!$clean)
								$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
						}
					}
					if($nested == 0 || $process_nested)
					{

						// support for directive 'include
						if( eregi("`include", $handle[$i]) && !eregi('`#',$handle[$i])  )
						{
							if($debug) echo "...directive `include found\n";

							$str = str_replace('`include', '', $handle[$i]);
							// comments out directive
							$handle[$i] = str_replace('`','`#', $handle[$i]);
							if(!$clean)
								$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
							$str = IsDir2($project).trim($str);
							if($debug) echo "......embedding file '".$str."'\n";
							if( file_exists($str) )
							{
								//lets start including :)
								$source = file($str);
								$source[count($source)+1]="\n";
								$first_part = array();
								for($j=0; $j<$i; $j++)
								{
									$first_part[$j] = $handle[$j];
								}
								$second_part = array();
								for($j=$i; $j<count($handle); $j++)
								{
									$second_part[$j] = $handle[$j];
								}
								$handle = array_merge($first_part, $source, $second_part);
								$i += count($source);
								echo ".........successful\n";
							}
							else if($debug) echo ".........failed\n";

						}
						// support for directive 'include
						if( eregi("`inc_process", $handle[$i]) && !eregi('`#',$handle[$i])  )
						{
							if($debug) echo "...directive `inc_process found\n";

							$str = str_replace('`inc_process', '', $handle[$i]);
							// comments out directive
							$handle[$i] = str_replace('`','`#', $handle[$i]);
							if(!$clean)
								$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);
							$str = IsDir2($project).trim($str);
							if($debug) echo "......embedding file '".$str."'\n";
							if( file_exists($str) )
							{
								//lets start including :)
								$source = file($str);
								$source[count($source)+1]="\n";
								$first_part = array();
								for($j=0; $j<$i; $j++)
								{
									$first_part[$j] = $handle[$j];
								}
								$second_part = array();
								for($j=$i; $j<count($handle); $j++)
								{
									$second_part[$j] = $handle[$j];
								}
								$handle = array_merge($first_part, $source, $second_part);
								echo ".........successful\n";
							}
							else if($debug) echo ".........failed\n";

						}
						// support for directive 'define
						if(preg_match('/(`define .*)/', $handle[$i], $matches) && !eregi('`#',$handle[$i]) )
						{
							for($k=0; $k<count($matches); $k++)
							{
						        	$matches[$k] = preg_replace('/`define/', '', $matches[$k]);
						 	}
				 		 	if(eregi("=", $matches[0]))
							{
								$def_val = explode("=",$matches[0]);
								$define[trim($def_val[0])] = trim($def_val[1]);
								echo "...directive `define found ('".trim($def_val[0])."' = ".trim($def_val[1]).")\n";
							}
							else
							{
						 		$define[trim($matches[0])] = "null";
							 	echo "...directive `define found (".trim($matches[0]).")\n";
							}
							$handle[$i] = str_replace('`','`#', $handle[$i]);
							if(!$clean)
								$handle[$i] = str_replace($handle[$i],'//'.$handle[$i], $handle[$i]);

						}
						if( eregi("`write", $handle[$i]) && !eregi('`#',$handle[$i])  )
						{
							if($debug) echo "...directive `write found\n";
							$str = str_replace('`write', '', $handle[$i]);
							$str = trim($str);
							if(CheckKey($str) != "")
							{
								if($debug) echo "......definition '".$str."' found (".CheckKey($str).")\n";
								$add_pt = "";
								if(!$clean)
								{
									$handle[$i] = str_replace('`','`#', $handle[$i]);
									$add_pt = " //".$handle[$i];
								}
								else
									$add_pt .= "\n";
								$out = $define[$str].$add_pt;
								$handle[$i] = $out;
							}
							else if($debug)
								echo "...definition '".$str."' can not be found";
						}
					}
				}
				$cur = fopen($output_dir.$input, 'w', true);
				if($debug) echo "...saving file: ".$output_dir.$input."\n";
				foreach($handle as $key => $value)
				{
					if(!$clean)
					{
						if(!fwrite($cur, $value))
							echo "...error saving data in resource ".$cur." (".get_resource_type($cur).").\n";
					}
					else if( $clean && !eregi("`#", $value) )
					{
						if(!fwrite($cur, $value))
							echo "...error saving data in resource ".$cur." (".get_resource_type($cur).").\n";
					}
				}
				fclose($cur);
				if($debug)
					echo "...finished\n";
				else
					echo "finished\n";
			}
			else
			{
				$cur = fopen($output_dir.$input, 'w', true);
				foreach($handle as $key => $value)
				{
					fwrite($cur, $value);
				}
				fclose($cur);
				if(!$silent) echo "preprocessor header not found.\n";
			}
		}
	}
?>