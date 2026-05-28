-- ============================================================
-- TTMS 票务管理系统 - 数据库初始化脚本
-- ============================================================

-- -----------------------------------------------------------
-- 1. 员工表
-- -----------------------------------------------------------
SET NAMES utf8mb4;
DROP TABLE IF EXISTS `sale_item`;
DROP TABLE IF EXISTS `sale`;
DROP TABLE IF EXISTS `ticket`;
DROP TABLE IF EXISTS `schedule`;
DROP TABLE IF EXISTS `seat`;
DROP TABLE IF EXISTS `play`;
DROP TABLE IF EXISTS `studio`;
DROP TABLE IF EXISTS `employee`;
DROP TABLE IF EXISTS `data_dict`;
DROP TABLE IF EXISTS `mylog`;

CREATE TABLE `employee` (
    `emp_id`       INT          NOT NULL AUTO_INCREMENT,
    `emp_no`       VARCHAR(32)  DEFAULT NULL,
    `emp_type`     INT          DEFAULT NULL COMMENT '1=经理, 2=售票员, 3=管理员, 4=VIP, 5=普通用户',
    `emp_name`     VARCHAR(64)  NOT NULL,
    `emp_passwd`   VARCHAR(128) NOT NULL COMMENT 'MD5 加密',
    `emp_tel_num`  VARCHAR(32)  DEFAULT NULL,
    `emp_addr`     VARCHAR(128) DEFAULT NULL,
    `emp_email`    VARCHAR(64)  DEFAULT NULL,
    PRIMARY KEY (`emp_id`),
    UNIQUE KEY `uk_emp_name` (`emp_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 2. 演出厅表
-- -----------------------------------------------------------
CREATE TABLE `studio` (
    `studio_id`          INT          NOT NULL AUTO_INCREMENT,
    `studio_name`        VARCHAR(64)  NOT NULL,
    `studio_row_count`   INT          DEFAULT 0,
    `studio_col_count`   INT          DEFAULT 0,
    `studio_seat_count`  INT          DEFAULT 0,
    `studio_introduction` VARCHAR(256) DEFAULT NULL,
    `studio_flag`        INT          DEFAULT 1 COMMENT '1=可用, 0=停用',
    PRIMARY KEY (`studio_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 3. 剧目表
-- -----------------------------------------------------------
CREATE TABLE `play` (
    `play_id`           INT            NOT NULL AUTO_INCREMENT,
    `play_type_id`      INT            DEFAULT NULL COMMENT '剧目类型 ID，关联 data_dict',
    `play_lang_id`      INT            DEFAULT NULL COMMENT '语言 ID，关联 data_dict',
    `play_name`         VARCHAR(128)   NOT NULL,
    `play_introduction` VARCHAR(1024)  DEFAULT NULL,
    `play_image`        LONGBLOB       DEFAULT NULL,
    `play_length`       INT            DEFAULT 0 COMMENT '时长（分钟）',
    `play_ticket_price` DECIMAL(10,2)  DEFAULT 0.00,
    `play_status`       SMALLINT       DEFAULT 1 COMMENT '1=上架, 0=下架',
    PRIMARY KEY (`play_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 4. 座位表
-- -----------------------------------------------------------
CREATE TABLE `seat` (
    `seat_id`     INT NOT NULL AUTO_INCREMENT,
    `studio_id`   INT NOT NULL,
    `seat_row`    INT DEFAULT 0,
    `seat_column` INT DEFAULT 0,
    `seat_status` SMALLINT DEFAULT 1 COMMENT '1=可用, 0=不可用',
    PRIMARY KEY (`seat_id`),
    KEY `idx_studio_id` (`studio_id`),
    CONSTRAINT `fk_seat_studio` FOREIGN KEY (`studio_id`) REFERENCES `studio` (`studio_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 5. 排片计划表
-- -----------------------------------------------------------
CREATE TABLE `schedule` (
    `sched_id`           INT            NOT NULL AUTO_INCREMENT,
    `studio_id`          INT            NOT NULL,
    `play_id`            INT            NOT NULL,
    `sched_time`         DATETIME       NOT NULL,
    `sched_ticket_price` DECIMAL(10,2)  DEFAULT 0.00,
    PRIMARY KEY (`sched_id`),
    KEY `idx_studio_id` (`studio_id`),
    KEY `idx_play_id` (`play_id`),
    CONSTRAINT `fk_schedule_studio` FOREIGN KEY (`studio_id`) REFERENCES `studio` (`studio_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_schedule_play`   FOREIGN KEY (`play_id`)   REFERENCES `play`   (`play_id`)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 6. 票表
-- -----------------------------------------------------------
CREATE TABLE `ticket` (
    `ticket_id`         BIGINT         NOT NULL AUTO_INCREMENT,
    `seat_id`           INT            NOT NULL,
    `sched_id`          INT            NOT NULL,
    `ticket_price`      DECIMAL(10,2)  DEFAULT 0.00,
    `ticket_status`     SMALLINT       DEFAULT 0 COMMENT '0=可选, 1=已售, 2=占座中',
    `ticket_locked_time` DATETIME      DEFAULT NULL,
    PRIMARY KEY (`ticket_id`),
    KEY `idx_seat_id`  (`seat_id`),
    KEY `idx_sched_id` (`sched_id`),
    CONSTRAINT `fk_ticket_seat`     FOREIGN KEY (`seat_id`)  REFERENCES `seat`     (`seat_id`)  ON DELETE CASCADE,
    CONSTRAINT `fk_ticket_schedule` FOREIGN KEY (`sched_id`) REFERENCES `schedule` (`sched_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 7. 销售/订单表
-- -----------------------------------------------------------
CREATE TABLE `sale` (
    `sale_ID`      BIGINT         NOT NULL AUTO_INCREMENT,
    `emp_id`       INT            DEFAULT NULL,
    `sale_time`    DATETIME       DEFAULT NULL,
    `sale_payment` DECIMAL(10,2)  DEFAULT 0.00,
    `sale_change`  DECIMAL(10,2)  DEFAULT 0.00,
    `sale_type`    SMALLINT       DEFAULT 1 COMMENT '1=购票, -1=退票',
    `sale_status`  SMALLINT       DEFAULT 0 COMMENT '0=待付款, 1=已完成, -1=已取消',
    PRIMARY KEY (`sale_ID`),
    KEY `idx_emp_id` (`emp_id`),
    CONSTRAINT `fk_sale_employee` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 8. 销售明细表
-- -----------------------------------------------------------
CREATE TABLE `sale_item` (
    `sale_item_id`   BIGINT        NOT NULL AUTO_INCREMENT,
    `ticket_id`      BIGINT        NOT NULL,
    `sale_ID`        BIGINT        NOT NULL,
    `sale_item_price` DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (`sale_item_id`),
    KEY `idx_ticket_id` (`ticket_id`),
    KEY `idx_sale_ID` (`sale_ID`),
    CONSTRAINT `fk_sale_item_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`ticket_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_sale_item_sale`   FOREIGN KEY (`sale_ID`)  REFERENCES `sale`   (`sale_ID`)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 9. 数据字典表
-- -----------------------------------------------------------
CREATE TABLE `data_dict` (
    `dict_id`        INT          NOT NULL AUTO_INCREMENT,
    `dict_parent_id` INT          DEFAULT NULL,
    `dict_index`     INT          DEFAULT NULL,
    `dict_name`      VARCHAR(64)  NOT NULL,
    `dict_value`     VARCHAR(256) DEFAULT NULL,
    PRIMARY KEY (`dict_id`),
    KEY `idx_parent_id` (`dict_parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- 10. 日志表
-- -----------------------------------------------------------
CREATE TABLE `mylog` (
    `log_id`      INT           NOT NULL AUTO_INCREMENT,
    `log_time`    VARCHAR(32)   DEFAULT NULL,
    `log_content` VARCHAR(1024) DEFAULT NULL,
    PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始数据
-- ============================================================

-- 基础测试账号
-- admin 密码：admin123
-- 其他账号密码：123456
INSERT INTO `employee` (`emp_id`, `emp_no`, `emp_type`, `emp_name`, `emp_passwd`, `emp_tel_num`, `emp_addr`, `emp_email`)
VALUES (1, 'A100', 3, 'admin',   '0192023a7bbd73250516f069df18b500', '13800000010', '系统管理中心', 'admin@test.com'),
       (2, 'M100', 1, 'manager', 'e10adc3949ba59abbe56e057f20f883e', '13800000011', '运营办公室',   'manager@test.com'),
       (3, 'C100', 2, 'seller01','e10adc3949ba59abbe56e057f20f883e', '13800000012', '售票窗口A',    'seller01@test.com'),
       (4, 'V100', 4, 'vip01',   'e10adc3949ba59abbe56e057f20f883e', '13800000013', 'VIP会员',      'vip01@test.com'),
       (5, 'U100', 5, 'user01',  'e10adc3949ba59abbe56e057f20f883e', '13800000014', '普通用户',      'user01@test.com');

-- 数据字典
INSERT INTO `data_dict` (`dict_id`, `dict_parent_id`, `dict_index`, `dict_name`, `dict_value`)
VALUES (1, NULL, 1, '剧目类型', 'play_type'),
       (2, NULL, 2, '语言',     'language'),
       (3, 1, 1, '悬疑片', 'suspense'),
       (4, 1, 2, '科幻片', 'science_fiction'),
       (5, 1, 3, '喜剧片', 'comedy'),
       (6, 1, 4, '动画片', 'animation'),
       (7, 2, 1, '中文',     'zh'),
       (8, 2, 2, '英文',     'en'),
       (9, 2, 3, '中文字幕', 'zh_subtitle');

-- ============================================================
-- 新的测试业务数据
-- 说明：保留完整表结构，移除原有演示数据，改为一套新的可直接测试的数据。
-- 为保证初始化后仍有可售场次，排片基准日期设置为：
-- 当前时间早于 20:00 用今天；否则自动用明天。
-- ============================================================

-- 3 个演出厅
INSERT INTO `studio` (`studio_id`, `studio_name`, `studio_row_count`, `studio_col_count`, `studio_seat_count`, `studio_introduction`, `studio_flag`)
VALUES (1, '晨星厅',    5, 6, 30, '中小型标准影厅，适合日常场次测试。', 1),
       (2, '海蓝厅',    6, 8, 48, '常规主力影厅，适合测试较多座位场景。', 1),
       (3, '云幕VIP厅', 4, 5, 20, 'VIP 影厅，适合测试高票价和少量座位。', 1);

-- 初始化座位
INSERT INTO `seat` (`studio_id`, `seat_row`, `seat_column`, `seat_status`)
SELECT st.studio_id, r.n, c.n, 1
FROM `studio` st
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
) r ON r.n <= st.studio_row_count
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
    SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
) c ON c.n <= st.studio_col_count;

-- 设置少量不可用座位，方便测试座位禁用状态
UPDATE `seat`
SET `seat_status` = 0
WHERE (`studio_id` = 1 AND `seat_row` = 1 AND `seat_column` IN (1, 6))
   OR (`studio_id` = 2 AND `seat_row` = 3 AND `seat_column` IN (4, 5))
   OR (`studio_id` = 3 AND `seat_row` = 4 AND `seat_column` IN (1, 5));

-- 4 个测试剧目
INSERT INTO `play` (`play_id`, `play_type_id`, `play_lang_id`, `play_name`, `play_introduction`, `play_length`, `play_ticket_price`, `play_status`)
VALUES (1, 3, 7, '迷城追踪', '都市悬疑题材影片，一名调查记者在旧城区追查失踪案，逐步揭开隐藏多年的秘密。', 105, 49.00, 1),
       (2, 4, 9, '月海计划', '科幻冒险影片，深空探测队登陆月海基地后遭遇失联危机，在倒计时中完成自救。', 115, 69.00, 1),
       (3, 5, 7, '周末训练营', '轻松喜剧片，一群性格迥异的年轻人在封闭训练营里发生一连串误会与笑料。', 98, 39.00, 1),
       (4, 6, 7, '风筝小队', '合家欢动画电影，几位少年伙伴和机械风筝一起展开城市上空的冒险旅程。', 92, 45.00, 1);

-- 排片基准日期：保证初始化后默认仍有未来场次可测试
SET @base_show_date = IF(CURTIME() < '20:00:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 DAY));

-- 排片
INSERT INTO `schedule` (`sched_id`, `studio_id`, `play_id`, `sched_time`, `sched_ticket_price`)
VALUES (1, 1, 1, TIMESTAMP(@base_show_date, '20:00:00'), 49.00),
       (2, 2, 2, TIMESTAMP(@base_show_date, '20:20:00'), 72.00),
       (3, 3, 4, TIMESTAMP(@base_show_date, '20:40:00'), 88.00),
       (4, 1, 3, TIMESTAMP(@base_show_date, '21:00:00'), 39.00),
       (5, 2, 1, TIMESTAMP(@base_show_date, '21:20:00'), 52.00),
       (6, 3, 2, TIMESTAMP(@base_show_date, '21:40:00'), 96.00),
       (7, 1, 4, TIMESTAMP(@base_show_date, '22:00:00'), 45.00),
       (8, 2, 2, TIMESTAMP(@base_show_date, '22:20:00'), 72.00),
       (9, 3, 1, TIMESTAMP(@base_show_date, '22:40:00'), 82.00),
       (10, 1, 2, TIMESTAMP(@base_show_date, '23:00:00'), 66.00),
       (11, 2, 3, TIMESTAMP(@base_show_date, '23:20:00'), 42.00),
       (12, 3, 4, TIMESTAMP(@base_show_date, '23:40:00'), 86.00);

-- 为每个排片生成票
INSERT INTO `ticket` (`seat_id`, `sched_id`, `ticket_price`, `ticket_status`, `ticket_locked_time`)
SELECT se.seat_id, sc.sched_id, sc.sched_ticket_price, 0, NULL
FROM `schedule` sc
JOIN `seat` se ON se.studio_id = sc.studio_id
WHERE se.seat_status = 1;

-- ============================================================
-- 新的销售测试数据
-- ============================================================

-- 已完成订单 1：seller01 售出 晨星厅《迷城追踪》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (1, 3, DATE_SUB(NOW(), INTERVAL 15 MINUTE), 98.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 1, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 1
  AND s.seat_row = 2
  AND s.seat_column IN (3, 4);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 1
  AND s.seat_row = 2
  AND s.seat_column IN (3, 4);

-- 已完成订单 2：vip01 购买 云幕VIP厅《风筝小队》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (2, 4, DATE_SUB(NOW(), INTERVAL 10 MINUTE), 176.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 2, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 3
  AND s.seat_row = 2
  AND s.seat_column IN (2, 3);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 3
  AND s.seat_row = 2
  AND s.seat_column IN (2, 3);

-- 待付款订单 3：user01 锁定 晨星厅《周末训练营》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (3, 5, DATE_SUB(NOW(), INTERVAL 2 MINUTE), 78.00, 0.00, 1, 0);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 3, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 4
  AND s.seat_row = 3
  AND s.seat_column IN (2, 3);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 2,
    t.ticket_locked_time = NOW()
WHERE t.sched_id = 4
  AND s.seat_row = 3
  AND s.seat_column IN (2, 3);

-- 已完成订单 4：seller01 售出 14:50 晨星厅《风筝小队》3 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (4, 3, DATE_SUB(NOW(), INTERVAL 6 HOUR), 135.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 4, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 7
  AND s.seat_row = 2
  AND s.seat_column IN (2, 3, 4);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 7
  AND s.seat_row = 2
  AND s.seat_column IN (2, 3, 4);

-- 已完成订单 5：vip01 购买 15:10 海蓝厅《迷城追踪》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (5, 4, DATE_SUB(NOW(), INTERVAL 5 HOUR), 98.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 5, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 8
  AND s.seat_row = 4
  AND s.seat_column IN (5, 6);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 8
  AND s.seat_row = 4
  AND s.seat_column IN (5, 6);

-- 已完成订单 6：seller01 售出 15:30 云幕VIP厅《月海计划》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (6, 3, DATE_SUB(NOW(), INTERVAL 4 HOUR), 184.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 6, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 9
  AND s.seat_row = 1
  AND s.seat_column IN (2, 3);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 9
  AND s.seat_row = 1
  AND s.seat_column IN (2, 3);

-- 已完成订单 7：seller01 售出 16:20 晨星厅《周末训练营》4 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (7, 3, DATE_SUB(NOW(), INTERVAL 3 HOUR), 156.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 7, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 10
  AND s.seat_row = 4
  AND s.seat_column IN (2, 3, 4, 5);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 10
  AND s.seat_row = 4
  AND s.seat_column IN (2, 3, 4, 5);

-- 已完成订单 8：user01 购买 16:40 海蓝厅《风筝小队》3 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (8, 5, DATE_SUB(NOW(), INTERVAL 160 MINUTE), 144.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 8, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 11
  AND s.seat_row = 5
  AND s.seat_column IN (3, 4, 5);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 11
  AND s.seat_row = 5
  AND s.seat_column IN (3, 4, 5);

-- 已完成订单 9：seller01 售出 17:00 云幕VIP厅《迷城追踪》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (9, 3, DATE_SUB(NOW(), INTERVAL 130 MINUTE), 164.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 9, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 12
  AND s.seat_row = 2
  AND s.seat_column IN (4, 5);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 12
  AND s.seat_row = 2
  AND s.seat_column IN (4, 5);

-- 已完成订单 10：seller01 售出 17:30 晨星厅《月海计划》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (10, 3, DATE_SUB(NOW(), INTERVAL 95 MINUTE), 132.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 10, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 13
  AND s.seat_row = 5
  AND s.seat_column IN (3, 4);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 13
  AND s.seat_row = 5
  AND s.seat_column IN (3, 4);

-- 待付款订单 11：vip01 锁定 17:50 海蓝厅《周末训练营》3 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (11, 4, DATE_SUB(NOW(), INTERVAL 30 MINUTE), 126.00, 0.00, 1, 0);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 11, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 14
  AND s.seat_row = 2
  AND s.seat_column IN (6, 7, 8);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 2,
    t.ticket_locked_time = NOW()
WHERE t.sched_id = 14
  AND s.seat_row = 2
  AND s.seat_column IN (6, 7, 8);

-- 已完成订单 12：user01 购买 18:20 云幕VIP厅《风筝小队》2 张
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (12, 5, DATE_SUB(NOW(), INTERVAL 55 MINUTE), 172.00, 0.00, 1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 12, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 15
  AND s.seat_row = 3
  AND s.seat_column IN (2, 3);

UPDATE `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
SET t.ticket_status = 1
WHERE t.sched_id = 15
  AND s.seat_row = 3
  AND s.seat_column IN (2, 3);

-- 退票订单 13：seller01 对 16:20 场次退 1 张票，用于测试退票统计
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (13, 3, DATE_SUB(NOW(), INTERVAL 45 MINUTE), 39.00, 0.00, -1, 1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 13, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 10
  AND s.seat_row = 5
  AND s.seat_column = 2;

-- 已取消订单 14：user01 取消 15:10 场次 2 张票，用于测试未完成订单状态
INSERT INTO `sale` (`sale_ID`, `emp_id`, `sale_time`, `sale_payment`, `sale_change`, `sale_type`, `sale_status`)
VALUES (14, 5, DATE_SUB(NOW(), INTERVAL 25 MINUTE), 98.00, 0.00, 1, -1);

INSERT INTO `sale_item` (`ticket_id`, `sale_ID`, `sale_item_price`)
SELECT t.ticket_id, 14, t.ticket_price
FROM `ticket` t
JOIN `seat` s ON s.seat_id = t.seat_id
WHERE t.sched_id = 8
  AND s.seat_row = 6
  AND s.seat_column IN (1, 2);

-- 日志
INSERT INTO `mylog` (`log_time`, `log_content`)
VALUES (DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), '系统初始化完成'),
       (DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), '已写入新的测试数据');
