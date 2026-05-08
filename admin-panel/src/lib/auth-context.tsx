'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from './supabase';
import { toast } from 'sonner';

interface User {
  id: string;
  email: string;
  name: string;
  role: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const fetchProfile = async (userId: string, email: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('first_name, last_name, role')
        .eq('id', userId)
        .single();

      if (error) throw error;
      
      // Strict Admin check for Admin Panel
      if (data.role !== 'admin') {
        await supabase.auth.signOut();
        throw new Error('Access denied. You do not have administrator privileges.');
      }

      const userData: User = {
        id: userId,
        email: email,
        name: `${data.first_name || ''} ${data.last_name || ''}`.trim() || email.split('@')[0],
        role: data.role
      };
      
      setUser(userData);
      return userData;
    } catch (error) {
      console.error('Profile fetch error:', error);
      throw error;
    }
  };

  useEffect(() => {
    const initAuth = async () => {
      console.log('Initializing Auth...');
      try {
        const { data: { session }, error } = await supabase.auth.getSession();
        if (error) throw error;

        if (session?.user) {
          console.log('Session found for user:', session.user.email);
          try {
            await fetchProfile(session.user.id, session.user.email!);
          } catch (e) {
            console.error('Profile fetch failed during init:', e);
            setUser(null);
            // Don't toast here as fetchProfile might already have or it's a redirect case
          }
        } else {
          console.log('No active session found.');
        }
      } catch (e) {
        console.error('Auth initialization error (Root Cause):', e);
        toast.error('Authentication service is currently unavailable. Please try again later.');
      } finally {
        setIsLoading(false);
        console.log('Auth initialization complete. isLoading set to false.');
      }
    };

    initAuth();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('Auth state changed:', event);
      if (session?.user) {
        try {
          await fetchProfile(session.user.id, session.user.email!);
        } catch (e) {
          console.error('Auth state change profile fetch error:', e);
          setUser(null);
        }
      } else {
        setUser(null);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const login = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
    if (data.user) {
      await fetchProfile(data.user.id, email);
    }
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
