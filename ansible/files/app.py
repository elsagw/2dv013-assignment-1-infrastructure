import configparser
import os
import psycopg2
from flask import Flask, render_template

app = Flask(__name__)

CONFIG_PATH = "/etc/webapp/config.ini"

config = configparser.ConfigParser()
config.read(CONFIG_PATH)

DB_HOST = config.get("database", "host", fallback="no-ip")
DB_NAME = config.get("database", "name", fallback="wrongappdb")
DB_USER = config.get("database", "user", fallback="wrongappuser")
DB_PASSWORD = config.get("database", "password", fallback="wrongapppassword")
APP_PORT = config.getint("server", "port", fallback=8080)


def init_db(cur):
    """Ensure table and initial row exist."""
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS page_views (
            id INT PRIMARY KEY,
            views INT NOT NULL
        );
    """
    )
    cur.execute(
        """
        INSERT INTO page_views (id, views)
        VALUES (1, 0)
        ON CONFLICT (id) DO NOTHING;
    """
    )


@app.route("/")
def index():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=3,
        )
        cur = conn.cursor()

        # Initialize schema if needed
        init_db(cur)

        # Increment visit counter and fetch updated count
        cur.execute(
            """
            UPDATE page_views
            SET views = views + 1
            WHERE id = 1
            RETURNING views;
        """
        )
        visit_count = cur.fetchone()[0]

        # Fetch DB version info
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]

        conn.commit()
        cur.close()
        conn.close()

        return render_template(
            "index.html",
            status="Connected to Database!",
            color="green",
            db_info=db_version,
            visit_count=visit_count,
        )
    except Exception as e:
        return render_template(
            "index.html",
            status="Database Connection Failed",
            color="red",
            db_info=str(e),
            visit_count="N/A",
        )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=APP_PORT)