-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema food_delivery_db
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `food_delivery_db` ;

-- -----------------------------------------------------
-- Schema food_delivery_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `food_delivery_db` DEFAULT CHARACTER SET utf8 ;
USE `food_delivery_db` ;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`utente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`utente` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`utente` (
  `idUtente` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `cognome` VARCHAR(45) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `dataNascita` DATE NULL,
  `dataRegistrazione` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `stato` ENUM('attivo', 'sospeso', 'disattivato') NOT NULL DEFAULT 'attivo',
  PRIMARY KEY (`idUtente`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  UNIQUE INDEX `telefono_UNIQUE` (`telefono` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`indirizzo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`indirizzo` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`indirizzo` (
  `idIndirizzo` INT NOT NULL AUTO_INCREMENT,
  `via` VARCHAR(100) NOT NULL,
  `civico` VARCHAR(10) NOT NULL,
  `cap` VARCHAR(10) NOT NULL,
  `citta` VARCHAR(45) NOT NULL,
  `provincia` VARCHAR(45) NOT NULL,
  `nazione` VARCHAR(45) NOT NULL DEFAULT 'Italia',
  `latitudine` DECIMAL(10,8) NULL,
  `longitudine` DECIMAL(11,8) NULL,
  `note` TEXT NULL,
  PRIMARY KEY (`idIndirizzo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`utente_indirizzo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`utente_indirizzo` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`utente_indirizzo` (
  `idUtente` INT NOT NULL,
  `idIndirizzo` INT NOT NULL,
  `etichetta` VARCHAR(45) NULL DEFAULT 'Casa',
  `predefinito` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`idUtente`, `idIndirizzo`),
  INDEX `fk_utente_indirizzo_indirizzo1_idx` (`idIndirizzo` ASC) VISIBLE,
  CONSTRAINT `fk_utente_indirizzo_utente1`
    FOREIGN KEY (`idUtente`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_utente_indirizzo_indirizzo1`
    FOREIGN KEY (`idIndirizzo`)
    REFERENCES `food_delivery_db`.`indirizzo` (`idIndirizzo`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`ristorante`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`ristorante` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`ristorante` (
  `idRistorante` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `descrizione` TEXT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `sitoWeb` VARCHAR(100) NULL,
  `orarioApertura` TIME NOT NULL,
  `orarioChiusura` TIME NOT NULL,
  `giorniApertura` VARCHAR(45) NOT NULL DEFAULT 'Lun-Dom',
  `tempoConsegnaMedio` INT NOT NULL DEFAULT 30,
  `costoConsegnaBase` DECIMAL(5,2) NOT NULL DEFAULT 2.50,
  `ordineMinimo` DECIMAL(5,2) NOT NULL DEFAULT 10.00,
  `stato` ENUM('attivo', 'sospeso', 'chiuso') NOT NULL DEFAULT 'attivo',
  `dataRegistrazione` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idIndirizzo` INT NOT NULL,
  `idProprietario` INT NOT NULL,
  `tipoCucina` VARCHAR(100) NULL COMMENT 'Tipo di cucina (italiana, giapponese, etc.)',
  PRIMARY KEY (`idRistorante`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  INDEX `fk_ristorante_indirizzo1_idx` (`idIndirizzo` ASC) VISIBLE,
  INDEX `fk_ristorante_utente1_idx` (`idProprietario` ASC) VISIBLE,
  CONSTRAINT `fk_ristorante_indirizzo1`
    FOREIGN KEY (`idIndirizzo`)
    REFERENCES `food_delivery_db`.`indirizzo` (`idIndirizzo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ristorante_utente1`
    FOREIGN KEY (`idProprietario`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`prodotto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`prodotto` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`prodotto` (
  `idProdotto` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `descrizione` TEXT NULL,
  `prezzo` DECIMAL(6,2) NOT NULL,
  `disponibile` TINYINT NOT NULL DEFAULT 1,
  `categoria` VARCHAR(45) NOT NULL COMMENT 'Categoria del prodotto (antipasto, primo, dessert, etc.)',
  `idRistorante` INT NOT NULL,
  PRIMARY KEY (`idProdotto`),
  INDEX `fk_prodotto_ristorante1_idx` (`idRistorante` ASC) VISIBLE,
  CONSTRAINT `fk_prodotto_ristorante1`
    FOREIGN KEY (`idRistorante`)
    REFERENCES `food_delivery_db`.`ristorante` (`idRistorante`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`metodo_pagamento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`metodo_pagamento` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`metodo_pagamento` (
  `idMetodoPagamento` INT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('carta_credito', 'paypal', 'contanti', 'buoni_pasto') NOT NULL,
  `titolare` VARCHAR(100) NULL,
  `numeroMascherato` VARCHAR(45) NULL,
  `tokenPagamento` VARCHAR(255) NULL,
  `predefinito` TINYINT NOT NULL DEFAULT 0,
  `idUtente` INT NOT NULL,
  PRIMARY KEY (`idMetodoPagamento`),
  INDEX `fk_metodo_pagamento_utente1_idx` (`idUtente` ASC) VISIBLE,
  CONSTRAINT `fk_metodo_pagamento_utente1`
    FOREIGN KEY (`idUtente`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`rider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`rider` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`rider` (
  `idRider` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `cognome` VARCHAR(45) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `dataNascita` DATE NOT NULL,
  `tipoVeicolo` ENUM('bicicletta', 'scooter', 'auto') NOT NULL,
  `targaVeicolo` VARCHAR(20) NULL,
  `statoAttivita` ENUM('disponibile', 'in_consegna', 'offline') NOT NULL DEFAULT 'offline',
  `dataRegistrazione` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idIndirizzo` INT NOT NULL,
  PRIMARY KEY (`idRider`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  UNIQUE INDEX `telefono_UNIQUE` (`telefono` ASC) VISIBLE,
  INDEX `fk_rider_indirizzo1_idx` (`idIndirizzo` ASC) VISIBLE,
  CONSTRAINT `fk_rider_indirizzo1`
    FOREIGN KEY (`idIndirizzo`)
    REFERENCES `food_delivery_db`.`indirizzo` (`idIndirizzo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`stato_ordine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`stato_ordine` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`stato_ordine` (
  `idStatoOrdine` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `descrizione` TEXT NULL,
  PRIMARY KEY (`idStatoOrdine`),
  UNIQUE INDEX `nome_UNIQUE` (`nome` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`ordine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`ordine` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`ordine` (
  `idOrdine` INT NOT NULL AUTO_INCREMENT,
  `dataOrdine` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `costoTotale` DECIMAL(8,2) NOT NULL,
  `costoConsegna` DECIMAL(5,2) NOT NULL,
  `ivaApplicata` DECIMAL(4,2) NOT NULL DEFAULT 10.00,
  `note` TEXT NULL,
  `dataConsegnaPrevista` DATETIME NULL,
  `dataConsegnaEffettiva` DATETIME NULL,
  `idUtente` INT NOT NULL,
  `idRistorante` INT NOT NULL,
  `idIndirizzoConsegna` INT NOT NULL,
  `idMetodoPagamento` INT NOT NULL,
  `idRider` INT NULL,
  `idStatoOrdine` INT NOT NULL,
  PRIMARY KEY (`idOrdine`),
  INDEX `fk_ordine_utente1_idx` (`idUtente` ASC) VISIBLE,
  INDEX `fk_ordine_ristorante1_idx` (`idRistorante` ASC) VISIBLE,
  INDEX `fk_ordine_indirizzo1_idx` (`idIndirizzoConsegna` ASC) VISIBLE,
  INDEX `fk_ordine_metodo_pagamento1_idx` (`idMetodoPagamento` ASC) VISIBLE,
  INDEX `fk_ordine_rider1_idx` (`idRider` ASC) VISIBLE,
  INDEX `fk_ordine_stato_ordine1_idx` (`idStatoOrdine` ASC) VISIBLE,
  CONSTRAINT `fk_ordine_utente1`
    FOREIGN KEY (`idUtente`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ordine_ristorante1`
    FOREIGN KEY (`idRistorante`)
    REFERENCES `food_delivery_db`.`ristorante` (`idRistorante`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ordine_indirizzo1`
    FOREIGN KEY (`idIndirizzoConsegna`)
    REFERENCES `food_delivery_db`.`indirizzo` (`idIndirizzo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ordine_metodo_pagamento1`
    FOREIGN KEY (`idMetodoPagamento`)
    REFERENCES `food_delivery_db`.`metodo_pagamento` (`idMetodoPagamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ordine_rider1`
    FOREIGN KEY (`idRider`)
    REFERENCES `food_delivery_db`.`rider` (`idRider`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ordine_stato_ordine1`
    FOREIGN KEY (`idStatoOrdine`)
    REFERENCES `food_delivery_db`.`stato_ordine` (`idStatoOrdine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`dettaglio_ordine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`dettaglio_ordine` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`dettaglio_ordine` (
  `idDettaglioOrdine` INT NOT NULL AUTO_INCREMENT,
  `quantita` INT NOT NULL DEFAULT 1,
  `prezzoUnitario` DECIMAL(6,2) NOT NULL,
  `note` TEXT NULL,
  `idOrdine` INT NOT NULL,
  `idProdotto` INT NOT NULL,
  PRIMARY KEY (`idDettaglioOrdine`),
  INDEX `fk_dettaglio_ordine_ordine1_idx` (`idOrdine` ASC) VISIBLE,
  INDEX `fk_dettaglio_ordine_prodotto1_idx` (`idProdotto` ASC) VISIBLE,
  CONSTRAINT `fk_dettaglio_ordine_ordine1`
    FOREIGN KEY (`idOrdine`)
    REFERENCES `food_delivery_db`.`ordine` (`idOrdine`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_dettaglio_ordine_prodotto1`
    FOREIGN KEY (`idProdotto`)
    REFERENCES `food_delivery_db`.`prodotto` (`idProdotto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`recensione_ristorante`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`recensione_ristorante` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`recensione_ristorante` (
  `idRecensioneRistorante` INT NOT NULL AUTO_INCREMENT,
  `valutazione` INT NOT NULL COMMENT 'Da 1 a 5 stelle',
  `commento` TEXT NULL,
  `dataRecensione` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idUtente` INT NOT NULL,
  `idRistorante` INT NOT NULL,
  `idOrdine` INT NOT NULL,
  PRIMARY KEY (`idRecensioneRistorante`),
  INDEX `fk_recensione_ristorante_utente1_idx` (`idUtente` ASC) VISIBLE,
  INDEX `fk_recensione_ristorante_ristorante1_idx` (`idRistorante` ASC) VISIBLE,
  INDEX `fk_recensione_ristorante_ordine1_idx` (`idOrdine` ASC) VISIBLE,
  CONSTRAINT `fk_recensione_ristorante_utente1`
    FOREIGN KEY (`idUtente`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_recensione_ristorante_ristorante1`
    FOREIGN KEY (`idRistorante`)
    REFERENCES `food_delivery_db`.`ristorante` (`idRistorante`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_recensione_ristorante_ordine1`
    FOREIGN KEY (`idOrdine`)
    REFERENCES `food_delivery_db`.`ordine` (`idOrdine`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`recensione_rider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`recensione_rider` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`recensione_rider` (
  `idRecensioneRider` INT NOT NULL AUTO_INCREMENT,
  `valutazione` INT NOT NULL COMMENT 'Da 1 a 5 stelle',
  `commento` TEXT NULL,
  `dataRecensione` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idUtente` INT NOT NULL,
  `idRider` INT NOT NULL,
  `idOrdine` INT NOT NULL,
  PRIMARY KEY (`idRecensioneRider`),
  INDEX `fk_recensione_rider_utente1_idx` (`idUtente` ASC) VISIBLE,
  INDEX `fk_recensione_rider_rider1_idx` (`idRider` ASC) VISIBLE,
  INDEX `fk_recensione_rider_ordine1_idx` (`idOrdine` ASC) VISIBLE,
  CONSTRAINT `fk_recensione_rider_utente1`
    FOREIGN KEY (`idUtente`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_recensione_rider_rider1`
    FOREIGN KEY (`idRider`)
    REFERENCES `food_delivery_db`.`rider` (`idRider`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_recensione_rider_ordine1`
    FOREIGN KEY (`idOrdine`)
    REFERENCES `food_delivery_db`.`ordine` (`idOrdine`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `food_delivery_db`.`notifica`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `food_delivery_db`.`notifica` ;

CREATE TABLE IF NOT EXISTS `food_delivery_db`.`notifica` (
  `idNotifica` INT NOT NULL AUTO_INCREMENT,
  `titolo` VARCHAR(100) NOT NULL,
  `messaggio` TEXT NOT NULL,
  `tipo` ENUM('ordine', 'sistema') NOT NULL,
  `dataCreazione` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `letta` TINYINT NOT NULL DEFAULT 0,
  `dataLettura` DATETIME NULL,
  `idUtente` INT NOT NULL,
  `idOrdine` INT NULL,
  PRIMARY KEY (`idNotifica`),
  INDEX `fk_notifica_utente1_idx` (`idUtente` ASC) VISIBLE,
  INDEX `fk_notifica_ordine1_idx` (`idOrdine` ASC) VISIBLE,
  CONSTRAINT `fk_notifica_utente1`
    FOREIGN KEY (`idUtente`)
    REFERENCES `food_delivery_db`.`utente` (`idUtente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_notifica_ordine1`
    FOREIGN KEY (`idOrdine`)
    REFERENCES `food_delivery_db`.`ordine` (`idOrdine`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Prepopulate `food_delivery_db`.`stato_ordine`
-- -----------------------------------------------------

INSERT INTO `food_delivery_db`.`stato_ordine` (`nome`, `descrizione`) VALUES 
('nuovo', 'Ordine appena creato'),
('confermato', 'Ordine confermato dal ristorante'),
('in_preparazione', 'Il ristorante sta preparando l\'ordine'),
('pronto_per_consegna', 'L\'ordine è pronto per essere ritirato dal rider'),
('in_consegna', 'Il rider sta consegnando l\'ordine'),
('consegnato', 'L\'ordine è stato consegnato con successo'),
('annullato', 'L\'ordine è stato annullato'),
('rifiutato', 'L\'ordine è stato rifiutato dal ristorante');

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- 1
-- -----------------------------------------------------

-- Creazione degli utenti
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin_password';
CREATE USER 'ristoratore'@'localhost' IDENTIFIED BY 'ristoratore_password';
CREATE USER 'cliente'@'localhost' IDENTIFIED BY 'cliente_password';
CREATE USER 'rider'@'localhost' IDENTIFIED BY 'rider_password';

-- Creazione dei ruoli
CREATE ROLE 'admin_role', 'ristoratore_role', 'cliente_role', 'rider_role';

-- Assegnazione dei privilegi ai ruoli
GRANT ALL PRIVILEGES ON food_delivery_db.* TO 'admin_role';

GRANT SELECT, INSERT, UPDATE ON food_delivery_db.prodotto TO 'ristoratore_role';
GRANT SELECT, UPDATE ON food_delivery_db.ordine TO 'ristoratore_role';
GRANT SELECT ON food_delivery_db.utente TO 'ristoratore_role';
GRANT SELECT ON food_delivery_db.recensione_ristorante TO 'ristoratore_role';

GRANT SELECT, INSERT ON food_delivery_db.ordine TO 'cliente_role';
GRANT SELECT ON food_delivery_db.prodotto TO 'cliente_role';
GRANT SELECT, INSERT ON food_delivery_db.recensione_ristorante TO 'cliente_role';
GRANT SELECT, INSERT ON food_delivery_db.recensione_rider TO 'cliente_role';

GRANT SELECT, UPDATE ON food_delivery_db.ordine TO 'rider_role';
GRANT SELECT ON food_delivery_db.indirizzo TO 'rider_role';

-- Assegnazione dei ruoli agli utenti
GRANT 'admin_role' TO 'admin'@'localhost';
GRANT 'ristoratore_role' TO 'ristoratore'@'localhost';
GRANT 'cliente_role' TO 'cliente'@'localhost';
GRANT 'rider_role' TO 'rider'@'localhost';

-- Attivazione dei ruoli di default
SET DEFAULT ROLE 'admin_role' TO 'admin'@'localhost';
SET DEFAULT ROLE 'ristoratore_role' TO 'ristoratore'@'localhost';
SET DEFAULT ROLE 'cliente_role' TO 'cliente'@'localhost';
SET DEFAULT ROLE 'rider_role' TO 'rider'@'localhost';

-- -----------------------------------------------------
-- 2
-- -----------------------------------------------------

-- Popolamento tabella indirizzo
INSERT INTO `food_delivery_db`.`indirizzo` (`via`, `civico`, `cap`, `citta`, `provincia`, `nazione`, `latitudine`, `longitudine`) VALUES 
('Via Roma', '10', '00100', 'Roma', 'RM', 'Italia', 41.9028, 12.4964),
('Via Milano', '25', '20100', 'Milano', 'MI', 'Italia', 45.4642, 9.1900),
('Via Napoli', '5', '80100', 'Napoli', 'NA', 'Italia', 40.8518, 14.2681),
('Via Firenze', '42', '50100', 'Firenze', 'FI', 'Italia', 43.7696, 11.2558),
('Via Bologna', '18', '40100', 'Bologna', 'BO', 'Italia', 44.4949, 11.3426);

-- Popolamento tabella utente
INSERT INTO `food_delivery_db`.`utente` (`nome`, `cognome`, `email`, `password`, `telefono`, `dataNascita`, `dataRegistrazione`) VALUES 
('Mario', 'Rossi', 'mario.rossi@email.com', SHA2('password123', 256), '3331234567', '1985-05-10', NOW()),
('Laura', 'Bianchi', 'laura.bianchi@email.com', SHA2('password456', 256), '3387654321', '1990-08-15', NOW()),
('Giovanni', 'Verdi', 'giovanni.verdi@email.com', SHA2('password789', 256), '3391122334', '1988-03-20', NOW()),
('Francesca', 'Neri', 'francesca.neri@email.com', SHA2('passwordabc', 256), '3395566778', '1992-11-25', NOW()),
('Giuseppe', 'Gialli', 'giuseppe.gialli@email.com', SHA2('passworddef', 256), '3399988776', '1980-07-07', NOW());

-- Popolamento tabella utente_indirizzo
INSERT INTO `food_delivery_db`.`utente_indirizzo` (`idUtente`, `idIndirizzo`, `etichetta`, `predefinito`) VALUES 
(1, 1, 'Casa', 1),
(2, 2, 'Casa', 1),
(3, 3, 'Ufficio', 1),
(4, 4, 'Casa', 1),
(5, 5, 'Casa', 0);

-- Popolamento tabella ristorante
INSERT INTO `food_delivery_db`.`ristorante` (`nome`, `descrizione`, `telefono`, `email`, `sitoWeb`, `orarioApertura`, `orarioChiusura`, `giorniApertura`, `tempoConsegnaMedio`, `costoConsegnaBase`, `ordineMinimo`, `idIndirizzo`, `idProprietario`, `tipoCucina`) VALUES 
('Pizzeria Napoli', 'Autentica pizza napoletana', '0612345678', 'pizzeria.napoli@email.com', 'www.pizzerianapoli.it', '12:00:00', '23:00:00', 'Mar-Dom', 25, 2.00, 15.00, 1, 1, 'Italiana'),
('Sushi Fusion', 'Il meglio della cucina giapponese', '0223456789', 'sushi.fusion@email.com', 'www.sushifusion.it', '18:00:00', '23:00:00', 'Lun-Dom', 35, 3.50, 20.00, 2, 2, 'Giapponese'),
('Burger House', 'Hamburger gourmet per tutti i gusti', '0634567890', 'burger.house@email.com', 'www.burgerhouse.it', '11:30:00', '22:30:00', 'Lun-Sab', 20, 2.50, 10.00, 3, 3, 'Americana');

-- Popolamento tabella prodotto
INSERT INTO `food_delivery_db`.`prodotto` (`nome`, `descrizione`, `prezzo`, `disponibile`, `categoria`, `idRistorante`) VALUES 
('Margherita', 'Pomodoro, mozzarella e basilico', 7.50, 1, 'Pizza', 1),
('Marinara', 'Pomodoro, aglio e origano', 6.00, 1, 'Pizza', 1),
('Diavola', 'Pomodoro, mozzarella e salame piccante', 9.00, 1, 'Pizza', 1),
('Nigiri Salmone', 'Riso e salmone fresco', 3.00, 1, 'Sushi', 2),
('Uramaki California', 'Rotolo con surimi, avocado e cetriolo', 8.00, 1, 'Sushi', 2),
('Tempura Misto', 'Verdure e gamberi in tempura', 12.00, 1, 'Antipasti', 2),
('Classic Burger', 'Hamburger di manzo, insalata, pomodoro, formaggio', 9.50, 1, 'Hamburger', 3),
('Cheese Bacon Burger', 'Hamburger di manzo, bacon croccante, cheddar', 11.50, 1, 'Hamburger', 3),
('Patatine Fritte', 'Patatine fritte con salse a scelta', 3.50, 1, 'Contorni', 3);

-- Popolamento tabella metodo_pagamento
INSERT INTO `food_delivery_db`.`metodo_pagamento` (`tipo`, `titolare`, `numeroMascherato`, `tokenPagamento`, `predefinito`, `idUtente`) VALUES 
('carta_credito', 'Mario Rossi', '****1234', 'token123', 1, 1),
('paypal', 'Laura Bianchi', 'laura.b@email.com', 'token456', 1, 2),
('contanti', NULL, NULL, NULL, 1, 3),
('carta_credito', 'Francesca Neri', '****5678', 'token789', 1, 4),
('buoni_pasto', 'Giuseppe Gialli', '****9876', 'tokenabc', 1, 5);

-- Popolamento tabella rider
INSERT INTO `food_delivery_db`.`rider` (`nome`, `cognome`, `email`, `password`, `telefono`, `dataNascita`, `tipoVeicolo`, `targaVeicolo`, `statoAttivita`, `idIndirizzo`) VALUES 
('Paolo', 'Blu', 'paolo.blu@email.com', SHA2('riderpass1', 256), '3335544332', '1995-02-12', 'scooter', 'AB12345', 'disponibile', 1),
('Marco', 'Viola', 'marco.viola@email.com', SHA2('riderpass2', 256), '3334455667', '1992-06-30', 'bicicletta', NULL, 'disponibile', 2),
('Sara', 'Rosa', 'sara.rosa@email.com', SHA2('riderpass3', 256), '3332211445', '1994-09-15', 'auto', 'CD67890', 'offline', 3);

-- Popolamento tabella ordine
INSERT INTO `food_delivery_db`.`ordine` (`dataOrdine`, `costoTotale`, `costoConsegna`, `ivaApplicata`, `note`, `dataConsegnaPrevista`, `idUtente`, `idRistorante`, `idIndirizzoConsegna`, `idMetodoPagamento`, `idRider`, `idStatoOrdine`) VALUES 
(NOW() - INTERVAL 2 HOUR, 22.50, 2.00, 10.00, 'Citofonare piano 2', NOW() - INTERVAL 1 HOUR, 1, 1, 1, 1, 1, 6),
(NOW() - INTERVAL 1 HOUR, 31.00, 3.50, 10.00, 'Lasciare davanti alla porta', NOW() + INTERVAL 30 MINUTE, 2, 2, 2, 2, 2, 3),
(NOW() - INTERVAL 30 MINUTE, 24.50, 2.50, 10.00, NULL, NOW() + INTERVAL 1 HOUR, 3, 3, 3, 3, NULL, 2);

-- Popolamento tabella dettaglio_ordine
INSERT INTO `food_delivery_db`.`dettaglio_ordine` (`quantita`, `prezzoUnitario`, `note`, `idOrdine`, `idProdotto`) VALUES 
(2, 7.50, NULL, 1, 1),
(1, 6.00, 'Ben cotta', 1, 2),
(2, 8.00, NULL, 2, 5),
(1, 12.00, NULL, 2, 6),
(1, 9.50, 'Senza cipolla', 3, 7),
(2, 3.50, 'Extra ketchup', 3, 9);

-- Popolamento tabella recensione_ristorante
INSERT INTO `food_delivery_db`.`recensione_ristorante` (`valutazione`, `commento`, `idUtente`, `idRistorante`, `idOrdine`) VALUES 
(5, 'Pizza eccellente, consegna puntuale!', 1, 1, 1),
(4, 'Buon sushi, ma consegna un po\' in ritardo', 2, 2, 2);

-- Popolamento tabella recensione_rider
INSERT INTO `food_delivery_db`.`recensione_rider` (`valutazione`, `commento`, `idUtente`, `idRider`, `idOrdine`) VALUES 
(5, 'Rider gentile e veloce', 1, 1, 1),
(3, 'Consegna in ritardo ma rider gentile', 2, 2, 2);

-- Popolamento tabella notifica
INSERT INTO `food_delivery_db`.`notifica` (`titolo`, `messaggio`, `tipo`, `idUtente`, `idOrdine`) VALUES 
('Ordine consegnato', 'Il tuo ordine #1 è stato consegnato con successo', 'ordine', 1, 1),
('Ordine in preparazione', 'Il tuo ordine #2 è in preparazione', 'ordine', 2, 2),
('Ordine confermato', 'Il tuo ordine #3 è stato confermato dal ristorante', 'ordine', 3, 3),
('Promozione', 'Usa il codice FOOD10 per avere il 10% di sconto sul prossimo ordine', 'sistema', 4, NULL),
('Benvenuto', 'Benvenuto su Food Delivery! Inizia a ordinare.', 'sistema', 5, NULL);

-- -----------------------------------------------------
-- 3
-- -----------------------------------------------------

-- Trigger per inviare notifica automatica quando un ordine viene aggiornato
DELIMITER //
CREATE TRIGGER after_ordine_update
AFTER UPDATE ON `food_delivery_db`.`ordine`
FOR EACH ROW
BEGIN
    DECLARE stato_nome VARCHAR(45);
    
    -- Ottieni il nome dello stato
    SELECT nome INTO stato_nome FROM `food_delivery_db`.`stato_ordine` WHERE idStatoOrdine = NEW.idStatoOrdine;
    
    -- Se lo stato è cambiato, crea una notifica
    IF OLD.idStatoOrdine <> NEW.idStatoOrdine THEN
        INSERT INTO `food_delivery_db`.`notifica` 
            (`titolo`, `messaggio`, `tipo`, `idUtente`, `idOrdine`)
        VALUES 
            (CONCAT('Aggiornamento Ordine #', NEW.idOrdine), 
             CONCAT('Il tuo ordine è ora ', stato_nome), 
             'ordine', 
             NEW.idUtente, 
             NEW.idOrdine);
    END IF;
END //
DELIMITER ;

-- Trigger per controllare la disponibilità dei prodotti prima di inserire un dettaglio ordine
DELIMITER //
CREATE TRIGGER before_dettaglio_ordine_insert
BEFORE INSERT ON `food_delivery_db`.`dettaglio_ordine`
FOR EACH ROW
BEGIN
    DECLARE is_available TINYINT;
    
    -- Verifica se il prodotto è disponibile
    SELECT disponibile INTO is_available 
    FROM `food_delivery_db`.`prodotto` 
    WHERE idProdotto = NEW.idProdotto;
    
    -- Se il prodotto non è disponibile, genera un errore
    IF is_available = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il prodotto non è disponibile al momento';
    END IF;
END //
DELIMITER ;

-- Trigger per aggiornare il totale dell'ordine dopo l'inserimento di un nuovo dettaglio
DELIMITER //
CREATE TRIGGER after_dettaglio_ordine_insert
AFTER INSERT ON `food_delivery_db`.`dettaglio_ordine`
FOR EACH ROW
BEGIN
    DECLARE subtotale DECIMAL(8,2);
    
    -- Calcola il subtotale di questo dettaglio
    SET subtotale = NEW.quantita * NEW.prezzoUnitario;
    
    -- Aggiorna il totale dell'ordine
    UPDATE `food_delivery_db`.`ordine` 
    SET costoTotale = costoTotale + subtotale
    WHERE idOrdine = NEW.idOrdine;
END //
DELIMITER ;

-- Trigger per calcolare la data di consegna prevista
DELIMITER //
CREATE TRIGGER before_ordine_insert
BEFORE INSERT ON `food_delivery_db`.`ordine`
FOR EACH ROW
BEGIN
    DECLARE tempo_medio INT;
    
    -- Recupera il tempo medio di consegna dal ristorante
    SELECT tempoConsegnaMedio INTO tempo_medio
    FROM `food_delivery_db`.`ristorante`
    WHERE idRistorante = NEW.idRistorante;
    
    -- Imposta la data di consegna prevista
    SET NEW.dataConsegnaPrevista = DATE_ADD(NEW.dataOrdine, INTERVAL tempo_medio MINUTE);
END //
DELIMITER ;

-- -----------------------------------------------------
-- 4
-- -----------------------------------------------------
-- Vista per visualizzare i ristoranti con le loro valutazioni medie
CREATE VIEW `food_delivery_db`.`vista_ristoranti_valutazioni` AS
SELECT 
    r.idRistorante,
    r.nome,
    r.tipoCucina,
    r.telefono,
    i.citta,
    i.provincia,
    r.orarioApertura,
    r.orarioChiusura,
    r.giorniApertura,
    r.costoConsegnaBase,
    r.ordineMinimo,
    COALESCE(AVG(rr.valutazione), 0) AS valutazione_media,
    COUNT(rr.idRecensioneRistorante) AS numero_recensioni
FROM 
    `food_delivery_db`.`ristorante` r
LEFT JOIN 
    `food_delivery_db`.`recensione_ristorante` rr ON r.idRistorante = rr.idRistorante
JOIN 
    `food_delivery_db`.`indirizzo` i ON r.idIndirizzo = i.idIndirizzo
WHERE 
    r.stato = 'attivo'
GROUP BY 
    r.idRistorante, r.nome, r.tipoCucina, r.telefono, i.citta, i.provincia, 
    r.orarioApertura, r.orarioChiusura, r.giorniApertura, r.costoConsegnaBase, r.ordineMinimo;

-- Vista per visualizzare gli ordini completi con dettagli
CREATE VIEW `food_delivery_db`.`vista_ordini_completi` AS
SELECT 
    o.idOrdine,
    o.dataOrdine,
    o.costoTotale,
    o.costoConsegna,
    o.ivaApplicata,
    s.nome AS stato_ordine,
    u.nome AS nome_utente,
    u.cognome AS cognome_utente,
    u.email AS email_utente,
    r.nome AS nome_ristorante,
    r.telefono AS telefono_ristorante,
    i.via,
    i.civico,
    i.citta,
    i.provincia,
    i.cap,
    CONCAT(rd.nome, ' ', rd.cognome) AS nome_rider,
    rd.telefono AS telefono_rider,
    o.dataConsegnaPrevista,
    o.dataConsegnaEffettiva
FROM 
    `food_delivery_db`.`ordine` o
JOIN 
    `food_delivery_db`.`utente` u ON o.idUtente = u.idUtente
JOIN 
    `food_delivery_db`.`ristorante` r ON o.idRistorante = r.idRistorante
JOIN 
    `food_delivery_db`.`indirizzo` i ON o.idIndirizzoConsegna = i.idIndirizzo
JOIN 
    `food_delivery_db`.`stato_ordine` s ON o.idStatoOrdine = s.idStatoOrdine
LEFT JOIN 
    `food_delivery_db`.`rider` rd ON o.idRider = rd.idRider;

-- Vista per visualizzare i dettagli degli ordini
CREATE VIEW `food_delivery_db`.`vista_dettagli_ordine` AS
SELECT 
    d.idOrdine,
    o.dataOrdine,
    u.nome AS nome_utente,
    u.cognome AS cognome_utente,
    r.nome AS nome_ristorante,
    p.nome AS nome_prodotto,
    p.categoria,
    d.quantita,
    d.prezzoUnitario,
    (d.quantita * d.prezzoUnitario) AS subtotale,
    d.note
FROM 
    `food_delivery_db`.`dettaglio_ordine` d
JOIN 
    `food_delivery_db`.`ordine` o ON d.idOrdine = o.idOrdine
JOIN 
    `food_delivery_db`.`utente` u ON o.idUtente = u.idUtente
JOIN 
    `food_delivery_db`.`ristorante` r ON o.idRistorante = r.idRistorante
JOIN 
    `food_delivery_db`.`prodotto` p ON d.idProdotto = p.idProdotto;

-- -----------------------------------------------------
-- 5
-- -----------------------------------------------------

-- Procedura per assegnare un rider all'ordine (semplificata)
DELIMITER //
CREATE PROCEDURE `food_delivery_db`.`assegna_rider_a_ordine`(
    IN p_idOrdine INT, 
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_idRider INT;
    
    -- Trova il rider disponibile
    SELECT idRider INTO v_idRider
    FROM `food_delivery_db`.`rider`
    WHERE statoAttivita = 'disponibile'
    LIMIT 1;
    
    IF v_idRider IS NULL THEN
        SET p_result = 'Nessun rider disponibile';
    ELSE
        -- Assegna il rider all'ordine
        UPDATE `food_delivery_db`.`ordine` 
        SET idRider = v_idRider, idStatoOrdine = 5 -- 5 = in_consegna
        WHERE idOrdine = p_idOrdine;
        
        -- Imposta lo stato del rider
        UPDATE `food_delivery_db`.`rider`
        SET statoAttivita = 'in_consegna'
        WHERE idRider = v_idRider;
        
        SET p_result = CONCAT('Rider ', v_idRider, ' assegnato all\'ordine ', p_idOrdine);
    END IF;
END //
DELIMITER ;

-- Procedura per completare un ordine (semplificata)
DELIMITER //
CREATE PROCEDURE `food_delivery_db`.`completa_ordine`(
    IN p_idOrdine INT,
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_idRider INT;
    
    -- Ottieni il rider dell'ordine
    SELECT idRider INTO v_idRider
    FROM `food_delivery_db`.`ordine` 
    WHERE idOrdine = p_idOrdine;
    
    -- Aggiorna lo stato dell'ordine
    UPDATE `food_delivery_db`.`ordine` 
    SET idStatoOrdine = 6, -- 6 = consegnato
        dataConsegnaEffettiva = NOW()
    WHERE idOrdine = p_idOrdine;
    
    -- Libera il rider
    IF v_idRider IS NOT NULL THEN
        UPDATE `food_delivery_db`.`rider`
        SET statoAttivita = 'disponibile'
        WHERE idRider = v_idRider;
    END IF;
    
    SET p_result = CONCAT('Ordine ', p_idOrdine, ' completato con successo');
END //
DELIMITER ;

-- Transazione: Creazione di un nuovo ordine (semplificata)
DELIMITER //
CREATE PROCEDURE `food_delivery_db`.`crea_nuovo_ordine`(
    IN p_idUtente INT,
    IN p_idRistorante INT,
    IN p_idIndirizzoConsegna INT,
    IN p_idMetodoPagamento INT,
    OUT p_idOrdine INT
)
BEGIN
    DECLARE v_costo_consegna DECIMAL(5,2);
    
    START TRANSACTION;
    
    -- Ottieni il costo di consegna dal ristorante
    SELECT costoConsegnaBase INTO v_costo_consegna
    FROM `food_delivery_db`.`ristorante`
    WHERE idRistorante = p_idRistorante;
    
    -- Inserisci il nuovo ordine
    INSERT INTO `food_delivery_db`.`ordine`
        (dataOrdine, costoTotale, costoConsegna, ivaApplicata, 
         idUtente, idRistorante, idIndirizzoConsegna, idMetodoPagamento, idStatoOrdine)
    VALUES
        (NOW(), v_costo_consegna, v_costo_consegna, 10.00, 
         p_idUtente, p_idRistorante, p_idIndirizzoConsegna, p_idMetodoPagamento, 1);
    
    -- Salva l'ID dell'ordine creato
    SET p_idOrdine = LAST_INSERT_ID();
    
    COMMIT;
END //
DELIMITER ;

-- Transazione: Aggiornamento stato ordine (semplificata)
DELIMITER //
CREATE PROCEDURE `food_delivery_db`.`aggiorna_stato_ordine`(
    IN p_idOrdine INT,
    IN p_nuovo_stato VARCHAR(45),
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_id_stato_nuovo INT;
    
    START TRANSACTION;
    
    -- Ottieni l'id del nuovo stato
    SELECT idStatoOrdine INTO v_id_stato_nuovo
    FROM `food_delivery_db`.`stato_ordine`
    WHERE nome = p_nuovo_stato;
    
    -- Aggiorna lo stato dell'ordine
    UPDATE `food_delivery_db`.`ordine`
    SET idStatoOrdine = v_id_stato_nuovo
    WHERE idOrdine = p_idOrdine;
    
    SET p_result = CONCAT('Stato dell\'ordine #', p_idOrdine, ' aggiornato a ', p_nuovo_stato);
    COMMIT;
END //
DELIMITER ;

-- -----------------------------------------------------
-- 6
-- -----------------------------------------------------
-- 1. Query semplice: Elenco dei ristoranti con relativi prodotti
SELECT 
    r.nome AS nome_ristorante,
    r.tipoCucina,
    COUNT(p.idProdotto) AS numero_prodotti,
    MIN(p.prezzo) AS prezzo_minimo,
    MAX(p.prezzo) AS prezzo_massimo,
    AVG(p.prezzo) AS prezzo_medio
FROM 
    `food_delivery_db`.`ristorante` r
LEFT JOIN 
    `food_delivery_db`.`prodotto` p ON r.idRistorante = p.idRistorante
GROUP BY 
    r.idRistorante, r.nome, r.tipoCucina
ORDER BY 
    r.nome;

-- 2. Query media: Prodotti più popolari per ogni ristorante
SELECT 
    r.nome AS nome_ristorante,
    p.nome AS nome_prodotto,
    p.categoria,
    SUM(d.quantita) AS quantita_venduta
FROM 
    `food_delivery_db`.`ristorante` r
JOIN 
    `food_delivery_db`.`prodotto` p ON r.idRistorante = p.idRistorante
JOIN 
    `food_delivery_db`.`dettaglio_ordine` d ON p.idProdotto = d.idProdotto
GROUP BY 
    r.idRistorante, r.nome, p.idProdotto, p.nome, p.categoria
ORDER BY 
    r.nome, quantita_venduta DESC;

-- 3. Query complessa: Ordini con dettagli completi
SELECT 
    o.idOrdine,
    o.dataOrdine,
    o.costoTotale,
    u.nome AS nome_cliente,
    u.cognome AS cognome_cliente,
    r.nome AS nome_ristorante,
    GROUP_CONCAT(CONCAT(p.nome, ' (', d.quantita, ')') SEPARATOR ', ') AS prodotti,
    CASE 
        WHEN o.idStatoOrdine = 1 THEN 'Nuovo'
        WHEN o.idStatoOrdine = 2 THEN 'Confermato'
        WHEN o.idStatoOrdine = 3 THEN 'In preparazione'
        WHEN o.idStatoOrdine = 4 THEN 'Pronto per consegna'
        WHEN o.idStatoOrdine = 5 THEN 'In consegna'
        WHEN o.idStatoOrdine = 6 THEN 'Consegnato'
        WHEN o.idStatoOrdine = 7 THEN 'Annullato'
        WHEN o.idStatoOrdine = 8 THEN 'Rifiutato'
        ELSE 'Sconosciuto'
    END AS stato_ordine
FROM 
    `food_delivery_db`.`ordine` o
JOIN 
    `food_delivery_db`.`utente` u ON o.idUtente = u.idUtente
JOIN 
    `food_delivery_db`.`ristorante` r ON o.idRistorante = r.idRistorante
JOIN 
    `food_delivery_db`.`dettaglio_ordine` d ON o.idOrdine = d.idOrdine
JOIN 
    `food_delivery_db`.`prodotto` p ON d.idProdotto = p.idProdotto
GROUP BY 
    o.idOrdine, o.dataOrdine, o.costoTotale, nome_cliente, cognome_cliente, nome_ristorante, stato_ordine
ORDER BY 
    o.dataOrdine DESC;

-- 4. Query semplice per trovare i rider disponibili
SELECT 
    idRider,
    CONCAT(nome, ' ', cognome) AS nome_completo,
    telefono,
    tipoVeicolo
FROM 
    `food_delivery_db`.`rider`
WHERE 
    statoAttivita = 'disponibile'
ORDER BY 
    idRider;

-- 5. Query per trovare i ristoranti con le recensioni migliori
SELECT 
    r.nome AS nome_ristorante,
    r.tipoCucina,
    r.telefono,
    AVG(rr.valutazione) AS valutazione_media,
    COUNT(rr.idRecensioneRistorante) AS numero_recensioni
FROM 
    `food_delivery_db`.`ristorante` r
LEFT JOIN 
    `food_delivery_db`.`recensione_ristorante` rr ON r.idRistorante = rr.idRistorante
GROUP BY 
    r.idRistorante, r.nome, r.tipoCucina, r.telefono
HAVING 
    numero_recensioni > 0
ORDER BY 
    valutazione_media DESC, numero_recensioni DESC;

-- -----------------------------------------------------
-- 7
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE `food_delivery_db`.`registra_nuovo_utente`(
    IN p_nome VARCHAR(45),
    IN p_cognome VARCHAR(45),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(45),
    IN p_telefono VARCHAR(20),
    IN p_dataNascita DATE,
    OUT p_idUtente INT,
    OUT p_messaggio VARCHAR(255)
)
BEGIN
    DECLARE v_email_exists INT DEFAULT 0;
    DECLARE v_telefono_exists INT DEFAULT 0;
    DECLARE v_errore_generico CONDITION FOR SQLSTATE '45000';
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Gestisce gli errori SQL
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;
        
        SET p_messaggio = CONCAT('Errore SQL: ', @errno, ' - ', @text);
        SET p_idUtente = 0;
        ROLLBACK;
    END;
    
    -- Convalida dei dati di input
    IF p_nome IS NULL OR p_nome = '' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Il nome è obbligatorio';
    END IF;
    
    IF p_cognome IS NULL OR p_cognome = '' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Il cognome è obbligatorio';
    END IF;
    
    IF p_email IS NULL OR p_email = '' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'L\'email è obbligatoria';
    ELSEIF p_email NOT REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Formato email non valido';
    END IF;
    
    IF p_password IS NULL OR LENGTH(p_password) < 8 THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'La password deve essere di almeno 8 caratteri';
    END IF;
    
    IF p_telefono IS NULL OR p_telefono = '' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Il telefono è obbligatorio';
    ELSEIF p_telefono NOT REGEXP '^[0-9]{10,15}$' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Formato telefono non valido';
    END IF;
    
    IF p_dataNascita IS NOT NULL AND p_dataNascita > CURDATE() THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'La data di nascita non può essere nel futuro';
    END IF;
    
    -- Verifica che email e telefono non siano già in uso
    SELECT COUNT(*) INTO v_email_exists 
    FROM `food_delivery_db`.`utente` 
    WHERE email = p_email;
    
    IF v_email_exists > 0 THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Email già in uso';
    END IF;
    
    SELECT COUNT(*) INTO v_telefono_exists 
    FROM `food_delivery_db`.`utente` 
    WHERE telefono = p_telefono;
    
    IF v_telefono_exists > 0 THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Numero di telefono già in uso';
    END IF;
    
    -- Inizia la transazione
    START TRANSACTION;
    
    -- Inserisci il nuovo utente
    INSERT INTO `food_delivery_db`.`utente` 
        (nome, cognome, email, password, telefono, dataNascita, dataRegistrazione, stato)
    VALUES 
        (p_nome, p_cognome, p_email, SHA2(p_password, 256), p_telefono, p_dataNascita, NOW(), 'attivo');
    
    SET p_idUtente = LAST_INSERT_ID();
    
    -- Crea una notifica di benvenuto
    INSERT INTO `food_delivery_db`.`notifica` 
        (titolo, messaggio, tipo, idUtente, idOrdine)
    VALUES 
        ('Benvenuto su Food Delivery', 
         CONCAT('Benvenuto ', p_nome, '! Inizia a ordinare i tuoi piatti preferiti.'), 
         'sistema', 
         p_idUtente, 
         NULL);
    
    COMMIT;
    
    SET p_messaggio = CONCAT('Utente registrato con successo. ID: ', p_idUtente);
END //
DELIMITER ;

-- Procedura con gestione degli errori per l'inserimento di un nuovo prodotto
DELIMITER //
CREATE PROCEDURE `food_delivery_db`.`inserisci_nuovo_prodotto`(
    IN p_nome VARCHAR(100),
    IN p_descrizione TEXT,
    IN p_prezzo DECIMAL(6,2),
    IN p_categoria VARCHAR(45),
    IN p_idRistorante INT,
    OUT p_idProdotto INT,
    OUT p_messaggio VARCHAR(100)
)
BEGIN
    DECLARE v_ristorante_exists INT DEFAULT 0;
    DECLARE v_errore_generico CONDITION FOR SQLSTATE '45000';
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Gestisce gli errori SQL
        GET DIAGNOSTICS CONDITION 1
        @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT;
        
        SET p_messaggio = CONCAT('Errore SQL: ', @errno, ' - ', @text);
        SET p_idProdotto = 0;
        ROLLBACK;
    END;
    
    -- Convalida dei dati di input
    IF p_nome IS NULL OR p_nome = '' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Il nome è obbligatorio';
    END IF;
    
    IF p_prezzo IS NULL OR p_prezzo <= 0 THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Il prezzo deve essere maggiore di zero';
    END IF;
    
    IF p_categoria IS NULL OR p_categoria = '' THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'La categoria è obbligatoria';
    END IF;
    
    IF p_idRistorante IS NULL THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'L\'ID del ristorante è obbligatorio';
    END IF;
    
    -- Verifica che il ristorante esista
    SELECT COUNT(*) INTO v_ristorante_exists 
    FROM `food_delivery_db`.`ristorante` 
    WHERE idRistorante = p_idRistorante;
    
    IF v_ristorante_exists = 0 THEN
        SIGNAL v_errore_generico SET MESSAGE_TEXT = 'Ristorante non trovato';
    END IF;
    
    -- Inizia la transazione
    START TRANSACTION;
    
    -- Inserisci il nuovo prodotto
    INSERT INTO `food_delivery_db`.`prodotto` 
        (nome, descrizione, prezzo, disponibile, categoria, idRistorante)
    VALUES 
        (p_nome, p_descrizione, p_prezzo, 1, p_categoria, p_idRistorante);
    
    SET p_idProdotto = LAST_INSERT_ID();
    
    COMMIT;
    
    SET p_messaggio = CONCAT('Prodotto inserito con successo. ID: ', p_idProdotto);
END //
DELIMITER ;