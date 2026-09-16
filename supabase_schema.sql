-- Supabase Schema for Food Tinder App

-- 1. Create a table for Users
CREATE TABLE IF NOT EXISTS public.users (
  id uuid references auth.users not null primary key,
  email text not null,
  role text not null default 'user', -- 'user' or 'admin'
  swipe_count integer not null default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Turn on Row Level Security (RLS) for users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
CREATE POLICY "Users can view own profile" 
ON public.users FOR SELECT 
USING (auth.uid() = id);

-- Allow users to update their own profile (e.g., swipe_count)
CREATE POLICY "Users can update own profile" 
ON public.users FOR UPDATE 
USING (auth.uid() = id);

-- Allow admins to read all profiles
CREATE POLICY "Admins can view all profiles" 
ON public.users FOR SELECT 
USING (
  (SELECT role FROM public.users WHERE id = auth.uid()) = 'admin'
);


-- 2. Create a table for Restaurants
CREATE TABLE IF NOT EXISTS public.restaurants (
  id uuid default gen_random_uuid() primary key,
  owner_id uuid references public.users(id) not null,
  name text not null,
  address text not null,
  lat double precision not null,
  lng double precision not null,
  phone text not null,
  email text,
  menu text,
  status text not null default 'pending', -- 'pending', 'approved', 'rejected'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Turn on Row Level Security (RLS) for restaurants table
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read approved restaurants
CREATE POLICY "Anyone can view approved restaurants" 
ON public.restaurants FOR SELECT 
USING (status = 'approved');

-- Allow owner to view their own restaurants
CREATE POLICY "Owners can view own restaurants" 
ON public.restaurants FOR SELECT 
USING (auth.uid() = owner_id);

-- Allow admins to view all restaurants
CREATE POLICY "Admins can view all restaurants" 
ON public.restaurants FOR SELECT 
USING (
  (SELECT role FROM public.users WHERE id = auth.uid()) = 'admin'
);

-- Allow users to insert their own restaurants
CREATE POLICY "Users can insert own restaurants" 
ON public.restaurants FOR INSERT 
WITH CHECK (auth.uid() = owner_id);

-- Allow admins to update restaurant status
CREATE POLICY "Admins can update restaurants" 
ON public.restaurants FOR UPDATE 
USING (
  (SELECT role FROM public.users WHERE id = auth.uid()) = 'admin'
);

-- 3. Create a trigger to automatically create a user profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, role, swipe_count)
  VALUES (new.id, new.email, 'user', 0);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. Create a table for Reviews
CREATE TABLE IF NOT EXISTS public.reviews (
  id uuid default gen_random_uuid() primary key,
  restaurant_id uuid references public.restaurants(id) on delete cascade,
  user_id uuid references public.users(id),
  user_name text not null,
  user_avatar text,
  rating integer not null check (rating >= 1 and rating <= 5),
  comment text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Turn on Row Level Security (RLS) for reviews table
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read reviews
CREATE POLICY "Anyone can view reviews" 
ON public.reviews FOR SELECT 
USING (true);

-- Allow authenticated users to insert reviews
CREATE POLICY "Users can insert reviews" 
ON public.reviews FOR INSERT 
WITH CHECK (auth.uid() = user_id);

