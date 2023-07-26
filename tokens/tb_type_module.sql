-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 28/03/2023 às 23:56
-- Versão do servidor: 10.6.12-MariaDB-0ubuntu0.22.04.1
-- Versão do PHP: 8.2.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `u301289665_agenda`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `tb_type_module`
--

CREATE TABLE `tb_type_module` (
  `id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `type` varchar(255) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `tb_type_module`
--

INSERT INTO `tb_type_module` (`id`, `created_at`, `type`, `updated_at`) VALUES
(1, '2023-03-27 21:02:04', 'menu', '2023-03-28 00:02:41'),
(2, '2023-03-27 21:02:04', 'button', '2023-03-28 00:02:41'),
(3, '2023-03-28 15:36:56', 'page', '2023-03-28 18:37:12'),
(4, '2023-03-28 15:36:56', 'tab-pane', '2023-03-28 18:37:12'),
(5, '2023-03-28 15:36:56', 'tab-pane-config-app', '2023-03-28 18:37:12');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `tb_type_module`
--
ALTER TABLE `tb_type_module`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `tb_type_module`
--
ALTER TABLE `tb_type_module`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
