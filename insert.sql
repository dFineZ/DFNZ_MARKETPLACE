CREATE TABLE `marketplace` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) DEFAULT NULL,
  `item` varchar(50) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL
  PRIMARY KEY (id)
);
