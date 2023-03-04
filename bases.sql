SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


CREATE TABLE `bases` (
  `id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL DEFAULT 'null',
  `attpos` varchar(24) NOT NULL,
  `defpos` varchar(24) NOT NULL,
  `cppos` varchar(24) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `bases`
  ADD PRIMARY KEY (`id`);
COMMIT;