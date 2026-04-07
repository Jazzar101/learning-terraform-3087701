-- Create admin user if not exists
INSERT INTO users (id, name, slug, password, email, status, created_at)
SELECT 1, 'Admin', 'admin-user', '$2a$12$WaTC5QUYjiVu/Ri7BkJBe.eukFfOrvAAb1lta5XPEz7aNhEl9UmgS', 'admin@admin.com', 'active', NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@example.com');

-- Assign Administrator role (role_id = 1)
INSERT INTO roles_users (id, role_id, user_id)
SELECT 1, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM roles_users WHERE user_id = 1);
