CREATE TABLE IF NOT EXISTS `inventories` (
  `id` varchar(100) NOT NULL DEFAULT '',
  `data` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
