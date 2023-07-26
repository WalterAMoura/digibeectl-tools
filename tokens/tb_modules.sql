-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 28/03/2023 às 23:57
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
-- Estrutura para tabela `tb_modules`
--

CREATE TABLE `tb_modules` (
  `id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `module` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `path_module` varchar(255) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `type_id` int(11) NOT NULL,
  `current` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `tb_modules`
--

INSERT INTO `tb_modules` (`id`, `created_at`, `module`, `label`, `icon`, `path_module`, `updated_at`, `type_id`, `current`) VALUES
(1, '2023-03-27 11:58:15', 'home', 'Home', 'fas  fa-home', '/home', '2023-03-28 00:03:29', 1, NULL),
(2, '2023-03-27 11:58:15', 'event', 'Agenda', 'fas  fa-calendar-alt', '/event', '2023-03-28 00:03:31', 1, NULL),
(3, '2023-03-27 11:59:53', 'users', 'Usuários', 'fas  fa-users', '/users', '2023-03-28 00:03:33', 1, NULL),
(4, '2023-03-27 11:59:53', 'config-event', 'Configurações Evento', 'fas fa-cog', '/config-event', '2023-03-28 00:03:34', 1, NULL),
(5, '2023-03-27 11:59:53', 'config-app', 'Configurações Aplicação', 'fas fa-cogs', '/config-app', '2023-03-28 00:03:35', 1, NULL),
(7, '2023-03-27 11:59:53', 'btn-manager-event', 'Gestão Eventos', 'null', 'null', '2023-03-28 00:28:15', 2, NULL),
(8, '2023-03-27 11:59:53', 'btn-cadastrar-user', 'Cadastrar Usuários', 'null', 'null', '2023-03-28 00:28:15', 2, NULL),
(9, '2023-03-27 11:59:53', 'btn-edit-user', 'Editar Usuário', 'null', 'null', '2023-03-28 00:28:15', 2, NULL),
(10, '2023-03-27 11:59:53', 'btn-delete-user', 'Excluir Usuário', 'null', 'null', '2023-03-28 00:28:15', 2, NULL),
(11, '2023-03-27 11:59:53', 'page-manager-event', 'Página Gestão Eventos', 'null', 'null', '2023-03-28 18:54:59', 3, NULL),
(12, '2023-03-27 11:59:53', 'page-manager-user', 'Página Gestão Usuários', 'null', 'null', '2023-03-28 00:28:15', 3, NULL),
(13, '2023-03-27 11:59:53', 'tab-pane-status-event', 'Status Eventos', 'null', '#dadosStatusEvents', '2023-03-28 19:13:02', 4, 'true'),
(14, '2023-03-27 11:59:53', 'page-config-event', 'Página Configuração Eventos', 'null', 'null', '2023-03-28 00:28:15', 3, NULL),
(15, '2023-03-27 11:59:53', 'tab-pane-department', 'Departamentos', 'null', '#dadosDepartamentos', '2023-03-28 19:13:02', 4, 'false'),
(16, '2023-03-27 11:59:53', 'tab-pane-program', 'Programas/Eventos Especiais', 'null', '#dadosProgramas', '2023-03-28 19:13:02', 4, 'false'),
(17, '2023-03-27 11:59:53', 'tab-pane-elder', 'Ancionato', 'null', '#dadosAncionato', '2023-03-28 19:13:02', 4, 'false'),
(18, '2023-03-27 11:59:53', 'tab-pane-elder-month', 'Ancião do Mês', 'null', '#dadosAnciaoMes', '2023-03-28 19:13:02', 4, 'false'),
(20, '2023-03-28 23:26:20', 'tab-pane-level', 'Nivel', 'null', '#dadosNivel', '2023-03-28 23:26:23', 5, NULL),
(21, '2023-03-28 23:33:27', 'page-config-app', 'Página Configuração App', 'null', 'null', '2023-03-28 23:33:27', 3, NULL);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `tb_modules`
--
ALTER TABLE `tb_modules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `module` (`module`),
  ADD KEY `type_id` (`type_id`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `tb_modules`
--
ALTER TABLE `tb_modules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `tb_modules`
--
ALTER TABLE `tb_modules`
  ADD CONSTRAINT `type_id` FOREIGN KEY (`type_id`) REFERENCES `tb_type_module` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
