-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- ����: localhost
-- ����� ��������: ��� 10 2012 �., 22:51
-- ������ �������: 5.1.41
-- ������ PHP: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES cp1251 */;

--
-- ���� ������: `sa_api`
--
CREATE DATABASE `sa_api` DEFAULT CHARACTER SET cp1251 COLLATE cp1251_general_ci;
USE `sa_api`;

-- --------------------------------------------------------

--
-- ��������� ������� `applications`
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
-- ���� ������ ������� `applications`
--

INSERT INTO `applications` (`id`, `name`, `thumbURL`, `description`, `secretKey`, `swfURL`) VALUES
(2, '���������', 'http://cs10273.vkontakte.ru/u3461920/d_a63e871f.jpg', '��������� - ������������� ���� ��� ������, ���������� � �������. � ���� ���� ���: �������, ��������, ���, ������, ������, ����, ���������, �������, �����, ��������, ���������, �����, �������, ����. ����� ���� ������!', '4356745677655487', 'http://cs5354.vkontakte.ru/u3461920/6faf42ea8af15e.zip'),
(1, '��� �����', 'http://cs10273.vkontakte.ru/u3461920/d_2854f38d.jpg', '��� ����� - ��������������������� ���������� ���� � ����� "��� � ���". ���������� ���������� � ������������ �� ������� ������!', '4356745677655489', 'http://cs304914.vkontakte.ru/u3461920/af667dbb3e69f0.zip'),
(2656163, '�������� �����', 'http://cs10273.vkontakte.ru/u1102454/d_811034ce.jpg', '���������� ��������������������� ���� � �������� �������, ������������ �� ����������. �� ������� �� ������������� ������� ������ � ������ ������ �������, ������� ������ ���� � ��������� �� �����. ���������� ����� � ������!', 'H5HZoVxym2Ixj00AshoP', 'file:///D:/Projects/Squirrel Client/bin/client_release.swf');

-- --------------------------------------------------------

--
-- ��������� ������� `appusers`
--

CREATE TABLE IF NOT EXISTS `appusers` (
  `userId` int(11) NOT NULL,
  `appId` int(11) NOT NULL,
  `userBalance` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=10 ;

--
-- ���� ������ ������� `appusers`
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
-- ��������� ������� `passwdrecover`
--

CREATE TABLE IF NOT EXISTS `passwdrecover` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `passwd` varchar(32) CHARACTER SET ascii NOT NULL,
  `key` varchar(32) CHARACTER SET ascii NOT NULL,
  `email` varchar(50) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 AUTO_INCREMENT=1 ;

--
-- ���� ������ ������� `passwdrecover`
--


-- --------------------------------------------------------

--
-- ��������� ������� `users`
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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 COMMENT='������� �������������' AUTO_INCREMENT=113100756 ;

--
-- ���� ������ ������� `users`
--

INSERT INTO `users` (`id`, `firstName`, `secondName`, `photoURL`, `gender`, `birthDate`, `passwd`, `regDate`, `email`, `lastAuth`, `sessionSig`) VALUES
(1, 'Andr', 'Zam', 'http://cs9619.vkontakte.ru/u118977583/-6/x_6d7df7a', 0, 2012, 'e10adc3949ba59ab', '2012-01-03 14:40:23', 'scale_@mail.ru', '2012-01-03 14:40:34', ''),
(2, 'Andrey', 'Zamyatki', 'asd', 0, 2012, '123456', '2012-01-03 14:47:27', 'kapany3-88@mail.ru', '0000-00-00 00:00:00', 'dbdbcb3f0f694596dd3265d5d642fd98'),
(7, '������', '', '', 0, 0, 'd8578edf8458ce06fbc5bb76a58c5ca4', '0000-00-00 00:00:00', 'qwerty', '2012-01-07 14:27:52', '1708d58f94f77f50b10737ab8df31fe5'),
(8, '', '', '', 0, 0, 'd41d8cd98f00b204e9800998ecf8427e', '0000-00-00 00:00:00', '', '0000-00-00 00:00:00', '2f16c07dd9aed5a3ae586847284c3d07'),
(113100755, '������', '', 'http://cs4233.vkontakte.ru/u6732360/-6/x_f5ee661b.jpg', 0, 0, '4297f44b13955235245b2497399d7a93', '0000-00-00 00:00:00', '123123', '0000-00-00 00:00:00', '96578012353172d3c2d0079b19c91616'),
(10, '', '', '', 0, 0, '25d55ad283aa400af464c76d713c07ad', '0000-00-00 00:00:00', 'scale!_@mail.ru', '0000-00-00 00:00:00', '7d0e2edcb69bab922bb281df1f60fa09'),
(11, '', '', '', 0, 0, '4ebf1c936dfa037be930f2f4c43ab4a4', '0000-00-00 00:00:00', 'vsekaktotakk@mail.ru', '0000-00-00 00:00:00', '53fc8537b73d857dd1fadb09f59f3270'),
(12, '', '', '', 0, 0, '25d55ad283aa400af464c76d713c07ad', '0000-00-00 00:00:00', 'tirrrr@mail.ru', '0000-00-00 00:00:00', '49c4f160d1fa93a1df897b1ed6603ec0'),
(13, '', '', '', 0, 0, '25d55ad283aa400af464c76d713c07ad', '0000-00-00 00:00:00', 'tir@mail.ru', '0000-00-00 00:00:00', '4fa935760848fb56bb0a86ed554c6d81');

-- --------------------------------------------------------

--
-- ��������� ������� `waitingusers`
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
-- ���� ������ ������� `waitingusers`
--

INSERT INTO `waitingusers` (`id`, `email`, `passwd`, `regKey`) VALUES
(10, 'qwerty1', 'd8578edf8458ce06fbc5bb76a58c5ca4', 'a8705be7aac52a36c037852d065c4265');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
