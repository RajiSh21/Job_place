-- KaamKhojo Database Schema
-- PostgreSQL 14+

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                 VARCHAR(100),
  phone                VARCHAR(20) UNIQUE NOT NULL,
  email                VARCHAR(100),
  role                 VARCHAR(20) NOT NULL DEFAULT 'customer'
                         CHECK (role IN ('customer','worker','admin')),
  location_district    VARCHAR(100),
  location_city        VARCHAR(100),
  location_municipality VARCHAR(100),
  location_ward        INTEGER,
  profile_photo        TEXT,
  fcm_token            TEXT,
  is_active            BOOLEAN DEFAULT true,
  created_at           TIMESTAMP DEFAULT NOW(),
  updated_at           TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role);

-- ============================================================
-- WORKERS
-- ============================================================
CREATE TABLE IF NOT EXISTS workers (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  skills                 TEXT[] NOT NULL DEFAULT '{}',
  bio                    TEXT,
  hourly_rate            DECIMAL(10,2),
  fixed_rate             DECIMAL(10,2),
  availability_days      TEXT[] DEFAULT '{}',
  availability_start_time TIME,
  availability_end_time  TIME,
  is_verified            BOOLEAN DEFAULT false,
  is_featured            BOOLEAN DEFAULT false,
  nid_number             VARCHAR(50),
  rating_avg             DECIMAL(3,2) DEFAULT 0,
  rating_punctuality     DECIMAL(3,2) DEFAULT 0,
  rating_quality         DECIMAL(3,2) DEFAULT 0,
  rating_behavior        DECIMAL(3,2) DEFAULT 0,
  total_jobs             INTEGER DEFAULT 0,
  total_earnings         DECIMAL(12,2) DEFAULT 0,
  work_photos            TEXT[] DEFAULT '{}',
  profile_views          INTEGER DEFAULT 0,
  latitude               DECIMAL(10,7),
  longitude              DECIMAL(10,7),
  created_at             TIMESTAMP DEFAULT NOW(),
  updated_at             TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workers_user_id   ON workers(user_id);
CREATE INDEX IF NOT EXISTS idx_workers_skills    ON workers USING GIN(skills);
CREATE INDEX IF NOT EXISTS idx_workers_rating    ON workers(rating_avg DESC);
CREATE INDEX IF NOT EXISTS idx_workers_featured  ON workers(is_featured);
CREATE INDEX IF NOT EXISTS idx_workers_location  ON workers(latitude, longitude);

-- ============================================================
-- OTP CODES
-- ============================================================
CREATE TABLE IF NOT EXISTS otp_codes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone      VARCHAR(20) NOT NULL,
  code       VARCHAR(6) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  is_used    BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_codes(phone);

-- ============================================================
-- BOOKINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS bookings (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID REFERENCES users(id),
  worker_id           UUID REFERENCES workers(id),
  service_type        VARCHAR(100) NOT NULL,
  description         TEXT,
  job_photos          TEXT[] DEFAULT '{}',
  scheduled_date      DATE NOT NULL,
  scheduled_time      TIME NOT NULL,
  address             TEXT NOT NULL,
  address_district    VARCHAR(100),
  latitude            DECIMAL(10,7),
  longitude           DECIMAL(10,7),
  status              VARCHAR(30) DEFAULT 'pending'
                        CHECK (status IN ('pending','accepted','in_progress','completed','cancelled','declined')),
  payment_method      VARCHAR(30) DEFAULT 'cash'
                        CHECK (payment_method IN ('cash','esewa','khalti')),
  payment_status      VARCHAR(30) DEFAULT 'pending'
                        CHECK (payment_status IN ('pending','paid','refunded')),
  amount              DECIMAL(10,2),
  commission          DECIMAL(10,2),
  counter_offer_amount DECIMAL(10,2),
  cancellation_reason TEXT,
  created_at          TIMESTAMP DEFAULT NOW(),
  updated_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_customer  ON bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_worker    ON bookings(worker_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status    ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_date      ON bookings(scheduled_date);

-- ============================================================
-- REVIEWS
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id   UUID UNIQUE REFERENCES bookings(id),
  reviewer_id  UUID REFERENCES users(id),
  reviewed_id  UUID REFERENCES users(id),
  rating       INTEGER CHECK (rating BETWEEN 1 AND 5),
  punctuality  INTEGER CHECK (punctuality BETWEEN 1 AND 5),
  quality      INTEGER CHECK (quality BETWEEN 1 AND 5),
  behavior     INTEGER CHECK (behavior BETWEEN 1 AND 5),
  comment      TEXT,
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_reviewed ON reviews(reviewed_id);
CREATE INDEX IF NOT EXISTS idx_reviews_booking  ON reviews(booking_id);

-- ============================================================
-- MESSAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id),
  sender_id  UUID REFERENCES users(id),
  message    TEXT NOT NULL,
  is_read    BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_booking ON messages(booking_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender  ON messages(sender_id);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES users(id),
  title        TEXT NOT NULL,
  body         TEXT NOT NULL,
  type         VARCHAR(50),
  reference_id UUID,
  is_read      BOOLEAN DEFAULT false,
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user   ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- ============================================================
-- AUTO-UPDATE updated_at TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_users
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_workers
  BEFORE UPDATE ON workers
  FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_bookings
  BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
