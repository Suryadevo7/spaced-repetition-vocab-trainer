-- Sample data. Run AFTER `alembic upgrade head`:
--   sqlite3 srs.db < seed_data.sql
-- Dates are relative to "now", so the demo always has due + upcoming words.
-- Latest review per word = its current SRS state.

INSERT INTO words (id, word, definition, language) VALUES
 (1, 'ephemeral',   'lasting a very short time',                 'English'),
 (2, 'ubiquitous',  'present or found everywhere',               'English'),
 (3, 'serendipity', 'a happy accident or pleasant surprise',     'English'),
 (4, 'Fernweh',     'longing for far-away places',               'German'),
 (5, 'Schadenfreude','pleasure at another''s misfortune',         'German'),
 (6, 'mañana',      'tomorrow',                                  'Spanish'),
 (7, 'sobremesa',   'time spent chatting at the table after a meal', 'Spanish'),
 (8, 'komorebi',    'sunlight filtering through trees',          'Japanese');
-- words 4 and 8 have no reviews -> due immediately (new words)

INSERT INTO reviews (word_id, review_date, score, interval, easiness_factor, repetition, next_review) VALUES
 -- word 1: three good reviews, next one in 5 days
 (1, datetime('now','-14 days'), 5, 5, 2.6,  1, datetime('now','start of day','-9 days')),
 (1, datetime('now','-8 days'),  4, 6, 2.6,  2, datetime('now','start of day','-2 days')),
 (1, datetime('now','-2 days'),  5, 7, 2.7,  3, datetime('now','start of day','+5 days')),
 -- word 2: failed yesterday -> due today
 (2, datetime('now','-5 days'),  4, 3, 2.5,  1, datetime('now','start of day','-2 days')),
 (2, datetime('now','-1 days'),  1, 1, 2.5,  0, datetime('now','start of day')),
 -- word 3: due today after a hard pass
 (3, datetime('now','-4 days'),  3, 2, 2.36, 1, datetime('now','start of day','-2 days')),
 (3, datetime('now','-3 days'),  3, 6, 2.22, 2, datetime('now','start of day')),
 -- word 5: upcoming in 2 days
 (5, datetime('now','-1 days'),  4, 3, 2.5,  1, datetime('now','start of day','+2 days')),
 -- word 6: upcoming in 6 days
 (6, datetime('now','-1 days'),  5, 5, 2.6,  1, datetime('now','start of day','+4 days')),
 -- word 7: struggling word
 (7, datetime('now','-3 days'),  0, 1, 2.5,  0, datetime('now','start of day','-2 days')),
 (7, datetime('now','-2 days'),  2, 1, 2.5,  0, datetime('now','start of day','-1 days')),
 (7, datetime('now','-1 days'),  3, 2, 2.36, 1, datetime('now','start of day','+1 days'));
