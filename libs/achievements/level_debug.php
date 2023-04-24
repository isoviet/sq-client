<?php

 define ('URL', 'http://squirrelsa.realcdn.ru/test/fb_rus/achievements/');
 define ('URL_IMG', 'http://squirrelsa.realcdn.ru/test/images/');
 define ('APP_ID', '130880430367150');
 define ('LEVEL_MIN', 2);
 define ('LEVEL_MAX', 155);

for ($level = LEVEL_MIN; $level <= LEVEL_MAX; $level++)
{
	ob_start();

	echo '<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# game: http://ogp.me/ns/game#">' . PHP_EOL;
	echo '<meta property="fb:app_id" content="' . APP_ID . '"/>' . PHP_EOL;
	echo '<meta property="game:points" content="1"/>' . PHP_EOL;
	echo '<meta property="og:type" content="game.achievement" />' . PHP_EOL;
	echo '<meta property="og:url" content="' . URL . 'level' . $level. '.html" />' . PHP_EOL;
	echo '<meta property="og:title"  content="Level '. $level . '"/>' . PHP_EOL;
	echo '<meta property="og:description"  content="I have gained level ' . $level . '!" />' . PHP_EOL;
	echo '<meta property="og:image"  content="'. URL_IMG . 'New_level_' . $level . '.png" />' . PHP_EOL;
	echo '</head>';

	file_put_contents('level'. $level .'.html', ob_get_contents());
	ob_end_clean();
}

?>