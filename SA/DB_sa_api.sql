-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Янв 10 2012 г., 22:51
-- Версия сервера: 5.1.41
-- Версия PHP: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES cp1251 */;

--
-- База данных: `sa_api`
--
CREATE DATABASE `sa_api` DEFAULT CHARACTER SET cp1251 COLLATE cp1251_general_ci;
USE `sa_api`;

-- --------------------------------------------------------

--
-- Структура таблицы `applications`
--

CREATE TABLE IF NOT EXISTS `applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `thumbURL` varchar(60) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `description` text NOT NULL,
  `secretKey` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `swfURL` varchar(60) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=2656164 ;

--
-- Дамп данных таблицы `applications`
--

INSERT INTO `applications` (`id`, `name`, `thumbURL`, `description`, `secretKey`, `swfURL`) VALUES
(2, 'Бутылочка', 'http://cs10273.vkontakte.ru/u3461920/d_a63e871f.jpg', 'Бутылочка - увлекательная игра для флирта, знакомства и общения. В игре есть все: подарки, открытки, чат, дружба, любовь, секс, отношения, поцелуи, парни, девчонки, бутылочка, флирт, эротика, вирт. Найди свою любовь!', '4356745677655487', 'http://cs5354.vkontakte.ru/u3461920/6faf42ea8af15e.zip'),
(1, 'Дар богов', 'http://cs10273.vkontakte.ru/u3461920/d_2854f38d.jpg', 'Дар Богов - многопользовательская казуальная игра в стиле "три в ряд". Побеждайте соперников и поднимайтесь на вершину Олимпа!', '4356745677655489', 'http://cs304914.vkontakte.ru/u3461920/af667dbb3e69f0.zip'),
(2656163, 'Трагедия белок', 'http://cs10273.vkontakte.ru/u1102454/d_811034ce.jpg', 'Динамичная многопользовательская игра с веселыми Белками, спасающимися от катастрофы. Ты бегаешь по разнообразным уровням вместе с толпой других Белочек, пытаясь добыть орех и добраться до дупла. Всемогущий шаман в помощь!', 'H5HZoVxym2Ixj00AshoP', 'file:///D:/Projects/Squirrel Client/bin/client_release.swf');

-- --------------------------------------------------------

--
-- Структура таблицы `appusers`
--

CREATE TABLE IF NOT EXISTS `appusers` (
  `userId` int(11) NOT NULL,
  `appId` int(11) NOT NULL,
  `userBalance` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=10 ;

--
-- Дамп данных таблицы `appusers`
--

INSERT INTO `appusers` (`userId`, `appId`, `userBalance`, `id`) VALUES
(1, 0, 0, 4),
(1, 1, 0, 5),
(9, 6, 0, 6),
(13, 6, 0, 7),
(9, 2656163, 0, 8),
(113100755, 2656163, 0, 9);

-- --------------------------------------------------------

--
-- Структура таблицы `passwdrecover`
--

CREATE TABLE IF NOT EXISTS `passwdrecover` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `passwd` varchar(32) CHARACTER SET ascii NOT NULL,
  `key` varchar(32) CHARACTER SET ascii NOT NULL,
  `email` varchar(50) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 AUTO_INCREMENT=1 ;

--
-- Дамп данных таблицы `passwdrecover`
--


-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `firstName` varchar(20) NOT NULL,
  `secondName` varchar(20) NOT NULL,
  `photoURL` varchar(150) CHARACTER SET ascii NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `birthDate` int(11) NOT NULL,
  `passwd` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `regDate` datetime NOT NULL,
  `email` varchar(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `lastAuth` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `sessionSig` varchar(32) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 COMMENT='Таблица пользователей' AUTO_INCREMENT=113100756 ;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `firstName`, `secondName`, `photoURL`, `gender`, `birthDate`, `passwd`, `regDate`, `email`, `lastAuth`, `sessionSig`) VALUES
(1, 'Andr', 'Zam', 'http://cs9619.vkontakte.ru/u118977583/-6/x_6d7df7a', 0, 2012, 'e10adc3949ba59ab', '2012-01-03 14:40:23', 'scale_@mail.ru', '2012-01-03 14:40:34', ''),
(2, 'Andrey', 'Zamyatki', 'asd', 0, 2012, '123456', '2012-01-03 14:47:27', 'kapany3-88@mail.ru', '0000-00-00 00:00:00', 'dbdbcb3f0f694596dd3265d5d642fd98'),
(7, 'анжрей', '', '', 0, 0, 'd8578edf8458ce06fbc5bb76a58c5ca4', '0000-00-00 00:00:00', 'qwerty', '2012-01-07 14:27:52', '1708d58f94f77f50b10737ab8df31fe5'),
(8, '', '', '', 0, 0, 'd41d8cd98f00b204e9800998ecf8427e', '0000-00-00 00:00:00', '', '0000-00-00 00:00:00', '2f16c07dd9aed5a3ae586847284c3d07'),
(113100755, 'Дрейко', '', 'http://cs4233.vkontakte.ru/u6732360/-6/x_f5ee661b.jpg', 0, 0, '4297f44b13955235245b2497399d7a93', '0000-00-00 00:00:00', '123123', '0000-00-00 00:00:00', '96578012353172d3c2d0079b19c91616'),
(10, '', '', '', 0, 0, '25d55ad283aa400af464c76d713c07ad', '0000-00-00 00:00:00', 'scale!_@mail.ru', '0000-00-00 00:00:00', '7d0e2edcb69bab922bb281df1f60fa09'),
(11, '', '', '', 0, 0, '4ebf1c936dfa037be930f2f4c43ab4a4', '0000-00-00 00:00:00', 'vsekaktotakk@mail.ru', '0000-00-00 00:00:00', '53fc8537b73d857dd1fadb09f59f3270'),
(12, '', '', '', 0, 0, '25d55ad283aa400af464c76d713c07ad', '0000-00-00 00:00:00', 'tirrrr@mail.ru', '0000-00-00 00:00:00', '49c4f160d1fa93a1df897b1ed6603ec0'),
(13, '', '', '', 0, 0, '25d55ad283aa400af464c76d713c07ad', '0000-00-00 00:00:00', 'tir@mail.ru', '0000-00-00 00:00:00', '4fa935760848fb56bb0a86ed554c6d81');

-- --------------------------------------------------------

--
-- Структура таблицы `waitingusers`
--

CREATE TABLE IF NOT EXISTS `waitingusers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `passwd` varchar(32) CHARACTER SET armscii8 COLLATE armscii8_bin NOT NULL,
  `regKey` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=16 ;

--
-- Дамп данных таблицы `waitingusers`
--

INSERT INTO `waitingusers` (`id`, `email`, `passwd`, `regKey`) VALUES
(10, 'qwerty1', 'd8578edf8458ce06fbc5bb76a58c5ca4', 'a8705be7aac52a36c037852d065c4265');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
