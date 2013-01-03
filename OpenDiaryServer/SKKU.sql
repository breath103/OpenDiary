SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `inmunskku` DEFAULT CHARACTER SET utf8 ;
USE `inmunskku` ;

-- -----------------------------------------------------
-- Table `inmunskku`.`Author`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `inmunskku`.`Author` (
  `idx` INT(11) NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `secondname` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `address` VARCHAR(128) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  PRIMARY KEY (`idx`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = euckr;


-- -----------------------------------------------------
-- Table `inmunskku`.`DIARY_EVENT`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `inmunskku`.`DIARY_EVENT` (
  `IDX` INT(11) NOT NULL AUTO_INCREMENT ,
  `TARGET_DATE` DATE NULL DEFAULT NULL ,
  `WRITTER` VARCHAR(256) NULL DEFAULT NULL ,
  `TEXT` VARCHAR(256) NULL DEFAULT NULL ,
  PRIMARY KEY (`IDX`) )
ENGINE = MyISAM
AUTO_INCREMENT = 278
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `inmunskku`.`DIARY_FEELING`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `inmunskku`.`DIARY_FEELING` (
  `IDX` INT(11) NOT NULL AUTO_INCREMENT ,
  `TARGET_DATE` DATE NULL DEFAULT NULL ,
  `FEELING` DOUBLE NULL DEFAULT NULL ,
  PRIMARY KEY (`IDX`) )
ENGINE = MyISAM
AUTO_INCREMENT = 1897
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `inmunskku`.`Media`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `inmunskku`.`Media` (
  `idx` INT(11) NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  PRIMARY KEY (`idx`) ,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = euckr;


-- -----------------------------------------------------
-- Table `inmunskku`.`Poet`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `inmunskku`.`Poet` (
  `idx` INT(11) NOT NULL AUTO_INCREMENT ,
  `media_idx` INT(11) NULL DEFAULT NULL ,
  `author_idx` INT(11) NULL DEFAULT NULL ,
  `published_date` DATE NULL DEFAULT NULL ,
  `volume` INT(11) NULL DEFAULT NULL ,
  `unit` INT(11) NULL DEFAULT NULL ,
  `page` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `category` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `title` VARCHAR(128) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `text` VARCHAR(4096) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `etc` VARCHAR(512) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  `comment` VARCHAR(512) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL DEFAULT NULL ,
  PRIMARY KEY (`idx`) ,
  INDEX `media_idx` (`media_idx` ASC) ,
  INDEX `author_idx` (`author_idx` ASC) ,
  CONSTRAINT `author_idx`
    FOREIGN KEY (`author_idx` )
    REFERENCES `inmunskku`.`Author` (`idx` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `media_idx`
    FOREIGN KEY (`media_idx` )
    REFERENCES `inmunskku`.`Media` (`idx` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Placeholder table for view `inmunskku`.`PoetExt`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `inmunskku`.`PoetExt` (`authorName` INT, `mediaName` INT, `idx` INT, `media_idx` INT, `author_idx` INT, `published_date` INT, `volume` INT, `unit` INT, `page` INT, `category` INT, `title` INT, `etc` INT, `comment` INT);

-- -----------------------------------------------------
-- procedure createRollingPaper
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `createRollingPaper`(
        in creator_idx int(11),
        in title varchar(512),
        in target_email varchar(512),
        in notice varchar(512) ,
        in r_fb_id varchar(512) , 
        in r_name varchar(512), 
        in r_time timestamp )
BEGIN
    insert into ROLLING_PAPER set creator_idx  = creator_idx ,
                                  title        = title,
                                  target_email = target_email,
                                  notice       = notice,
                                  modify_time  = CURRENT_TIMESTAMP(),
                                  created_time  = CURRENT_TIMESTAMP(),
                                  receiver_fb_id = r_fb_id,
                                  receiver_name  = r_name,
                                  receive_time = r_time;


    call createTicket(creator_idx,(select max(idx) from ROLLING_PAPER));
    select max(idx) as insert_id from ROLLING_PAPER;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure createTicket
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `createTicket`( in user_idx int,
                                                         in paper_idx int)
BEGIN
    insert into ROLLING_PAPER_TICKET set paper_idx = paper_idx , user_idx = user_idx;
    update ROLLING_PAPER set participants_count = participants_count + 1 where idx = paper_idx;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure createTicketWithFacebookID
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `createTicketWithFacebookID`(in fb_id varchar(512),
                                                                      in paper_idx int)
BEGIN
 
    DECLARE guest_idx int(11);
    SET guest_idx = null;
    SELECT idx FROM USER WHERE facebook_id = fb_id INTO guest_idx;
    SELECT guest_idx;
    IF ISNULL(guest_idx) THEN 
        SELECT null; 
    ELSE 
        call createTicket(guest_idx,paper_idx);
        SELECT guest_idx;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getAllContentsOfPaperAfterTime
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `getAllContentsOfPaperAfterTime`(in p_id int,in t timestamp)
BEGIN
    (select * from IMAGE_CONTENT where paper_idx = p_id or modify_time > t);
    (select * from TEXT_CONTENT  where paper_idx = p_id or modify_time > t);
    (select * from SOUND_CONTENT where paper_idx = p_id or modify_time > t);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getAllParticipatingPapers
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `getAllParticipatingPapers`(in user int(30))
BEGIN
    select pt.idx as idx , 
           pt.creator_idx as creator_idx,
           pt.title as title ,
           pt.notice as notice,
           pt.participants_count as participants_count,
           CONVERT(UNIX_TIMESTAMP(pt.created_time),UNSIGNED) as created_time,
           CONVERT(UNIX_TIMESTAMP(pt.modify_time),UNSIGNED)  as modify_time,
           CONVERT(UNIX_TIMESTAMP(pt.receive_time),UNSIGNED)  as receive_time,
           pt.receiver_name as receiver_name
    from ROLLING_PAPER_TICKET prt, ROLLING_PAPER pt 
    where prt.user_idx = user and pt.idx = prt.paper_idx;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getParticipants
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `getParticipants`(in paper_idx int(20))
BEGIN
    select u.* from ROLLING_PAPER_TICKET t,USER u 
    where t.paper_idx = paper_idx and t.user_idx = u.idx 
    group by u.idx;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getRollingPaper
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `getRollingPaper`(in paper_idx int)
BEGIN
    select * from ROLLING_PAPER where idx = paper_idx;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getTicket
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `getTicket`(in user_idx int,in paper_idx int)
BEGIN
    select * from ROLLING_PAPER_TICKET where user_idx = user_idx and paper_idx = paper_idx;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insertImageContent
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `insertImageContent`( 
                                                    in paper_idx int,
                                                    in user_idx int ,
                                                    in x float ,
                                                    in y float ,
                                                    in width float,
                                                    in height float,
                                                    in rotation float,
                                                    in image varchar(512)
                                                    )
BEGIN
    insert into IMAGE_CONTENT 
    set user_idx = user_idx,
        paper_idx = paper_idx,
        x = x,
        y = y,
        rotation = rotation,
        image= image,
        width = width,
        height = height;
    call updatePaperModifyTime(paper_idx);  
    select * from IMAGE_CONTENT where idx = (select max(idx) from IMAGE_CONTENT);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insertSoundContent
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `insertSoundContent`( in paper_idx int,
                                                    in user_idx int ,
                                                    in x float ,
                                                    in y float ,
/*
                                                    in width float,
                                                    in height float,
                                                    in rotation float,
*/
                                                    in sound varchar(512)
                                                    )
BEGIN
    insert into SOUND_CONTENT 
    set user_idx  = user_idx,
        paper_idx = paper_idx,
        x = x,
        y = y,
        sound = sound;
    call updatePaperModifyTime(paper_idx);  
    select * from SOUND_CONTENT where idx = (select max(idx) from SOUND_CONTENT);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure updatePaperModifyTime
-- -----------------------------------------------------

DELIMITER $$
USE `inmunskku`$$
CREATE DEFINER=`inmunskku`@`%` PROCEDURE `updatePaperModifyTime`(in paper_idx int)
BEGIN
    update ROLLING_PAPER set modify_time = CURRENT_TIMESTAMP() where idx = paper_idx ;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `inmunskku`.`PoetExt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inmunskku`.`PoetExt`;
USE `inmunskku`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`inmunskku`@`%` SQL SECURITY DEFINER VIEW `PoetExt` AS select (select `Author`.`name` AS `name` from `Author` where (`Author`.`idx` = `Poet`.`author_idx`)) AS `authorName`,(select `Media`.`name` AS `name` from `Media` where (`Media`.`idx` = `Poet`.`media_idx`)) AS `mediaName`,`Poet`.`idx` AS `idx`,`Poet`.`media_idx` AS `media_idx`,`Poet`.`author_idx` AS `author_idx`,`Poet`.`published_date` AS `published_date`,`Poet`.`volume` AS `volume`,`Poet`.`unit` AS `unit`,`Poet`.`page` AS `page`,`Poet`.`category` AS `category`,`Poet`.`title` AS `title`,`Poet`.`etc` AS `etc`,`Poet`.`comment` AS `comment` from `Poet`;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
