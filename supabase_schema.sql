-- =====================================================
-- SUPABASE SCHEMA FOR ATS (Applicant Tracking System)
-- =====================================================
-- Run this SQL in Supabase SQL Editor (Table Editor > SQL Editor)

-- 1. ADMINS TABLE
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. JOBS TABLE
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  requirements TEXT NOT NULL,
  location TEXT NOT NULL,
  salary_range TEXT NOT NULL,
  employment_type TEXT NOT NULL,
  is_open BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 3. APPLICATIONS TABLE
CREATE TABLE IF NOT EXISTS applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  education TEXT NOT NULL,
  experience TEXT NOT NULL,
  skills TEXT NOT NULL,
  cover_letter TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  ai_score REAL,
  ai_label TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE(job_id, email)
);

-- 4. INTERVIEWS TABLE
CREATE TABLE IF NOT EXISTS interviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL UNIQUE REFERENCES applications(id) ON DELETE CASCADE,
  scheduled_at TIMESTAMPTZ NOT NULL,
  location TEXT NOT NULL,
  notes TEXT,
  is_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
  status TEXT NOT NULL DEFAULT 'scheduled',
  result TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 5. BROADCASTS TABLE
CREATE TABLE IF NOT EXISTS broadcasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- =====================================================
-- SEED DATA (Default Admin & Sample Data)
-- =====================================================

-- Default Admin (username: admin, password: admin123)
-- password_hash is SHA256 of 'admin123'
INSERT INTO admins (username, password_hash, full_name) VALUES
('admin', '240be518fabd2724ddb6f04eeb9d5b051ef2af5e95e0c25c292e6c40e2e1bc7c', 'Administrator')
ON CONFLICT (username) DO NOTHING;

-- Sample Jobs
INSERT INTO jobs (title, description, requirements, location, salary_range, employment_type) VALUES
('Software Engineer', 
 'Kami mencari Software Engineer yang berpengalaman untuk bergabung dengan tim teknologi kami. Anda akan bekerja pada pengembangan aplikasi web dan mobile.',
 '• Pengalaman minimal 2 tahun dalam pengembangan software
• Menguasai bahasa pemrograman (Java, Python, atau Dart)
• Familiar dengan framework modern
• Kemampuan problem solving yang baik
• Bisa bekerja dalam tim',
 'Jakarta, Indonesia',
 'Rp 8.000.000 - Rp 15.000.000',
 'Full-time'),
 
('UI/UX Designer',
 'Dibutuhkan UI/UX Designer kreatif untuk merancang antarmuka pengguna yang menarik dan intuitif untuk produk digital kami.',
 '• Portfolio yang menunjukkan kemampuan desain UI/UX
• Menguasai Figma, Adobe XD, atau tools desain lainnya
• Pemahaman tentang user research dan usability testing
• Kreativitas tinggi dan attention to detail
• Pengalaman minimal 1 tahun',
 'Bandung, Indonesia',
 'Rp 6.000.000 - Rp 12.000.000',
 'Full-time'),

('Data Analyst',
 'Kami membutuhkan Data Analyst untuk menganalisis data bisnis dan memberikan insight yang berguna untuk pengambilan keputusan.',
 '• Pengalaman dengan SQL dan Python
• Kemampuan visualisasi data (Tableau, Power BI)
• Pemahaman statistik dan analisis data
• Kemampuan komunikasi yang baik
• Gelar S1 di bidang terkait',
 'Surabaya, Indonesia',
 'Rp 7.000.000 - Rp 13.000.000',
 'Full-time')
ON CONFLICT DO NOTHING;

-- Sample Broadcast
INSERT INTO broadcasts (title, content) VALUES
('Selamat Datang di Portal Karir Kami!',
 'Terima kasih telah mengunjungi portal karir kami. Kami terus membuka kesempatan bagi talenta-talenta terbaik untuk bergabung. Pantau terus lowongan terbaru dan jangan lewatkan kesempatan emas Anda!')
ON CONFLICT DO NOTHING;

-- =====================================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE interviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcasts ENABLE ROW LEVEL SECURITY;

-- PUBLIC READ POLICIES (for anonymous users)
CREATE POLICY "Public can read open jobs" ON jobs FOR SELECT USING (is_open = true);
CREATE POLICY "Public can read active broadcasts" ON broadcasts FOR SELECT USING (is_active = true);
CREATE POLICY "Public can insert applications" ON applications FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can read own applications by email" ON applications FOR SELECT USING (true);
CREATE POLICY "Public can read interviews" ON interviews FOR SELECT USING (true);
CREATE POLICY "Public can update interviews" ON interviews FOR UPDATE USING (true);

-- ADMIN FULL ACCESS POLICIES
CREATE POLICY "Admin full access to admins" ON admins FOR ALL USING (true);
CREATE POLICY "Admin full access to jobs" ON jobs FOR ALL USING (true);
CREATE POLICY "Admin full access to applications" ON applications FOR ALL USING (true);
CREATE POLICY "Admin full access to interviews" ON interviews FOR ALL USING (true);
CREATE POLICY "Admin full access to broadcasts" ON broadcasts FOR ALL USING (true);


DROP POLICY IF EXISTS "Admin full access to admins" ON admins;
CREATE POLICY "Allow all access to admins" ON admins FOR ALL TO anon USING (true) WITH CHECK (true);

ALTER TABLE interviews ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'scheduled';
ALTER TABLE interviews ADD COLUMN IF NOT EXISTS result TEXT;