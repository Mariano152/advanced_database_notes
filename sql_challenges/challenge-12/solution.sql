/* ============================================================
   SQL Challenge 12 - KPI Dashboards
   Lesson 07 - 2026-05-19
   ============================================================ */

/* ============================================================
   Setup - Enrich schema
   ============================================================ */

ALTER TABLE tasks ADD (
    priority      VARCHAR2(10) DEFAULT 'medium',
    due_date      DATE,
    completed_at  TIMESTAMP,
    tags          VARCHAR2(200)
);

ALTER TABLE tasks ADD CONSTRAINT chk_task_priority
    CHECK (priority IN ('low', 'medium', 'high', 'critical'));

ALTER TABLE tasks DROP CONSTRAINT chk_task_status;

ALTER TABLE tasks ADD CONSTRAINT chk_task_status
    CHECK (status IN ('open', 'in_progress', 'blocked', 'completed', 'cancelled'));

COMMIT;

SELECT column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name = 'TASKS'
ORDER BY column_id;

/* ============================================================
   Exercise 1 - Define Team Velocity
   ============================================================ */

-- Business question:
-- How fast does each team complete work?
--
-- Definition:
-- Team velocity = completed tasks per team member.
-- I count tasks with status = 'completed' and a completed_at value.
-- I normalize by team size because Product and Engineering can have different
-- numbers of people.
--
-- Edge cases:
-- Teams with no users should not divide by zero. Teams with no completed tasks
-- should show velocity 0.
--
-- Unit:
-- Completed tasks per team member.
--
-- Graph suggestion:
-- Bar chart by team_name, colored by velocity_flag.

WITH team_stats AS (
    SELECT t.id,
           t.name AS team_name,
           COUNT(DISTINCT u.id) AS member_count,
           COUNT(CASE
                     WHEN ts.status = 'completed'
                      AND ts.completed_at IS NOT NULL
                     THEN 1
                 END) AS completed_tasks
    FROM teams t
    LEFT JOIN users u ON u.team_id = t.id
    LEFT JOIN tasks ts ON ts.assigned_to = u.id
    GROUP BY t.id, t.name
),
velocity AS (
    SELECT team_name,
           member_count,
           completed_tasks,
           ROUND(completed_tasks / NULLIF(member_count, 0), 2) AS team_velocity
    FROM team_stats
)
SELECT team_name,
       member_count,
       completed_tasks,
       NVL(team_velocity, 0) AS team_velocity,
       CASE
           WHEN NVL(team_velocity, 0) < AVG(NVL(team_velocity, 0)) OVER ()
           THEN 'Below average'
           ELSE 'At or above average'
       END AS velocity_flag
FROM velocity
ORDER BY team_velocity DESC;

/* ============================================================
   Exercise 2 - Define On-Time Delivery Rate
   ============================================================ */

-- Business question:
-- Are tasks being completed by their deadlines?
--
-- Definition:
-- On-time means the task was completed any time before the end of its due_date.
-- A task completed at 23:59 on the due date is on time. A task completed after
-- midnight the next day is late.
--
-- Filters:
-- Only completed tasks with due_date and completed_at are included.
--
-- Edge cases:
-- Tasks without due_date are excluded because they do not have a deadline.
-- Cancelled tasks are excluded because they were not delivered.
--
-- Unit:
-- Percentage by priority, plus average lateness in hours.
--
-- Graph suggestion:
-- Bar chart by priority for on_time_rate_pct.

SELECT priority,
       COUNT(*) AS completed_task_count,
       COUNT(CASE
                 WHEN CAST(completed_at AS DATE) < due_date + 1
                 THEN 1
             END) AS on_time_count,
       ROUND(
           COUNT(CASE
                     WHEN CAST(completed_at AS DATE) < due_date + 1
                     THEN 1
                 END) * 100 / COUNT(*),
           1
       ) AS on_time_rate_pct,
       ROUND(
           AVG(CASE
                   WHEN CAST(completed_at AS DATE) >= due_date + 1
                   THEN (CAST(completed_at AS DATE) - (due_date + 1)) * 24
               END),
           1
       ) AS avg_lateness_hours
FROM tasks
WHERE status = 'completed'
  AND completed_at IS NOT NULL
  AND due_date IS NOT NULL
GROUP BY priority
ORDER BY CASE priority
             WHEN 'critical' THEN 1
             WHEN 'high' THEN 2
             WHEN 'medium' THEN 3
             WHEN 'low' THEN 4
         END;

/* ============================================================
   Exercise 3 - Improve Tasks Per Team
   ============================================================ */

-- Problem with original KPI:
-- Counting all tasks can make a team look busy even if most tasks are already
-- completed or cancelled.
--
-- Definition:
-- total_tasks = all assigned tasks.
-- active_tasks = open, in_progress, or blocked.
-- completion_rate = completed / all non-cancelled tasks.
--
-- Unit:
-- Counts and percentage.
--
-- Graph suggestion:
-- Grouped bar chart for total_tasks and active_tasks by team.

SELECT t.name AS team_name,
       COUNT(ts.id) AS total_tasks,
       COUNT(CASE
                 WHEN ts.status IN ('open', 'in_progress', 'blocked')
                 THEN 1
             END) AS active_tasks,
       ROUND(
           COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100
           / NULLIF(COUNT(CASE WHEN ts.status <> 'cancelled' THEN 1 END), 0),
           1
       ) AS completion_rate_pct,
       CASE
           WHEN COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN 1 END) > 10
           THEN 'Overloaded'
           WHEN COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN 1 END) BETWEEN 5 AND 10
           THEN 'Healthy'
           ELSE 'Underutilized'
       END AS health_score
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
LEFT JOIN tasks ts ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY active_tasks DESC;

/* ============================================================
   Exercise 4 - Improve Average Resolution Time
   ============================================================ */

-- Problem with original KPI:
-- Averaging all completed tasks together hides priority differences.
--
-- Definition:
-- Resolution time = completed_at - created_at, measured in hours.
-- Only completed tasks with completed_at are included.
--
-- SLA targets:
-- critical = 24h, high = 72h, medium = 168h, low = 336h.
--
-- Edge cases:
-- If a priority has only one completed task, the result is still shown but
-- should be interpreted carefully.
--
-- Graph suggestion:
-- Bar chart by priority for avg_resolution_hours with target_met as color.

WITH completed_tasks AS (
    SELECT priority,
           (
               EXTRACT(DAY FROM (completed_at - created_at)) * 24
               + EXTRACT(HOUR FROM (completed_at - created_at))
               + EXTRACT(MINUTE FROM (completed_at - created_at)) / 60
           ) AS resolution_hours
    FROM tasks
    WHERE status = 'completed'
      AND completed_at IS NOT NULL
)
SELECT priority,
       COUNT(*) AS completed_task_count,
       ROUND(AVG(resolution_hours), 1) AS avg_resolution_hours,
       ROUND(
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_hours),
           1
       ) AS median_resolution_hours,
       ROUND(MIN(resolution_hours), 1) AS fastest_hours,
       ROUND(MAX(resolution_hours), 1) AS slowest_hours,
       CASE
           WHEN priority = 'critical' AND AVG(resolution_hours) <= 24 THEN 'Target met'
           WHEN priority = 'high' AND AVG(resolution_hours) <= 72 THEN 'Target met'
           WHEN priority = 'medium' AND AVG(resolution_hours) <= 168 THEN 'Target met'
           WHEN priority = 'low' AND AVG(resolution_hours) <= 336 THEN 'Target met'
           ELSE 'Target missed'
       END AS target_met
FROM completed_tasks
GROUP BY priority
ORDER BY CASE priority
             WHEN 'critical' THEN 1
             WHEN 'high' THEN 2
             WHEN 'medium' THEN 3
             WHEN 'low' THEN 4
         END;

/* ============================================================
   Exercise 5 - Improve Overdue Tasks
   ============================================================ */

-- Problem with original KPI:
-- A simple overdue count does not show who owns the work, how late it is, or
-- whether the overdue task is business critical.
--
-- Definition:
-- A task is overdue when due_date is before today and the task is not completed
-- or cancelled.
--
-- Unit:
-- Days overdue.
--
-- Graph suggestion:
-- Horizontal bar chart by title, colored by severity.

WITH overdue AS (
    SELECT ts.title,
           u.full_name AS assignee,
           t.name AS team_name,
           ts.priority,
           ts.due_date,
           TRUNC(SYSDATE) - ts.due_date AS days_overdue,
           CASE
               WHEN ts.priority = 'critical'
                AND TRUNC(SYSDATE) - ts.due_date > 0
               THEN 'CRITICAL'
               WHEN ts.priority = 'high'
                AND TRUNC(SYSDATE) - ts.due_date > 2
               THEN 'HIGH'
               WHEN ts.priority = 'medium'
                AND TRUNC(SYSDATE) - ts.due_date > 5
               THEN 'MEDIUM'
               ELSE 'LOW'
           END AS severity
    FROM tasks ts
    LEFT JOIN users u ON u.id = ts.assigned_to
    LEFT JOIN teams t ON t.id = u.team_id
    WHERE ts.due_date < TRUNC(SYSDATE)
      AND ts.status NOT IN ('completed', 'cancelled')
      AND ts.due_date IS NOT NULL
)
SELECT title,
       assignee,
       team_name,
       priority,
       due_date,
       days_overdue,
       severity
FROM overdue
ORDER BY CASE severity
             WHEN 'CRITICAL' THEN 1
             WHEN 'HIGH' THEN 2
             WHEN 'MEDIUM' THEN 3
             WHEN 'LOW' THEN 4
         END,
         days_overdue DESC;

-- Summary by severity.
WITH overdue AS (
    SELECT ts.priority,
           TRUNC(SYSDATE) - ts.due_date AS days_overdue,
           CASE
               WHEN ts.priority = 'critical'
                AND TRUNC(SYSDATE) - ts.due_date > 0
               THEN 'CRITICAL'
               WHEN ts.priority = 'high'
                AND TRUNC(SYSDATE) - ts.due_date > 2
               THEN 'HIGH'
               WHEN ts.priority = 'medium'
                AND TRUNC(SYSDATE) - ts.due_date > 5
               THEN 'MEDIUM'
               ELSE 'LOW'
           END AS severity
    FROM tasks ts
    WHERE ts.due_date < TRUNC(SYSDATE)
      AND ts.status NOT IN ('completed', 'cancelled')
      AND ts.due_date IS NOT NULL
)
SELECT severity,
       COUNT(*) AS overdue_count,
       ROUND(AVG(days_overdue), 1) AS avg_days_overdue
FROM overdue
GROUP BY severity
ORDER BY CASE severity
             WHEN 'CRITICAL' THEN 1
             WHEN 'HIGH' THEN 2
             WHEN 'MEDIUM' THEN 3
             WHEN 'LOW' THEN 4
         END;

/* ============================================================
   Exercise 6 - Fix the Productivity Score
   ============================================================ */

-- Problem:
-- The bad query counts assigned tasks, not completed work. It treats a low
-- priority task the same as a critical task and does not measure delivery.
--
-- Better KPI:
-- Completed tasks per day, weighted by priority.
--
-- Weight:
-- critical = 4, high = 3, medium = 2, low = 1.
--
-- Graph suggestion:
-- Bar chart by full_name for weighted_completed_per_day.

WITH completed AS (
    SELECT u.id,
           u.full_name,
           ts.created_at,
           ts.completed_at,
           CASE ts.priority
               WHEN 'critical' THEN 4
               WHEN 'high' THEN 3
               WHEN 'medium' THEN 2
               WHEN 'low' THEN 1
               ELSE 1
           END AS priority_weight
    FROM users u
    LEFT JOIN tasks ts ON ts.assigned_to = u.id
                      AND ts.status = 'completed'
                      AND ts.completed_at IS NOT NULL
)
SELECT full_name,
       COUNT(completed_at) AS completed_tasks,
       NVL(SUM(priority_weight), 0) AS weighted_completed_tasks,
       ROUND(
           NVL(SUM(priority_weight), 0)
           / NULLIF(
               GREATEST(
                   1,
                   MAX(CAST(completed_at AS DATE)) - MIN(CAST(created_at AS DATE)) + 1
               ),
               0
           ),
           2
       ) AS weighted_completed_per_day
FROM completed
GROUP BY id, full_name
ORDER BY weighted_completed_per_day DESC;

/* ============================================================
   Exercise 7 - Fix the Team Efficiency
   ============================================================ */

-- Problem:
-- Average task ID is not a business metric. IDs are identifiers, not values.
--
-- Better KPI:
-- Team efficiency = completed tasks / total non-cancelled tasks.
--
-- Graph suggestion:
-- Bar chart by team_name for team_efficiency_pct.

SELECT t.name AS team_name,
       COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) AS completed_tasks,
       COUNT(CASE WHEN ts.status <> 'cancelled' THEN 1 END) AS total_non_cancelled_tasks,
       ROUND(
           COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100
           / NULLIF(COUNT(CASE WHEN ts.status <> 'cancelled' THEN 1 END), 0),
           1
       ) AS team_efficiency_pct
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
LEFT JOIN tasks ts ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY team_efficiency_pct DESC NULLS LAST;

/* ============================================================
   Exercise 8 - Fix the Urgency Index
   ============================================================ */

-- Problem:
-- The bad query tries to multiply a VARCHAR priority and add a date. That is
-- not a valid or meaningful calculation.
--
-- Better KPI:
-- Convert priority to a number and combine it with due-date pressure.
-- days_until_due is positive for future work and negative for overdue work.
-- urgency_score = priority_weight * 10 - days_until_due.
-- This makes overdue and high-priority tasks score higher.
--
-- Graph suggestion:
-- Bar chart of top urgent tasks ordered by urgency_score.

SELECT title,
       status,
       priority,
       due_date,
       CASE priority
           WHEN 'critical' THEN 4
           WHEN 'high' THEN 3
           WHEN 'medium' THEN 2
           WHEN 'low' THEN 1
           ELSE 1
       END AS priority_weight,
       due_date - TRUNC(SYSDATE) AS days_until_due,
       (
           CASE priority
               WHEN 'critical' THEN 4
               WHEN 'high' THEN 3
               WHEN 'medium' THEN 2
               WHEN 'low' THEN 1
               ELSE 1
           END * 10
       ) - (due_date - TRUNC(SYSDATE)) AS urgency_score
FROM tasks
WHERE status NOT IN ('completed', 'cancelled')
  AND due_date IS NOT NULL
ORDER BY urgency_score DESC;
