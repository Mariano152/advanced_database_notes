/* ============================================================
   SQL Challenge 11 - SQLAlchemy ORM And Alembic Migrations
   ============================================================ */

/* ============================================================
   Exercise 1 - Model Design
   ============================================================ */

-- SQL equivalent of the Comment model.
-- In the notebook, this table is created through SQLAlchemy + Alembic.

CREATE TABLE comments (
    id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id    NUMBER NOT NULL,
    user_id    NUMBER NOT NULL,
    content    VARCHAR2(1000) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_task
        FOREIGN KEY (task_id) REFERENCES tasks(id),
    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_comments_content
        CHECK (content IS NOT NULL AND LENGTH(TRIM(content)) > 0)
);

-- Python ORM model used in Colab:
/*
class Comment(Base):
    __tablename__ = "comments"

    id         = Column(Integer, primary_key=True)
    task_id    = Column(Integer, ForeignKey("tasks.id"), nullable=False)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    content    = Column(String(1000), nullable=False)
    created_at = Column(DateTime, server_default=func.current_timestamp())

    task = relationship("Task", back_populates="comments")
    user = relationship("User")

    def __repr__(self):
        return f"<Comment(id={self.id}, task_id={self.task_id}, user_id={self.user_id})>"

Task.comments = relationship("Comment", back_populates="task")
*/

-- Q1:
-- Comment should have a relationship with Task and User.

-- Q2:
-- Yes. Task should have a comments relationship because one task can have many
-- comments.

-- Q3:
-- When a task is deleted, its comments should also be deleted because comments
-- depend on the task.

/* ============================================================
   Exercise 2 - Migration Creation
   ============================================================ */

-- Alembic command used to generate the migration:
/*
command.revision(
    alembic_cfg,
    autogenerate=True,
    message="add comments table"
)

import glob

migration_files = sorted(
    glob.glob('/content/alembic/versions/*.py')
)

print("Generated migrations:")
for f in migration_files:
    print(f)

latest = migration_files[-1]

with open(latest) as f:
    print(f.read())
*/

-- Output:
-- Generating /content/alembic/versions/d70e1e9d4f97_add_comments_table.py ... done
-- Generated migrations:
-- /content/alembic/versions/3c1495999ff6_initial_schema.py
-- /content/alembic/versions/d70e1e9d4f97_add_comments_table.py

-- SQL equivalent of what upgrade() should do:
SELECT table_name
FROM user_tables
WHERE table_name = 'COMMENTS';

-- Q1:
-- upgrade() applies the migration. For this exercise, it should create the
-- comments table.

-- Q2:
-- downgrade() undoes the migration. For this exercise, it should drop the
-- comments table.

-- Q3:
-- If I downgrade this migration, the comments table is removed. Any data stored
-- in that table is also lost.

/* ============================================================
   Exercise 3 - CRUD Challenge
   ============================================================ */

-- SQL version of the CRUD steps.
-- The notebook version used SQLAlchemy ORM relationships.

INSERT INTO teams (name, description)
VALUES ('DevOps', 'Operations Team');

INSERT INTO users (username, email, full_name, team_id)
SELECT 'diana_ops', 'diana@example.com', 'Diana Ops', id
FROM teams
WHERE name = 'DevOps';

INSERT INTO tasks (title, description, status, assigned_to)
SELECT 'Deploy App', 'Deploy the latest application version', 'open', id
FROM users
WHERE username = 'diana_ops';

INSERT INTO tasks (title, description, status, assigned_to)
SELECT 'Monitor Servers', 'Monitor server health and logs', 'in_progress', id
FROM users
WHERE username = 'diana_ops';

INSERT INTO tasks (title, description, status, assigned_to)
SELECT 'Cleanup Logs', 'Delete old temporary logs', 'open', id
FROM users
WHERE username = 'diana_ops';

COMMIT;

SELECT COUNT(*) AS task_count
FROM tasks;

UPDATE tasks
SET status = 'closed'
WHERE title = 'Deploy App'
AND assigned_to = (
    SELECT id
    FROM users
    WHERE username = 'diana_ops'
);

DELETE FROM tasks
WHERE title = 'Cleanup Logs'
AND assigned_to = (
    SELECT id
    FROM users
    WHERE username = 'diana_ops'
);

COMMIT;

-- Python ORM version used in Colab:
/*
with Session(engine) as session:
    try:
        devops = Team(
            name="DevOps",
            description="Operations Team"
        )

        diana = User(
            username="diana_ops",
            email="diana@example.com",
            full_name="Diana Ops",
            team=devops
        )

        task1 = Task(
            title="Deploy App",
            description="Deploy the latest application version",
            status="open",
            assignee=diana
        )

        task2 = Task(
            title="Monitor Servers",
            description="Monitor server health and logs",
            status="in_progress",
            assignee=diana
        )

        task3 = Task(
            title="Cleanup Logs",
            description="Delete old temporary logs",
            status="open",
            assignee=diana
        )

        session.add(devops)
        session.commit()

        print("DevOps team, Diana user, and 3 tasks created.")
        print("Task count:", session.query(Task).count())

        task1.status = "closed"
        print("Closed task:", task1.title)

        session.delete(task3)
        print("Deleted lowest priority task:", task3.title)

        session.commit()
        print("CRUD challenge completed.")

    except IntegrityError as e:
        session.rollback()
        print("Integrity error. You probably already inserted DevOps or diana_ops.")
        print(e)

    except Exception as e:
        session.rollback()
        print("Error:")
        print(e)
*/

/* ============================================================
   Exercise 4 - Migration Rollback
   ============================================================ */

-- Alembic rollback used in Colab:
/*
command.downgrade(alembic_cfg, "-1")
print("Downgraded by 1. Last migration removed.")
*/

-- SQL equivalent of the rollback if the last migration created comments:
DROP TABLE comments PURGE;

-- Q1:
-- The last migration is undone. If the migration added a column, that column is
-- removed. If it added the comments table, that table is dropped.

-- Q2:
-- The data inside the removed column or table is lost.

/* ============================================================
   Exercise 5 - Concept Check
   ============================================================ */

-- Q1:
-- ORM is useful because I can work with Python objects instead of writing raw
-- SQL for every operation. It also makes relationships easier to use in code.

-- Q2:
-- Migrations are useful because they keep track of database schema changes over
-- time and make it easier to share those changes with a team.

-- Q3:
-- I would rollback when a migration has a mistake, breaks the application, or
-- adds something that should not stay in the database.

-- Q4:
-- add() puts an object into the SQLAlchemy session. commit() saves the pending
-- changes permanently in the database.

-- Q5:
-- Relationships are useful because they connect related objects, like a user
-- with tasks or a task with comments, without writing joins manually every time.
