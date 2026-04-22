"""
Database Infrastructure & Contract Tests

These tests validate:
- Connectivity & reachability
- Authentication & least privilege
- Schema expectations
- Data integrity constraints
- Transaction behaviour
"""

import socket
import pytest
import mysql

DB_HOST = "${database_private_ip}"
DB_PORT = 3306
DB_NAME = "directus"
DB_USER = "user"
DB_PASSWORD = "password123"
CONNECT_TIMEOUT = 5

class DB_Tests:


    @pytest.fixture(scope="module")
    def db_connection(self):
        """
        Setup the database connection and make it available
        to all test suites before tearing down the connection.
        """
        conn = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            connection_timeout=CONNECT_TIMEOUT,
            autocommit=False,
        )
        yield conn
        conn.close()

    @pytest.fixture()
    def cursor(self, db_connection):
        """
        Setup the database cursor and make it available to
        all test suites before closing it.
        """
        cur = db_connection.cursor(self, dictionary=True)
        yield cur
        cur.close()

    def test_dns_resolution(self):
        """DB hostname must resolve."""
        ip = socket.gethostbyname(DB_HOST)
        assert ip, "DNS resolution failed"


    def test_db_port_open(self):
        """DB port must be reachable."""
        sock = socket.create_connection((DB_HOST, DB_PORT), timeout=CONNECT_TIMEOUT)
        sock.close()


    def test_db_login(self, db_connection):
        """Credentials must allow login."""
        assert db_connection.is_connected()


    def test_no_admin_privileges(self, cursor):
        """App DB user must not have admin privileges."""
        cursor.execute("SHOW GRANTS FOR CURRENT_USER")
        grants = " ".join(row[list(row.keys())[0]] for row in cursor.fetchall())

        forbidden = ["SUPER", "ALL PRIVILEGES", "GRANT OPTION"]
        for privilege in forbidden:
            assert privilege not in grants, f"Forbidden privilege found: {privilege}"


    def test_drop_table_not_allowed(self, cursor):
        """Ensure destructive ops are blocked."""
        with pytest.raises(mysql.connector.Error):
            cursor.execute("DROP TABLE users")

    def test_required_tables_exist(self, cursor):
        """Core tables must exist."""
        cursor.execute(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s
            """,
            (DB_NAME,),
        )

        tables = {row["table_name"] for row in cursor.fetchall()}
        expected = {"users"}  # extend as needed

        missing = expected - tables
        assert not missing, f"Missing tables: {missing}"


    def test_users_table_schema(self, cursor):
        """Users table schema must match expectations."""
        cursor.execute(
            """
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = %s
            AND table_name = 'users'
            """,
            (DB_NAME,),
        )

        cols = {row["column_name"]: row["data_type"] for row in cursor.fetchall()}

        assert cols.get("id") in ("int", "bigint")
        assert cols.get("email") == "varchar"

    def test_unique_constraint_enforced(self, cursor, db_connection):
        """Email uniqueness must be enforced."""
        try:
            cursor.execute(
                "INSERT INTO users (email) VALUES ('infra-test@example.com')"
            )
            cursor.execute(
                "INSERT INTO users (email) VALUES ('infra-test@example.com')"
            )
            db_connection.commit()
            pytest.fail("Duplicate insert should fail")
        except mysql.connector.Error as e:
            assert e.errno == mysql.connector.errorcode.ER_DUP_ENTRY
            db_connection.rollback()


    def test_transaction_rollback(self, cursor, db_connection):
        """Transactions must roll back cleanly."""
        cursor.execute(
            "INSERT INTO users (email) VALUES ('rollback-test@example.com')"
        )
        db_connection.rollback()

        cursor.execute(
            "SELECT COUNT(*) AS cnt FROM users WHERE email='rollback-test@example.com'"
        )
        result = cursor.fetchone()
        assert result["cnt"] == 0

    def test_time_zone_is_utc(self, cursor):
        """DB should run in UTC to avoid drift bugs."""
        cursor.execute("SELECT @@time_zone AS tz")
        tz = cursor.fetchone()["tz"]
        assert tz in ("UTC", "+00:00")
