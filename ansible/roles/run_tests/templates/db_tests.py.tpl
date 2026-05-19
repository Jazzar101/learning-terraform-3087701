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
import mysql.connector

DB_HOST = "${database_private_ip}"
DB_PORT = 3306
DB_NAME = "directus"
DB_USER = "user"
DB_PASSWORD = "password123"
CONNECT_TIMEOUT = 5

class Test_Database:


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
        cursor.execute("SHOW GRANTS FOR CURRENT_USER")

        grants = [
            row[list(row.keys())[0]]
            for row in cursor.fetchall()
        ]

        forbidden_substrings = [
            "SUPER",
            "GRANT OPTION",
            "ALL PRIVILEGES ON *.*",
        ]

        for grant in grants:
            for forbidden in forbidden_substrings:
                assert forbidden not in grant, f"Forbidden privilege found: {grant}"

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

        tables = {row["TABLE_NAME"] for row in cursor.fetchall()}
        expected = {"directus_users"}  # extend as needed

        missing = expected - tables
        assert not missing, f"Missing tables: {missing}"


    def test_users_table_schema(self, cursor):
        """Users table schema must match expectations."""
        cursor.execute(
            """
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = %s
            AND table_name = 'directus_users'
            """,
            (DB_NAME,),
        )

        cols = {row["COLUMN_NAME"]: row["DATA_TYPE"] for row in cursor.fetchall()}
        assert "id" in cols.keys(), f"Col Names: {cols.keys()}"
        assert "email" in cols.keys(), f"Col Names: {cols.keys()}"
        assert cols.get("id") == "char", f"Fail: ID col is type: {cols.get('id')}"
        assert cols.get("email") == "varchar", f"Fail: email col is type: {cols.get('email')}"

    def test_unique_constraint_enforced(self, cursor, db_connection):
        """Email uniqueness must be enforced."""
        try:
            cursor.execute(
                "INSERT INTO directus_users (id, email) VALUES (UUID(), 'infra-test@example.com')"
            )
            cursor.execute(
                "INSERT INTO directus_users (id, email) VALUES (UUID(), 'infra-test@example.com')"
            )
            db_connection.commit()
            pytest.fail("Duplicate insert should fail")
        except mysql.connector.Error as e:
            assert e.errno == mysql.connector.errorcode.ER_DUP_ENTRY
            db_connection.rollback()


    def test_transaction_rollback(self, cursor, db_connection):
        """Transactions must roll back cleanly."""
        cursor.execute(
            "INSERT INTO directus_users (id, email) VALUES (UUID(), 'rollback-test@example.com')"
        )
        db_connection.rollback()

        cursor.execute(
            "SELECT COUNT(*) AS ROW_COUNT FROM directus_users WHERE email='rollback-test@example.com'"
        )
        result = cursor.fetchone()
        assert result["ROW_COUNT"] == 0

    def test_time_zone_is_utc(self, cursor):
        """
        Verify the database operates in UTC by comparing NOW() with UTC_TIMESTAMP().
        """

        cursor.execute("""
            SELECT TIMESTAMPDIFF(SECOND, UTC_TIMESTAMP(), NOW()) AS UTC_OFFSET
        """)

        result = cursor.fetchone()

        # Extract the value safely (MySQL uppercases aliases)
        utc_offset = result["UTC_OFFSET"]

        assert utc_offset == 0, (
            f"Database is not running in UTC (offset={utc_offset} seconds)"
        )
