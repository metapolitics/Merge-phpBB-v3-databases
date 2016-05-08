


-- This SQL Script is designed to merge two phpbbv3 forums, into the single datasource.
-- Still requires possible private messages merger.

USE `BASE`;

-- Update the DTG of the base board to match merged post values.
UPDATE `BASE`.`phpbb3_config` SET `config_value` = '1012578292' WHERE `BASE`.`phpbb3_config`.`config_name` = 'board_startdate' ;

-- set the baseline post count number
SELECT MAX(post_id) + 10 FROM BASE.phpbb3_posts INTO @BASE_POST_COUNT;

-- set the baseline forum count number
SELECT MAX(forum_id) + 10 FROM BASE.phpbb3_forums INTO @BASE_FORUM_COUNT;

-- set the baseline topic count number
SELECT MAX(topic_id) + 10 FROM BASE.phpbb3_topics INTO @BASE_TOPIC_COUNT;

-- set the baseline id count number
SELECT MAX(user_id) + 10 FROM BASE.phpbb3_users INTO @BASE_USER_COUNT;

USE `NEW`;

-- Build topic posted list.

INSERT INTO phpbb_topics_posted (user_id, topic_id, topic_posted)
    (SELECT phpbb_posts.topic_id, phpbb_posts.post_id, true 
        FROM phpbb_topics, phpbb_posts
        WHERE phpbb_topics.topic_first_post_id = phpbb_posts.post_id);

-- update the forum_id numbers.
UPDATE phpbb_forums
    SET `forum_id` = `forum_id` + @BASE_FORUM_COUNT
    ORDER BY `forum_id` DESC;

UPDATE phpbb_forums
    SET `parent_id` = `parent_id` + @BASE_FORUM_COUNT
    WHERE `parent_id` > 0;

UPDATE phpbb_forums
    SET `left_id` = `left_id` + @BASE_FORUM_COUNT;

UPDATE phpbb_forums
    SET `right_id` = `right_id` + @BASE_FORUM_COUNT;

UPDATE phpbb_posts
    SET `forum_id` = `forum_id` + @BASE_FORUM_COUNT;

UPDATE phpbb_topics
    SET `forum_id` = `forum_id` + @BASE_FORUM_COUNT;

-- Clean up heirarchy
UPDATE BASE.phpbb3_forums as basef, `NEW`.phpbb_forums as newf
    SET basef.forum_parents = "" AND newf.forum_parents = "";

-- update the topic_id numbers
UPDATE  phpbb_topics
    SET `topic_id` = `topic_id` + @BASE_TOPIC_COUNT
    ORDER BY `topic_id` DESC;
UPDATE phpbb_topics
    SET `topic_moved_id` = `topic_moved_id` + @BASE_TOPIC_COUNT;

UPDATE phpbb_posts
    SET `topic_id` = `topic_id` + @BASE_TOPIC_COUNT;

-- update topics posted table

UPDATE phpbb_topics_posted
    SET `user_id` = `user_id` + @BASE_USER_COUNT
    ORDER BY `user_id` DESC;

UPDATE phpbb_topics_posted
    SET `topic_id` = `topic_id` + @BASE_TOPIC_COUNT
    ORDER BY `topic_id` DESC;

-- update the user_id numbers
UPDATE phpbb_users
    SET `user_id` = `user_id` + @BASE_USER_COUNT;

UPDATE phpbb_topics
    SET `topic_poster` = `topic_poster` + @BASE_USER_COUNT;
UPDATE phpbb_topics
    SET `topic_last_poster_id` = `topic_last_poster_id` + @BASE_USER_COUNT;

UPDATE phpbb_forums
    SET `forum_last_poster_id` = `forum_last_poster_id` + @BASE_USER_COUNT;

UPDATE phpbb_posts
    SET `poster_id` = `poster_id` + @BASE_USER_COUNT;



-- update the post_id numbers
UPDATE phpbb_topics
    SET `topic_last_post_id` = `topic_last_post_id` + @BASE_POST_COUNT;
UPDATE phpbb_topics
    SET `topic_first_post_id` = `topic_first_post_id` + @BASE_POST_COUNT;

UPDATE phpbb_forums
    SET `forum_last_post_id` = `forum_last_post_id` + @BASE_POST_COUNT;

UPDATE phpbb_posts
    SET `post_id` = `post_id` + @BASE_POST_COUNT
    ORDER BY `post_id` DESC;



USE `BASE`; 



INSERT INTO BASE.phpbb3_forums (
    `forum_id`, `parent_id`,`left_id`, `right_id`, `forum_parents`, `forum_name`, `forum_desc`,
    `forum_desc_bitfield`, `forum_desc_options`, `forum_desc_uid`, `forum_link`, `forum_password`,
    `forum_style`, `forum_image`, `forum_rules`, `forum_rules_link`, `forum_rules_bitfield`,
    `forum_rules_options`, `forum_rules_uid`, `forum_topics_per_page`, `forum_type`, `forum_status`,
    `forum_posts`, `forum_topics`, `forum_topics_real`, `forum_last_post_id`, `forum_last_poster_id`,
    `forum_last_post_subject`, `forum_last_post_time`, `forum_last_poster_name`, `forum_last_poster_colour`,
    `forum_flags`, `forum_options`, `display_subforum_list`, `display_on_index`, `enable_indexing`,
    `enable_icons`, `enable_prune`, `prune_next`, `prune_days`, `prune_viewed`, `prune_freq`)
    SELECT `forum_id`, `parent_id`,`left_id`, `right_id`, `forum_parents`, `forum_name`, `forum_desc`,
        `forum_desc_bitfield`, `forum_desc_options`, `forum_desc_uid`, `forum_link`, `forum_password`,
        `forum_style`, `forum_image`, `forum_rules`, `forum_rules_link`, `forum_rules_bitfield`,
        `forum_rules_options`, `forum_rules_uid`, `forum_topics_per_page`, `forum_type`, `forum_status`,
        `forum_posts`, `forum_topics`, `forum_topics_real`, `forum_last_post_id`, `forum_last_poster_id`,
        `forum_last_post_subject`, `forum_last_post_time`, `forum_last_poster_name`, `forum_last_poster_colour`,
        `forum_flags`, `forum_options`, `display_subforum_list`, `display_on_index`, `enable_indexing`,
        `enable_icons`, `enable_prune`, `prune_next`, `prune_days`, `prune_viewed`, `prune_freq`
        FROM `NEW`.phpbb_forums;








INSERT INTO BASE.`phpbb3_posts` (
    `post_id`, `topic_id`, `forum_id`, `poster_id`, `icon_id`, `poster_ip`, `post_time`,
    `post_approved`, `post_reported`, `enable_bbcode`, `enable_smilies`, `enable_magic_url`,
    `enable_sig`, `post_username`, `post_subject`, `post_text`, `post_checksum`, `post_attachment`,
    `bbcode_bitfield`, `bbcode_uid`, `post_postcount`, `post_edit_time`, `post_edit_reason`, `post_edit_user`,
    `post_edit_count`, `post_edit_locked`)
    SELECT `post_id`, `topic_id`, `forum_id`, `poster_id`, `icon_id`, `poster_ip`, `post_time`,
        `post_approved`, `post_reported`, `enable_bbcode`, `enable_smilies`, `enable_magic_url`,
        `enable_sig`, `post_username`, `post_subject`, `post_text`, `post_checksum`, `post_attachment`,
        `bbcode_bitfield`, `bbcode_uid`, `post_postcount`, `post_edit_time`, `post_edit_reason`, `post_edit_user`,
        `post_edit_count`, `post_edit_locked`
        FROM `NEW`.phpbb_posts;






INSERT INTO BASE.phpbb3_topics (
    `topic_id`, `forum_id`,`icon_id`,`topic_attachment`,`topic_approved`,`topic_reported`,
    `topic_title`,`topic_poster`,`topic_time`,`topic_time_limit`,`topic_views`,`topic_replies`,
    `topic_replies_real`,`topic_status`,`topic_type`,`topic_first_post_id`,`topic_first_poster_name`,
    `topic_first_poster_colour`,`topic_last_post_id`,`topic_last_poster_id`,`topic_last_poster_name`,
    `topic_last_poster_colour`,`topic_last_post_subject`,`topic_last_post_time`,`topic_last_view_time`,
    `topic_moved_id`,`topic_bumped`,`topic_bumper`,`poll_title`,`poll_start`,`poll_length`,`poll_max_options`,
    `poll_last_vote`,`poll_vote_change`)
    SELECT `topic_id`, `forum_id`,`icon_id`,`topic_attachment`,`topic_approved`,`topic_reported`,
        `topic_title`,`topic_poster`,`topic_time`,`topic_time_limit`,`topic_views`,`topic_replies`,
        `topic_replies_real`,`topic_status`,`topic_type`,`topic_first_post_id`,`topic_first_poster_name`,
        `topic_first_poster_colour`,`topic_last_post_id`,`topic_last_poster_id`,`topic_last_poster_name`,
        `topic_last_poster_colour`,`topic_last_post_subject`,`topic_last_post_time`,`topic_last_view_time`,
        `topic_moved_id`,`topic_bumped`,`topic_bumper`,`poll_title`,`poll_start`,`poll_length`,`poll_max_options`,
        `poll_last_vote`,`poll_vote_change`
        FROM `NEW`.phpbb_topics;



INSERT INTO BASE.`phpbb3_users` (
    `user_id`,`user_type`,`group_id`,`user_permissions`,`user_perm_from`,`user_ip`,`user_regdate`,
    `username`,`username_clean`,`user_password`,`user_passchg`,`user_pass_convert`,`user_email`,`user_email_hash`,
    `user_birthday`,`user_lastvisit`,`user_lastmark`,`user_lastpost_time`,`user_lastpage`,`user_last_confirm_key`,
    `user_last_search`,`user_warnings`,`user_last_warning`,`user_login_attempts`,`user_inactive_reason`,
    `user_inactive_time`,`user_posts`,`user_lang`,`user_timezone`,`user_dst`,`user_dateformat`,
    `user_style`,`user_rank`,`user_colour`,`user_new_privmsg`,`user_unread_privmsg`,`user_last_privmsg`,
    `user_message_rules`,`user_full_folder`,`user_emailtime`,`user_topic_show_days`,`user_topic_sortby_type`,
    `user_topic_sortby_dir`,`user_post_show_days`,`user_post_sortby_type`,`user_post_sortby_dir`,
    `user_notify`,`user_notify_pm`,`user_notify_type`,`user_allow_pm`,`user_allow_viewonline`,
    `user_allow_viewemail`,`user_allow_massemail`,`user_options`,`user_avatar`,`user_avatar_type`,
    `user_avatar_width`,`user_avatar_height`,`user_sig`,`user_sig_bbcode_uid`,`user_sig_bbcode_bitfield`,
    `user_from`,`user_icq`,`user_aim`,`user_yim`,`user_msnm`,`user_jabber`,`user_website`,`user_occ`,`user_interests`,
    `user_actkey`,`user_newpasswd`,`user_form_salt`,`user_new`,`user_reminded`,`user_reminded_time`)
    SELECT `user_id`,`user_type`,`group_id`,`user_permissions`,`user_perm_from`,`user_ip`,`user_regdate`,
        `username`,CONCAT(`username_clean`, "_old"),`user_password`,`user_passchg`,`user_pass_convert`,`user_email`,`user_email_hash`,
        `user_birthday`,`user_lastvisit`,`user_lastmark`,`user_lastpost_time`,`user_lastpage`,`user_last_confirm_key`,
        `user_last_search`,`user_warnings`,`user_last_warning`,`user_login_attempts`,`user_inactive_reason`,
        `user_inactive_time`,`user_posts`,`user_lang`,`user_timezone`,`user_dst`,`user_dateformat`,
        `user_style`,`user_rank`,`user_colour`,`user_new_privmsg`,`user_unread_privmsg`,`user_last_privmsg`,
        `user_message_rules`,`user_full_folder`,`user_emailtime`,`user_topic_show_days`,`user_topic_sortby_type`,
        `user_topic_sortby_dir`,`user_post_show_days`,`user_post_sortby_type`,`user_post_sortby_dir`,
        `user_notify`,`user_notify_pm`,`user_notify_type`,`user_allow_pm`,`user_allow_viewonline`,
        `user_allow_viewemail`,`user_allow_massemail`,`user_options`,`user_avatar`,`user_avatar_type`,
        `user_avatar_width`,`user_avatar_height`,`user_sig`,`user_sig_bbcode_uid`,`user_sig_bbcode_bitfield`,
        `user_from`,`user_icq`,`user_aim`,`user_yim`,`user_msnm`,`user_jabber`,`user_website`,`user_occ`,`user_interests`,
        `user_actkey`,`user_newpasswd`,`user_form_salt`,`user_new`,`user_reminded`,`user_reminded_time`
        FROM `NEW`.phpbb_users;



INSERT INTO BASE.phpbb3_topics_posted (user_id, topic_id, topic_posted)
    (SELECT user_id, topic_id, topic_posted 
        FROM `NEW`.phpbb_topics_posted);