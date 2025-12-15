-- ================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Event Management System
-- ================================

-- IMPORTANT: Run this AFTER creating the main schema
-- These policies ensure data security at the database level

-- ================================
-- 1. PROFILES TABLE
-- ================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can view all profiles (for displaying organizer info, etc.)
CREATE POLICY "Profiles are viewable by everyone" 
    ON profiles FOR SELECT 
    USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" 
    ON profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Users can insert their own profile (handled by trigger)
CREATE POLICY "Users can insert own profile" 
    ON profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- ================================
-- 2. EVENT CATEGORIES TABLE
-- ================================
ALTER TABLE event_categories ENABLE ROW LEVEL SECURITY;

-- Everyone can view categories
CREATE POLICY "Categories are viewable by everyone" 
    ON event_categories FOR SELECT 
    USING (true);

-- Only authenticated users can suggest categories (admin approval needed)
-- In production, you might want to restrict this further

-- ================================
-- 3. EVENTS TABLE
-- ================================
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Everyone can view published events
CREATE POLICY "Published events are viewable by everyone" 
    ON events FOR SELECT 
    USING (is_published = true OR auth.uid() = organizer_id);

-- Organizers can create events
CREATE POLICY "Organizers can create events" 
    ON events FOR INSERT 
    WITH CHECK (
        auth.uid() = organizer_id AND
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'organizer'
        )
    );

-- Organizers can update their own events
CREATE POLICY "Organizers can update own events" 
    ON events FOR UPDATE 
    USING (auth.uid() = organizer_id);

-- Organizers can delete their own events
CREATE POLICY "Organizers can delete own events" 
    ON events FOR DELETE 
    USING (auth.uid() = organizer_id);

-- ================================
-- 4. REGISTRATIONS TABLE
-- ================================
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;

-- Users can view their own registrations
CREATE POLICY "Users can view own registrations" 
    ON registrations FOR SELECT 
    USING (auth.uid() = user_id);

-- Organizers can view registrations for their events
CREATE POLICY "Organizers can view event registrations" 
    ON registrations FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = registrations.event_id 
            AND events.organizer_id = auth.uid()
        )
    );

-- Users can create registrations
CREATE POLICY "Users can create registrations" 
    ON registrations FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own registrations
CREATE POLICY "Users can update own registrations" 
    ON registrations FOR UPDATE 
    USING (auth.uid() = user_id);

-- ================================
-- 5. FAVORITES TABLE
-- ================================
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Users can view their own favorites
CREATE POLICY "Users can view own favorites" 
    ON favorites FOR SELECT 
    USING (auth.uid() = user_id);

-- Users can create favorites
CREATE POLICY "Users can create favorites" 
    ON favorites FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own favorites
CREATE POLICY "Users can delete own favorites" 
    ON favorites FOR DELETE 
    USING (auth.uid() = user_id);

-- ================================
-- 6. TICKETS TABLE
-- ================================
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- Users can view their own tickets
CREATE POLICY "Users can view own tickets" 
    ON tickets FOR SELECT 
    USING (auth.uid() = user_id);

-- Organizers can view tickets for their events
CREATE POLICY "Organizers can view event tickets" 
    ON tickets FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = tickets.event_id 
            AND events.organizer_id = auth.uid()
        )
    );

-- System can create tickets (service layer handles this)
CREATE POLICY "Authenticated users can create tickets" 
    ON tickets FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Organizers can update ticket status (for check-in)
CREATE POLICY "Organizers can update event tickets" 
    ON tickets FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = tickets.event_id 
            AND events.organizer_id = auth.uid()
        )
    );

-- ================================
-- 7. NOTIFICATIONS TABLE
-- ================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications" 
    ON notifications FOR SELECT 
    USING (auth.uid() = user_id);

-- System can create notifications (service layer)
CREATE POLICY "Authenticated users can receive notifications" 
    ON notifications FOR INSERT 
    WITH CHECK (true);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" 
    ON notifications FOR UPDATE 
    USING (auth.uid() = user_id);

-- Users can delete their own notifications
CREATE POLICY "Users can delete own notifications" 
    ON notifications FOR DELETE 
    USING (auth.uid() = user_id);

-- ================================
-- 8. ORGANIZER STATISTICS TABLE
-- ================================
ALTER TABLE organizer_statistics ENABLE ROW LEVEL SECURITY;

-- Organizers can view their own statistics
CREATE POLICY "Organizers can view own statistics" 
    ON organizer_statistics FOR SELECT 
    USING (auth.uid() = organizer_id);

-- Everyone can view statistics (for leaderboards, etc.)
CREATE POLICY "Statistics are viewable by everyone" 
    ON organizer_statistics FOR SELECT 
    USING (true);

-- System can create/update statistics
CREATE POLICY "System can manage statistics" 
    ON organizer_statistics FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- ================================
-- 9. PAYMENTS TABLE
-- ================================
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Users can view their own payments
CREATE POLICY "Users can view own payments" 
    ON payments FOR SELECT 
    USING (auth.uid() = user_id);

-- Organizers can view payments for their events
CREATE POLICY "Organizers can view event payments" 
    ON payments FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = payments.event_id 
            AND events.organizer_id = auth.uid()
        )
    );

-- System can create payments
CREATE POLICY "Authenticated users can create payments" 
    ON payments FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- System can update payment status
CREATE POLICY "System can update payments" 
    ON payments FOR UPDATE 
    USING (auth.uid() = user_id);

-- ================================
-- 10. REVIEWS TABLE (Optional)
-- ================================
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Everyone can view reviews
CREATE POLICY "Reviews are viewable by everyone" 
    ON reviews FOR SELECT 
    USING (true);

-- Registered users can create reviews for events they attended
CREATE POLICY "Users can review attended events" 
    ON reviews FOR INSERT 
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM registrations 
            WHERE registrations.event_id = reviews.event_id 
            AND registrations.user_id = auth.uid()
        )
    );

-- Users can update their own reviews
CREATE POLICY "Users can update own reviews" 
    ON reviews FOR UPDATE 
    USING (auth.uid() = user_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete own reviews" 
    ON reviews FOR DELETE 
    USING (auth.uid() = user_id);

-- ================================
-- COMPLETED
-- ================================
-- RLS policies created successfully!
-- All tables are now protected with Row Level Security
-- Test these policies thoroughly before production deployment
