<?php
	function print_help()
	{
		if(file_exists("embed_readme.txt"))
		{
			$content = file("embed_readme.txt");
			for($i=0; $i<count($content); $i++)
				echo $content[$i];
		}
		else
			echo "ReamMe file can not be found.";
	}
?>